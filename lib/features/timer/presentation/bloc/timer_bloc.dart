import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/utils/ticker.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';
import '../../domain/entities/timer_config.dart';
import '../../domain/entities/timer_phase.dart';
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
  }

  void addObserver(TimerObserver observer) => _observers.add(observer);
  void removeObserver(TimerObserver observer) => _observers.remove(observer);

  // --- Event Handlers ---

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    _workoutStartTime = DateTime.now();
    _totalPausedDuration = Duration.zero;
    _lastElapsedSeconds = 0;

    _initializeWorkout(event.config, emit);
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is! TimerRunning) return;

    _tickerSubscription?.cancel();
    _pauseStartTime = DateTime.now();

    final currentState = state as TimerRunning;
    emit(
      TimerPausedState(
        phase: currentState.phase,
        remainingSeconds: currentState.remainingSeconds,
        totalPhaseSeconds: currentState.totalPhaseSeconds,
        currentRound: currentState.currentRound,
        totalRounds: currentState.totalRounds,
        config: currentState.config,
      ),
    );
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is! TimerPausedState) return;

    _recordPauseDuration();

    final currentState = state as TimerPausedState;
    final elapsedSoFar =
        currentState.totalPhaseSeconds - currentState.remainingSeconds;

    _resumeTicker(elapsedSoFar);

    emit(
      TimerRunning(
        phase: currentState.phase,
        remainingSeconds: currentState.remainingSeconds,
        totalPhaseSeconds: currentState.totalPhaseSeconds,
        currentRound: currentState.currentRound,
        totalRounds: currentState.totalRounds,
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
    final phase = currentState.phase;
    final currentRound = currentState.currentRound;

    final strategy = _getStrategy(config, phase);
    final totalSeconds = _getTotalPhaseSeconds(config, phase);
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
    if (phase == TimerPhase.work &&
        totalSeconds > 0 &&
        currentRound > 0 &&
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
          phase: phase,
          remainingSeconds: displayTime,
          totalPhaseSeconds: totalSeconds,
          currentRound: currentRound,
          totalRounds: config.rounds,
          config: config,
        ),
      );
    } else {
      _finishCurrentPhase(emit);
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
        phase: currentState.phase,
        remainingSeconds: currentState.remainingSeconds,
        totalPhaseSeconds: currentState.totalPhaseSeconds,
        currentRound: currentState.currentRound + 1,
        totalRounds: currentState.totalRounds,
        config: currentState.config,
      ),
    );
  }

  // --- Logic Methods ---

  void _initializeWorkout(TimerConfig config, Emitter<TimerState> emit) {
    if (config.prepareSeconds > 0) {
      _startPhase(TimerPhase.prepare, config, 1, config.prepareSeconds, emit);
    } else {
      _startPhase(TimerPhase.work, config, 1, config.workSeconds, emit);
    }
  }

  void _startPhase(
    TimerPhase phase,
    TimerConfig config,
    int round,
    int seconds,
    Emitter<TimerState> emit,
  ) {
    _lastElapsedSeconds = 0;
    _lastBeepSecond = null;
    _halfwayPlayed = false;
    _startTicker();
    final strategy = _getStrategy(config, phase);
    for (final observer in _observers) {
      observer.onPhaseChanged(phase);
    }
    emit(
      TimerRunning(
        phase: phase,
        remainingSeconds: strategy.calculateDisplayTime(seconds, 0),
        totalPhaseSeconds: seconds,
        currentRound: round,
        totalRounds: config.rounds,
        config: config,
      ),
    );
  }

  void _finishCurrentPhase(Emitter<TimerState> emit) {
    _advancePhase(emit);
  }

  void _advancePhase(Emitter<TimerState> emit) {
    if (state is! TimerActiveState) return;

    final currentState = state as TimerActiveState;
    final config = currentState.config;
    final currentPhase = currentState.phase;
    final currentRound = currentState.currentRound;

    switch (currentPhase) {
      case TimerPhase.prepare:
        _transitionToWork(config, currentRound, emit);
      case TimerPhase.work:
        _handleWorkPhaseEnd(config, currentRound, emit);
      case TimerPhase.rest:
        _transitionToWorkAfterRest(config, currentRound, emit);
      case TimerPhase.cooldown:
        _completeWorkout(config, emit);
    }
  }

  void _transitionToWork(
    TimerConfig config,
    int round,
    Emitter<TimerState> emit,
  ) {
    // Hazırlık bitip antrenman başladığında Start Bell çal
    if (state is TimerActiveState && (state as TimerActiveState).phase == TimerPhase.prepare) {
      unawaited(_playTimerSound(TimerSoundType.startBell));
    }
    _startPhase(TimerPhase.work, config, round, config.workSeconds, emit);
  }

  void _handleWorkPhaseEnd(
    TimerConfig config,
    int round,
    Emitter<TimerState> emit,
  ) {
    for (final observer in _observers) {
      observer.onRoundCompleted(round);
    }
    
    if (config.restSeconds > 0 && round < config.rounds) {
      _transitionToRest(config, round, emit);
    } else if (round < config.rounds) {
      _nextRoundWithoutRest(config, round, emit);
    } else if (config.cooldownSeconds > 0) {
      _transitionToCooldown(config, round, emit);
    } else {
      _completeWorkout(config, emit);
    }
  }

  void _transitionToRest(
    TimerConfig config,
    int round,
    Emitter<TimerState> emit,
  ) {
    _startPhase(TimerPhase.rest, config, round, config.restSeconds, emit);
  }

  void _nextRoundWithoutRest(
    TimerConfig config,
    int round,
    Emitter<TimerState> emit,
  ) {
    _transitionToWork(config, round + 1, emit);
  }

  void _transitionToWorkAfterRest(
    TimerConfig config,
    int round,
    Emitter<TimerState> emit,
  ) {
    _transitionToWork(config, round + 1, emit);
  }

  void _transitionToCooldown(
    TimerConfig config,
    int round,
    Emitter<TimerState> emit,
  ) {
    _startPhase(
      TimerPhase.cooldown,
      config,
      round,
      config.cooldownSeconds,
      emit,
    );
  }

  void _completeWorkout(TimerConfig config, Emitter<TimerState> emit) {
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

  int _getTotalPhaseSeconds(TimerConfig config, TimerPhase phase) {
    switch (phase) {
      case TimerPhase.prepare:
        return config.prepareSeconds;
      case TimerPhase.work:
        return config.workSeconds;
      case TimerPhase.rest:
        return config.restSeconds;
      case TimerPhase.cooldown:
        return config.cooldownSeconds;
    }
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
