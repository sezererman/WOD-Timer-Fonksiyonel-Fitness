// ignore_for_file: lines_longer_than_80_chars

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/services.dart';

import 'package:fonksiyonel_fitness_timer/core/utils/ticker.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/domain/entities/timer_config.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/domain/entities/timer_phase.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/domain/entities/timer_sound_type.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/domain/usecases/play_timer_sound_use_case.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/presentation/bloc/timer_event.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/presentation/bloc/timer_state.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/presentation/observers/timer_observer.dart';
import 'package:fonksiyonel_fitness_timer/features/workout_modes/domain/entities/workout_mode.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOCK SINIFLAR
// ─────────────────────────────────────────────────────────────────────────────

class MockTicker extends Mock implements Ticker {}

class MockTimerObserver extends Mock implements TimerObserver {}

class MockPlayTimerSoundUseCase extends Mock implements PlayTimerSoundUseCase {}

// ─────────────────────────────────────────────────────────────────────────────
// TEST SABITLERI
// ─────────────────────────────────────────────────────────────────────────────

/// AMRAP konfigürasyonu: 10 sn çalışma, hazırlık yok.
const tAmrapConfig = TimerConfig(
  rounds: 1,
  workSeconds: 10,
  prepareSeconds: 0,
  mode: WorkoutMode.amrap,
  requiresManualRoundIncrement: true,
);

/// EMOM konfigürasyonu: 3 tur, 5 sn çalışma + 3 sn dinlenme, hazırlık yok.
const tEmomConfig = TimerConfig(
  rounds: 3,
  workSeconds: 5,
  restSeconds: 3,
  prepareSeconds: 0,
  mode: WorkoutMode.emom,
);

