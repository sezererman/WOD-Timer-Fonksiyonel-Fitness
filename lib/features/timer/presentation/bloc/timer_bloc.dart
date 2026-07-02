import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../design_system/constants/app_durations.dart';
import '../../../../core/utils/ticker.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';
import '../../domain/entities/timer_config.dart';
import '../../domain/entities/timer_config_extensions.dart';
import '../../domain/entities/timer_phase.dart';
import '../../domain/entities/timer_phase_item.dart';
import '../../domain/strategies/timer_strategy.dart';
import '../../domain/entities/timer_sound_type.dart';
import '../../domain/usecases/play_timer_sound_use_case.dart';
import '../observers/timer_observer.dart';
import 'timer_event.dart';
import 'timer_state.dart';

/// Timer iş mantığı — Observer Pattern ile genişletildi.
/// Ses yönetimi için UseCase (Clean Architecture) kullanır.
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final PlayTimerSoundUseCase _playTimerSound;
  final List<TimerObserver> _observers = [];

  StreamSubscription<int>? _tickerSubscription;
  DateTime? _workoutStartTime;
  Duration _totalPausedDuration = Duration.zero;
  DateTime? _pauseStartTime;
  int _lastElapsedSeconds = 0;
  int? _lastBeepSecond;
  bool _halfwayPlayed = false;

  TimerBloc({
    required Ticker ticker,
    required PlayTimerSoundUseCase playTimerSound,
    List<TimerObserver>? observers,
  })  : _ticker = ticker,
        _playTimerSound = playTimerSound,
        super(const TimerInitial()) {
    if (observers != null) _observers.addAll(observers);

    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerWorkoutEnded>(_onWorkoutEnded);
    on<TimerTicked>(_onTicked);
    on<TimerRoundIncremented>(_onRoundIncremented);
    on<TimerStopped>(_onStopped);
    on<TimerFastForwarded>(_onFastForwarded);
  }

  void addObserver(TimerObserver observer) => _observers.add(observer);
  void removeObserver(TimerObserver observer) => _observers.remove(observer);

  // --- Event Handlers ---

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    WakelockPlus.enable();
    _workoutStartTime = DateTime.now();
    _totalPausedDuration = Duration.zero;
    _lastElapsedSeconds = 0;

    _initializeWorkout(event.config, emit);
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is! TimerRunning) return;

    WakelockPlus.disable();
    _tickerSubscription?.cancel();
    _pauseStartTime = DateTime.now();

    final currentState = state as TimerRunning;
    emit(
      TimerPausedState(
        phases: currentState.phases,
        currentPhaseIndex: currentState.currentPhaseIndex,
        remainingSeconds: currentState.remainingSeconds,
        config: currentState.config,
      ),
    );
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is! TimerPausedState) return;

    WakelockPlus.enable();
    _recordPauseDuration();

    final currentState = state as TimerPausedState;
    final elapsedSoFar =
        currentState.totalPhaseSeconds - currentState.remainingSeconds;

    _resumeTicker(elapsedSoFar);

    emit(
      TimerRunning(
        phases: currentState.phases,
        currentPhaseIndex: currentState.currentPhaseIndex,
        remainingSeconds: currentState.remainingSeconds,
        config: currentState.config,
      ),
    );
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _cleanupTimer();
    emit(const TimerInitial());
  }

  void _onWorkoutEnded(TimerWorkoutEnded event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    if (state is TimerActiveState) {
      _completeWorkout((state as TimerActiveState).config, emit);
    }
  }

  void _onStopped(TimerStopped event, Emitter<TimerState> emit) {
    _cleanupTimer();
    emit(const TimerAborted());
  }

  void _onTicked(TimerTicked event, Emitter<TimerState> emit) {
    if (state is! TimerActiveState) return;

    final currentState = state as TimerActiveState;
    final config = currentState.config;
    final phaseItem = currentState.currentPhaseItem;
    
    if (phaseItem == null) return; // Geçersiz state koruması

    final strategy = _getStrategy(config, phaseItem.phase);
    final totalSeconds = phaseItem.durationSeconds;
    final elapsedSeconds = event.elapsedSeconds;

    // Anti-Cheat: Zaman sıçraması kontrolü
    if ((elapsedSeconds - _lastElapsedSeconds).abs() >
        AppDurations.maxTimeJumpSeconds) {
      _cleanupTimer();
      emit(const TimerInitial());
      return;
    }
    _lastElapsedSeconds = elapsedSeconds;

    final displayTime = strategy.calculateDisplayTime(
      totalSeconds,
      elapsedSeconds,
    );
    
    final trueRemaining = totalSeconds - elapsedSeconds;
    
    // Yarı Yol Kontrolü (Halfway)
    if (phaseItem.phase == TimerPhase.work &&
        totalSeconds > 0 &&
        phaseItem.round > 0 &&
        trueRemaining == totalSeconds ~/ 2 &&
        !_halfwayPlayed) {
      _halfwayPlayed = true;
      unawaited(_playTimerSound(TimerSoundType.halfwayGong));
    }

    // Son 3 saniye (Countdown)
    if (trueRemaining <= AppDurations.countdownThreshold &&
        trueRemaining > 0 &&
        trueRemaining != _lastBeepSecond) {
      _lastBeepSecond = trueRemaining;
      unawaited(_playTimerSound(TimerSoundType.beepShort));
    }

    if (!strategy.isFinished(totalSeconds, elapsedSeconds)) {
      emit(
        TimerRunning(
          phases: currentState.phases,
          currentPhaseIndex: currentState.currentPhaseIndex,
          remainingSeconds: displayTime,
          config: config,
        ),
      );
    } else {
      _advancePhase(emit);
    }
  }

  void _onRoundIncremented(
    TimerRoundIncremented event,
    Emitter<TimerState> emit,
  ) {
    if (state is! TimerRunning) return;

    final currentState = state as TimerRunning;
    for (final observer in _observers) {
      observer.onRoundCompleted(currentState.currentRound);
    }
    emit(
      TimerRunning(
        phases: currentState.phases,
        currentPhaseIndex: currentState.currentPhaseIndex,
        remainingSeconds: currentState.remainingSeconds,
        config: currentState.config,
      ),
    );
  }

  void _onFastForwarded(TimerFastForwarded event, Emitter<TimerState> emit) {
    // Sayacı ileri sarmak yalnızca aktif çalışırken mantıklıdır.
    if (state is! TimerRunning) return;

    final secondsToAdd = event.elapsedBackgroundDuration.inSeconds;
    if (secondsToAdd <= 0) return;

    final newElapsed = _lastElapsedSeconds + secondsToAdd;
    _resumeTicker(newElapsed);
    // Hemen UI'ı güncellemesi için manuel bir tick tetikleyelim
    add(TimerTicked(newElapsed));
  }

  // --- Logic Methods ---

  void _initializeWorkout(TimerConfig config, Emitter<TimerState> emit) {
    final phases = config.generatePhases();
    if (phases.isEmpty) {
      _completeWorkout(config, emit);
      return;
    }
    _startPhase(0, phases, config, emit);
  }

  void _startPhase(
    int index,
    List<TimerPhaseItem> phases,
    TimerConfig config,
    Emitter<TimerState> emit,
  ) {
    _lastElapsedSeconds = 0;
    _lastBeepSecond = null;
    _halfwayPlayed = false;
    _startTicker();
    
    final currentItem = phases[index];
    final strategy = _getStrategy(config, currentItem.phase);
    
    for (final observer in _observers) {
      observer.onPhaseChanged(currentItem.phase);
    }

    emit(
      TimerRunning(
        phases: phases,
        currentPhaseIndex: index,
        remainingSeconds: strategy.calculateDisplayTime(currentItem.durationSeconds, 0),
        config: config,
      ),
    );
  }

  void _advancePhase(Emitter<TimerState> emit) {
    if (state is! TimerActiveState) return;

    final currentState = state as TimerActiveState;
    final config = currentState.config;
    final phases = currentState.phases;
    final nextIndex = currentState.currentPhaseIndex + 1;

    // Tur (Round) bitimi event tetikleme:
    // Eğer şu anki faz 'work' ise ve bir sonraki faz 'rest' veya yeni 'work' (veya bitiş) ise round bitmiş demektir.
    // Ağaç yapısında bu biraz daha kompleks olabilir ama observers için basit tutuyoruz.
    if (currentState.phase == TimerPhase.work) {
      for (final observer in _observers) {
        observer.onRoundCompleted(currentState.currentRound);
      }
    }

    if (nextIndex < phases.length) {
      // Start Bell çalma mantığı (Prepare'den Work'e geçerken veya yeni Work başlarken)
      if (phases[nextIndex].phase == TimerPhase.work && 
         (currentState.phase == TimerPhase.prepare || currentState.phase == TimerPhase.rest)) {
        unawaited(_playTimerSound(TimerSoundType.startBell));
      }
      _startPhase(nextIndex, phases, config, emit);
    } else {
      _completeWorkout(config, emit);
    }
  }

  void _completeWorkout(TimerConfig config, Emitter<TimerState> emit) {
    WakelockPlus.disable();
    final totalElapsed = _workoutStartTime != null
        ? DateTime.now().difference(_workoutStartTime!) - _totalPausedDuration
        : Duration.zero;

    unawaited(_playTimerSound(TimerSoundType.finishHorn));

    for (final observer in _observers) {
      observer.onWorkoutCompleted(config, totalElapsed.inSeconds);
    }

    emit(
      TimerCompleted(
        config: config,
        totalElapsedSeconds: totalElapsed.inSeconds,
      ),
    );
  }

  TimerStrategy _getStrategy(TimerConfig config, TimerPhase phase) {
    if (config.mode == WorkoutMode.forTime && phase == TimerPhase.work) {
      return const CountupStrategy();
    }
    return const CountdownStrategy();
  }

  void _startTicker() {
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick().listen(
      (elapsed) => add(TimerTicked(elapsed)),
    );
  }

  void _resumeTicker(int elapsedSoFar) {
    _tickerSubscription?.cancel();
    _lastElapsedSeconds = elapsedSoFar;
    _tickerSubscription = _ticker
        .tick(startElapsed: elapsedSoFar)
        .listen((elapsed) => add(TimerTicked(elapsed)));
  }

  void _recordPauseDuration() {
    if (_pauseStartTime != null) {
      _totalPausedDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }
  }

  void _cleanupTimer() {
    WakelockPlus.disable();
    _tickerSubscription?.cancel();
    _workoutStartTime = null;
    _totalPausedDuration = Duration.zero;
    _pauseStartTime = null;
    _lastBeepSecond = null;
    _halfwayPlayed = false;
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