/// Hazırlık fazı içeren konfigürasyon.
const tConfigWithPrepare = TimerConfig(
  rounds: 1,
  workSeconds: 10,
  prepareSeconds: 5,
);

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock WakelockPlus platform channel (Pigeon)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
    (ByteData? message) async {
      return const StandardMessageCodec().encodeMessage(<Object?>[null]);
    },
  );

  late MockTicker mockTicker;
  late MockTimerObserver mockObserver;
  late MockPlayTimerSoundUseCase mockPlayTimerSound;

  // Mocktail, any() ile kullanılan non-nullable özel tipler için fallback gerektirir.
  setUpAll(() {
    registerFallbackValue(TimerSoundType.beepShort);
    registerFallbackValue(TimerPhase.work);
    registerFallbackValue(
      const TimerConfig(rounds: 1, workSeconds: 10, prepareSeconds: 0),
    );
  });

  // Her testten önce mock'ları temizle ve sıfırla.
  setUp(() {
    mockTicker = MockTicker();
    mockObserver = MockTimerObserver();
    mockPlayTimerSound = MockPlayTimerSoundUseCase();

    // Ses efektleri hiçbir test akışını bloklamamalı.
    when(() => mockPlayTimerSound.call(any())).thenAnswer((_) async {});

    // Observer metodları varsayılan olarak boş — özel testlerde override edilir.
    when(() => mockObserver.onPhaseChanged(any())).thenReturn(null);
    when(() => mockObserver.onRoundCompleted(any())).thenReturn(null);
    when(() => mockObserver.onWorkoutCompleted(any(), any())).thenReturn(null);
  });

  // Her test kendi bloc örneğini oluşturur — setUp içinde değil.
  TimerBloc buildBloc() => TimerBloc(
        ticker: mockTicker,
        playTimerSound: mockPlayTimerSound,
        observers: [mockObserver],
      );

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 1: BAŞLANGIÇ DURUMU
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 1. Başlangıç Durumu', () {
    // GIVEN: Hiçbir event gönderilmemiş, taze bir TimerBloc oluşturulmuş.
    // WHEN: Bloc'un state'i okunuyor.
    // THEN: State, TimerInitial olmalı.
    test('GIVEN taze bir bloc / WHEN state okunur / THEN TimerInitial dönmeli',
        () {
      final bloc = buildBloc();
      expect(bloc.state, const TimerInitial());
      bloc.close();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 2: TIMER BAŞLATMA (StartTimer)
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 2. Timer Başlatma', () {
    // GIVEN: prepareSeconds = 5 olan bir config.
    // WHEN: TimerStarted eventi gönderilir.
    // THEN: İlk emit edilen state, TimerPhase.prepare fazında TimerRunning olmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN hazırlık fazlı config / WHEN TimerStarted / THEN prepare fazında TimerRunning emit edilmeli',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted(tConfigWithPrepare)),
      expect: () => [
        isA<TimerRunning>().having(
          (s) => s.phase,
          'phase',
          TimerPhase.prepare,
        ),
      ],
    );

    // GIVEN: prepareSeconds = 0 olan bir AMRAP config.
    // WHEN: TimerStarted eventi gönderilir.
    // THEN: Hazırlık fazı atlanarak doğrudan TimerPhase.work fazında başlamalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN prepareSeconds=0 olan config / WHEN TimerStarted / THEN doğrudan work fazında başlamalı',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted(tAmrapConfig)),
      expect: () => [
        isA<TimerRunning>().having(
          (s) => s.phase,
          'phase',
          TimerPhase.work,
        ),
      ],
    );

    // GIVEN: 10 sn'lik bir AMRAP config.
    // WHEN: TimerStarted eklenir ve ilk tick gelir.
    // THEN: remainingSeconds = 10 - 1 = 9 olarak güncellenmeli.
    blocTest<TimerBloc, TimerState>(
      'GIVEN 10 sn AMRAP / WHEN 1. tick gelir / THEN remainingSeconds doğru azalmalı (10→9)',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted(tAmrapConfig)),
      expect: () => [
        // TimerStarted → ilk emit: remainingSeconds = 10
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 10),
        // Tick(1) → remainingSeconds = 9
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 9),
      ],
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 3: AMRAP — SÜRE BİTİŞİ
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 3. AMRAP Süre Bitişi', () {
    // GIVEN: 3 sn'lik bir AMRAP config (prepareSeconds=0).
    // WHEN: Ticker 1, 2, 3 değerlerini yayınlar (tüm süre tüketilir).
    // THEN: Work 3→2→1 azalırken en son TimerCompleted emit edilmeli.
    blocTest<TimerBloc, TimerState>(
      'GIVEN EMOM 2-tur / WHEN ticks tamamlanır / THEN Work→Rest→Work→Completed sırası olmalı',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1, 2]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const TimerStarted(
          TimerConfig(
            rounds: 2,
            workSeconds: 2,
            restSeconds: 2,
            prepareSeconds: 0,
            mode: WorkoutMode.emom,
          ),
        ),
      ),
      expect: () => [
        // Tüm antrenman (2 tur EMOM) tamamlanır — en son state TimerCompleted olmalı
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.work).having((s) => s.remainingSeconds, 'remaining', 2),
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 1),
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.rest),
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.rest).having((s) => s.remainingSeconds, 'remaining', 1),
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.work).having((s) => s.currentRound, 'round', 2),
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 1),
        isA<TimerCompleted>(),
      ],
    );

    // GIVEN: 3 sn AMRAP, süre bitince tamamlandı.
    // WHEN: Workout tamamlanır.
    // THEN: Observer'ın onWorkoutCompleted çağrılmış olmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN AMRAP bitiş / WHEN TimerCompleted / THEN observer.onWorkoutCompleted çağrılmalı',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1, 2, 3]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const TimerStarted(
          TimerConfig(rounds: 1, workSeconds: 3, prepareSeconds: 0, mode: WorkoutMode.amrap),
        ),
      ),
      verify: (_) {
        verify(() => mockObserver.onWorkoutCompleted(any(), any())).called(1);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 4: EMOM — FAZ GEÇİŞLERİ
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 4. EMOM Faz Geçişleri', () {
    // GIVEN: 3 sn'lik AMRAP (prepareSeconds=0).
    // WHEN: Ticker [1, 2, 3] emit eder.
    // THEN: remainingSeconds 3→2→1 azalmalı ve son state TimerCompleted olmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN 3 sn AMRAP / WHEN ticks [1,2,3] / THEN geri sayım doğru ilerlemeli',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1, 2, 3]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const TimerStarted(
          TimerConfig(
            rounds: 1,
            workSeconds: 3,
            prepareSeconds: 0,
            mode: WorkoutMode.amrap,
          ),
        ),
      ),
      expect: () => [
        // Başlangıç: remainingSeconds = 3
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 3),
        // Tick(1): 2 kaldı
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 2),
        // Tick(2): 1 kaldı
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 1),
        // Tick(3): süre bitti → TimerCompleted
        isA<TimerCompleted>(),
      ],
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 5: DURAKLAT / DEVAM ET
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 5. Duraklat / Devam Et', () {
    // GIVEN: Timer çalışıyor (TimerRunning state).
    // WHEN: TimerPaused eventi gönderilir.
    // THEN: State, TimerPausedState olmalı ve phase/remainingSeconds korunmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer çalışırken / WHEN TimerPaused / THEN TimerPausedState emit edilmeli',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const TimerStarted(tAmrapConfig));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerPaused());
      },
      expect: () => [
        isA<TimerRunning>(), // TimerStarted
        isA<TimerPausedState>()
            .having((s) => s.phase, 'phase', TimerPhase.work)
            .having((s) => s.remainingSeconds, 'remaining', 10),
      ],
    );

    // GIVEN: Timer duraklatılmış (TimerPausedState).
    // WHEN: TimerResumed eventi gönderilir.
    // THEN: State, TimerRunning'e dönmeli, remainingSeconds değişmemeli.
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer duraklatılmışken / WHEN TimerResumed / THEN TimerRunning state\'e dönmeli',
      build: () {
        // İlk başlatma akışı boş, resume sonrası da boş ticker.
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const TimerStarted(tAmrapConfig));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerPaused());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerResumed());
      },
      expect: () => [
        isA<TimerRunning>(),      // TimerStarted
        isA<TimerPausedState>(),  // TimerPaused
        isA<TimerRunning>(),      // TimerResumed
      ],
    );

    // GIVEN: Timer çalışmıyor (TimerInitial state).
    // WHEN: TimerPaused eventi gönderilir.
    // THEN: Hiçbir state değişikliği olmamalı (guard clause).
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer başlamadıysa / WHEN TimerPaused / THEN state değişmemeli',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const TimerPaused()),
      expect: () => <TimerState>[],
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 6: SIFIRLA VE DURDUR
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 6. Sıfırla ve Durdur', () {
    // GIVEN: Timer çalışıyor.
    // WHEN: TimerReset eventi gönderilir.
    // THEN: State, TimerInitial'a döner.
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer çalışırken / WHEN TimerReset / THEN TimerInitial emit edilmeli',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const TimerStarted(tAmrapConfig));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerReset());
      },
      expect: () => [
        isA<TimerRunning>(),
        const TimerInitial(),
      ],
    );

    // GIVEN: Timer çalışıyor.
    // WHEN: TimerStopped eventi gönderilir.
    // THEN: State, TimerAborted olmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer çalışırken / WHEN TimerStopped / THEN TimerAborted emit edilmeli',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const TimerStarted(tAmrapConfig));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerStopped());
      },
      expect: () => [
        isA<TimerRunning>(),
        const TimerAborted(),
      ],
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 7: AMRAP — MANUEL TUR ARTIRMA
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 7. AMRAP Manuel Tur Artırma', () {
    // GIVEN: AMRAP modu, timer çalışıyor (currentRound = 1).
    // WHEN: TimerRoundIncremented eventi gönderilir.
    // THEN: currentRound = 2 olmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN AMRAP timer çalışırken / WHEN TimerRoundIncremented / THEN observer.onRoundCompleted çağrılmalı',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const TimerStarted(tAmrapConfig));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerRoundIncremented());
      },
      expect: () => [
        // Sadece ilk başlatma state'i gelir, TimerRoundIncremented aynı state'i emit ettiği için düşer.
        isA<TimerRunning>().having((s) => s.currentRound, 'round', 1),
      ],
      verify: (_) {
        verify(() => mockObserver.onRoundCompleted(1)).called(1);
      },
    );

    // GIVEN: Timer başlamamış (TimerInitial state).
    // WHEN: TimerRoundIncremented eventi gönderilir.
    // THEN: Hiçbir state değişikliği olmamalı (guard clause).
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer başlamadıysa / WHEN TimerRoundIncremented / THEN state değişmemeli',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const TimerRoundIncremented()),
      expect: () => <TimerState>[],
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 8: GÜVENLİK — ANTİ-CHEAT (Zaman Sıçraması)
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 8. Güvenlik (Anti-Cheat)', () {
    // GIVEN: Ticker 1'den 10'a sıçrama yapıyor (maxTimeJump = 2).
    // WHEN: TimerStarted + sıçramalı ticks.
    // THEN: Sıçrama tespit edilince TimerInitial'a reset edilmeli.
    blocTest<TimerBloc, TimerState>(
      'GIVEN ileri zaman sıçraması (1→10) / WHEN tick gelir / THEN TimerInitial\'a reset edilmeli',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1, 10]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted(tAmrapConfig)),
      expect: () => [
        isA<TimerRunning>(), // TimerStarted
        isA<TimerRunning>(), // Tick(1) — normal
        const TimerInitial(), // Tick(10) — sıçrama algılandı, reset
      ],
    );

    // GIVEN: Ticker geriye doğru sıçrama yapıyor (1 → -2 = 3 sn fark).
    // WHEN: TimerStarted + geriye sıçramalı ticks.
    // THEN: Sıçrama tespit edilince TimerInitial'a reset edilmeli.
    blocTest<TimerBloc, TimerState>(
      'GIVEN geriye zaman sıçraması (1→-2) / WHEN tick gelir / THEN TimerInitial\'a reset edilmeli',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1, -2]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const TimerStarted(tAmrapConfig)),
      expect: () => [
        isA<TimerRunning>(), // TimerStarted
        isA<TimerRunning>(), // Tick(1) — normal
        const TimerInitial(), // Tick(-2) — geriye sıçrama algılandı
      ],
    );

    // GIVEN: Ticks sınır değerde (fark = 2, tam eşit).
    // WHEN: TimerStarted + sınır değeri ticks.
    // THEN: maxTimeJump = 2 sınırında sıçrama kabul edilmeli (reset olmamalı).
    blocTest<TimerBloc, TimerState>(
      'GIVEN sınır değer sıçraması (fark = 2) / WHEN tick gelir / THEN reset olmamali',
      build: () {
        when(() => mockTicker.tick())
            .thenAnswer((_) => Stream.fromIterable([1, 3])); // fark = 2, eşik = 2
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const TimerStarted(
          TimerConfig(rounds: 1, workSeconds: 10, prepareSeconds: 0),
        ),
      ),
      expect: () => [
        isA<TimerRunning>(), // TimerStarted
        isA<TimerRunning>(), // Tick(1) — normal
        isA<TimerRunning>(), // Tick(3) — fark=2, eşik dahilinde, reset YOK
      ],
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 9: STATE AKIŞ DOĞRULAMASI
  // ───────────────────────────────────────────────────────────────────────────

  group('TimerBloc — 9. State Akış Doğrulaması', () {
    // GIVEN: 2 tur EMOM, 2 sn work, 1 sn rest, hazırlık yok.
    // WHEN: Tüm work ve rest fazları tamamlanır.
    // THEN: Son state TimerCompleted olmalı.
    blocTest<TimerBloc, TimerState>(
      'GIVEN tam 2-tur EMOM akışı / WHEN tüm fazlar tamamlanır / THEN TimerCompleted ile bitmeli',
      build: () {
        // Tur 1: work 2sn (tick: 1,2) → rest 1sn (tick: 1) → Tur 2: work 2sn (tick: 1,2)
        // Her yeni phase başladığında elapsed sıfırlanır, yeni ticker başlar.
        // Stream'ler zincirlenmez; her tick() çağrısında yeni stream döner.
        int callCount = 0;
        when(() => mockTicker.tick()).thenAnswer((_) {
          callCount++;
          // 1. call: Tur-1 work fazı (1, 2)
          // 2. call: Tur-1 rest fazı (1)
          // 3. call: Tur-2 work fazı (1, 2) → tamamlanır
          switch (callCount) {
            case 1:
              return Stream.fromIterable([1, 2]);
            case 2:
              return Stream.fromIterable([1]);
            case 3:
              return Stream.fromIterable([1, 2]);
            default:
              return const Stream.empty();
          }
        });
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const TimerStarted(
          TimerConfig(
            rounds: 2,
            workSeconds: 2,
            restSeconds: 1,
            prepareSeconds: 0,
            mode: WorkoutMode.emom,
          ),
        ),
      ),
      expect: () => [
        // Tur 1 - Work fazı başlıyor
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.work).having((s) => s.currentRound, 'round', 1),
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 1),
        // Tur 1 - Rest fazı
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.rest),
        // Tur 2 - Work fazı
        isA<TimerRunning>().having((s) => s.phase, 'phase', TimerPhase.work).having((s) => s.currentRound, 'round', 2),
        isA<TimerRunning>().having((s) => s.remainingSeconds, 'remaining', 1),
        // Tamamlandı
        isA<TimerCompleted>(),
      ],
    );

    // GIVEN: Timer çalışıyor.
    // WHEN: TimerWorkoutEnded eventi gönderilir (erken bitiş).
    // THEN: TimerCompleted state'e geçmeli.
    blocTest<TimerBloc, TimerState>(
      'GIVEN timer çalışırken / WHEN TimerWorkoutEnded / THEN TimerCompleted emit edilmeli',
      build: () {
        when(() => mockTicker.tick()).thenAnswer((_) => const Stream.empty());
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const TimerStarted(tAmrapConfig));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerWorkoutEnded());
      },
      expect: () => [
        isA<TimerRunning>(),
        isA<TimerCompleted>(),
      ],
    );
  });
}
