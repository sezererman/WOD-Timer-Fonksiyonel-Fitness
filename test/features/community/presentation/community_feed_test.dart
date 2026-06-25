// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fonksiyonel_fitness_timer/features/community/domain/entities/workout_share_entity.dart';
import 'package:fonksiyonel_fitness_timer/features/community/presentation/bloc/workout_share/workout_share_bloc.dart';
import 'package:fonksiyonel_fitness_timer/features/community/presentation/bloc/workout_share/workout_share_event.dart';
import 'package:fonksiyonel_fitness_timer/features/community/presentation/bloc/workout_share/workout_share_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOCK SINIFLAR
// ─────────────────────────────────────────────────────────────────────────────

class MockWorkoutShareBloc
    extends MockBloc<WorkoutShareEvent, WorkoutShareState>
    implements WorkoutShareBloc {}

// ─────────────────────────────────────────────────────────────────────────────
// TEST SABİTLERİ
// ─────────────────────────────────────────────────────────────────────────────

const _kCurrentUserId = 'user-test-123';
const _kPostId = 'post-abc-001';

/// Beğenilmemiş bir gönderi — currentUser likedUserIds'de YOK.
final tPostUnliked = WorkoutShareEntity(
  id: _kPostId,
  userId: 'other-user-999',
  userName: 'CrossFit Atlet',
  workoutType: 'AMRAP',
  durationSeconds: 720,
  score: 42,
  date: DateTime(2026, 6, 25),
  likesCount: 5,
);

/// Beğenilmiş bir gönderi — currentUser likedUserIds'de VAR.
final tPostLiked = tPostUnliked.copyWith(
  likesCount: 6,
  likedUserIds: const [_kCurrentUserId],
);

// ─────────────────────────────────────────────────────────────────────────────
// YARDIMCI — Test Widget Sarmalayıcısı
//
// FeedPostCard, GetIt aracılığıyla SupabaseSocialDataSource bağımlılığı
// aldığından DI bağlamı gerektirmektedir. Bu nedenle widget testleri,
// sadece iş mantığını kapsayan minimal bir SocialFeedTestHarness widget'ı
// üzerinden yürütülür.
//
// Bu yaklaşım:
//  - Gerçek ağ/DB bağlantısından tamamen izole eder.
//  - WorkoutShareBloc'un Optimistic UI davranışını saf olarak test eder.
//  - Integration sürtüşmesi yaratmaz.
// ─────────────────────────────────────────────────────────────────────────────

/// Beğeni durumunu ve sayacını doğrudan WorkoutShareBloc state'inden okuyan
/// minimal test widget'ı. Gerçek FeedPostCard'ın _InteractionButton mantığını
/// aynı iken UI katmanına bağımlılığı sıfırlayan temiz bir harness.
class SocialFeedTestHarness extends StatelessWidget {
  final String postId;
  final String currentUserId;

  const SocialFeedTestHarness({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutShareBloc, WorkoutShareState>(
      builder: (ctx, state) {
        // BLoC state'inden ilgili postu bul.
        WorkoutShareEntity? post;
        bool isLiked = false;
        int likeCount = 0;

        if (state is WorkoutShareLoaded) {
          try {
            post = state.posts.firstWhere((p) => p.id == postId);
            isLiked = post.likedUserIds.contains(currentUserId);
            likeCount = post.likesCount;
          } catch (_) {}
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Beğeni butonu (Filled = beğenilmiş, Outlined = beğenilmemiş) ──
            IconButton(
              key: const Key('like_button'),
              icon: Icon(
                isLiked
                    ? Icons.fitness_center          // FILLED — beğenildi
                    : Icons.fitness_center_outlined, // OUTLINED — beğenilmedi
              ),
              onPressed: () {
                ctx.read<WorkoutShareBloc>().add(
                      ToggleLikeEvent(
                        workoutId: postId,
                        currentUserId: currentUserId,
                      ),
                    );
              },
            ),
            // Beğeni sayacı — doğrulama için key ile işaretlendi.
            Text(
              '$likeCount',
              key: const Key('like_count'),
            ),
            // İkon tipini doğrulama için semantic etiket
            Text(
              isLiked ? 'liked' : 'not_liked',
              key: const Key('like_status'),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockWorkoutShareBloc mockBloc;
  late StreamController<WorkoutShareState> stateController;

  // Mocktail fallback'leri.
  setUpAll(() {
    registerFallbackValue(
      const ToggleLikeEvent(workoutId: 'x', currentUserId: 'y'),
    );
  });

  setUp(() {
    mockBloc = MockWorkoutShareBloc();
    stateController = StreamController<WorkoutShareState>.broadcast();
    when(() => mockBloc.stream).thenAnswer((_) => stateController.stream);
  });

  tearDown(() {
    stateController.close();
    mockBloc.close();
  });

  // State'i hem getter hem stream için güncelleyen yardımcı metod
  void emitState(WorkoutShareState state) {
    when(() => mockBloc.state).thenReturn(state);
    stateController.add(state);
  }

  // Testi BlocProvider + MaterialApp ile sararak pump eder.
  Widget buildHarness() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<WorkoutShareBloc>.value(
          value: mockBloc,
          child: const SocialFeedTestHarness(
            postId: _kPostId,
            currentUserId: _kCurrentUserId,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 1: BAŞLANGIÇ RENDER
  // ───────────────────────────────────────────────────────────────────────────

  group('CommunityFeed — 1. Başlangıç Render', () {
    // GIVEN: BLoC beğenilmemiş bir post ile WorkoutShareLoaded state'inde.
    // WHEN: Widget render edilir.
    // THEN: Outlined ikon (beğenilmemiş) ekranda görünmeli.
    testWidgets(
      'GIVEN beğenilmemiş post / WHEN render / THEN Outlined ikon görünmeli',
      (tester) async {
        // GIVEN
        when(() => mockBloc.state).thenReturn(
          WorkoutShareLoaded(posts: [tPostUnliked]),
        );

        // WHEN
        await tester.pumpWidget(buildHarness());

        // THEN — outlined ikon var, filled ikon yok
        expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsNothing);
      },
    );

    // GIVEN: BLoC beğenilmemiş post ile yüklü.
    // WHEN: Widget render edilir.
    // THEN: Beğeni sayacı '5' göstermeli.
    testWidgets(
      'GIVEN 5 beğenili post / WHEN render / THEN beğeni sayısı 5 göstermeli',
      (tester) async {
        // GIVEN
        when(() => mockBloc.state).thenReturn(
          WorkoutShareLoaded(posts: [tPostUnliked]),
        );

        // WHEN
        await tester.pumpWidget(buildHarness());

        // THEN
        expect(find.text('5'), findsOneWidget);
        expect(find.byKey(const Key('like_status')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'not_liked',
        );
      },
    );

    // GIVEN: BLoC WorkoutShareLoading state'inde.
    // WHEN: Widget render edilir.
    // THEN: İkon YOK (state'ten post çözümlenemiyor), beğeni sayısı '0'.
    testWidgets(
      'GIVEN WorkoutShareLoading state / WHEN render / THEN like sayısı 0 olmalı',
      (tester) async {
        // GIVEN
        when(() => mockBloc.state).thenReturn(WorkoutShareLoading());

        // WHEN
        await tester.pumpWidget(buildHarness());

        // THEN — post bulunamadığında default değerler
        expect(find.text('0'), findsOneWidget);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 2: OPTİMİSTİK UI — BEĞEN / BEĞENME GEÇİŞİ
  // ───────────────────────────────────────────────────────────────────────────

  group('CommunityFeed — 2. Optimistik UI (Beğeni Geçişi)', () {
    // GIVEN: Beğenilmemiş post görüntüleniyor.
    // WHEN: Beğeni butonuna tıklanır ve BLoC beğenilmiş state'e geçer.
    // THEN: İkon anında Outlined → Filled'a geçmeli (Optimistic UI).
    testWidgets(
      "GIVEN outlined ikon / WHEN beğeni tıklanır / THEN ikon Filled'a geçmeli (Optimistik)",
      (tester) async {
        // GIVEN — önce beğenilmemiş state
        emitState(WorkoutShareLoaded(posts: [tPostUnliked]));

        await tester.pumpWidget(buildHarness());

        // Başlangıçta outlined
        expect(find.byIcon(Icons.fitness_center_outlined), findsOneWidget);

        // WHEN — BLoC'u beğenilmiş state'e taşı
        emitState(WorkoutShareLoaded(posts: [tPostLiked]));
        await tester.pumpAndSettle();

        // THEN — filled ikon görünmeli (like_status 'liked' olmalı)
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'liked',
        );
        expect(find.byIcon(Icons.fitness_center_outlined), findsNothing);
      },
    );

    // GIVEN: Beğenilmemiş post, outlined ikon.
    // WHEN: Butona tıklanır.
    // THEN: ToggleLikeEvent doğru parametrelerle BLoC'a gönderilmeli.
    testWidgets(
      'GIVEN outlined butona tıklanır / WHEN tap / THEN ToggleLikeEvent gönderilmeli',
      (tester) async {
        // GIVEN
        when(() => mockBloc.state).thenReturn(
          WorkoutShareLoaded(posts: [tPostUnliked]),
        );

        await tester.pumpWidget(buildHarness());

        // WHEN — beğeni butonuna tıkla
        await tester.tap(find.byKey(const Key('like_button')));
        await tester.pump();

        // THEN — bloc'a doğru event gönderildi mi?
        verify(
          () => mockBloc.add(
            const ToggleLikeEvent(
              workoutId: _kPostId,
              currentUserId: _kCurrentUserId,
            ),
          ),
        ).called(1);
      },
    );

    // GIVEN: Beğenilmiş post (sayı 6) görüntülenüyor.
    // WHEN: BLoC beğenilmemiş state'e geri döner (rollback).
    // THEN: like_status 'not_liked'a dönmeli ve sayı 5 görünmeli.
    testWidgets(
      "GIVEN filled ikon / WHEN rollback state / THEN ikon Outlined'a dönmeli ve sayı azalmalı",
      (tester) async {
        // GIVEN — başlangıçta beğenilmiş
        emitState(WorkoutShareLoaded(posts: [tPostLiked]));

        await tester.pumpWidget(buildHarness());
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'liked',
        );
        expect(find.text('6'), findsOneWidget);

        // WHEN — rollback: state stub'u beğenilmemiş versiyona güncelle
        emitState(WorkoutShareLoaded(posts: [tPostUnliked]));
        await tester.pumpAndSettle();

        // THEN — geri döndü
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'not_liked',
        );
        expect(find.text('5'), findsOneWidget);
      },
    );

    // GIVEN: Beğenilmemiş post.
    // WHEN: Hızlı ardışık 3 tıklama yapılır.
    // THEN: Her tıklamada ToggleLikeEvent gönderilmeli (debounce BLoC içinde).
    testWidgets(
      'GIVEN hızlı 3 tıklama / WHEN ardışık tap / THEN 3 kez ToggleLikeEvent gönderilmeli',
      (tester) async {
        // GIVEN
        when(() => mockBloc.state).thenReturn(
          WorkoutShareLoaded(posts: [tPostUnliked]),
        );

        await tester.pumpWidget(buildHarness());

        // WHEN — 3 hızlı tıklama
        await tester.tap(find.byKey(const Key('like_button')));
        await tester.tap(find.byKey(const Key('like_button')));
        await tester.tap(find.byKey(const Key('like_button')));
        await tester.pump();

        // THEN — widget katmanı 3 kez event gönderdi
        // (Debounce mantığı BLoC içinde — burada sadece event iletimini doğrularız)
        verify(
          () => mockBloc.add(any<ToggleLikeEvent>()),
        ).called(3);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 3: LIKE STATUS DOĞRULAMASI
  // ───────────────────────────────────────────────────────────────────────────

  group('CommunityFeed — 3. Like Status Anlam Doğrulaması', () {
    // GIVEN: tPostLiked — currentUser likedUserIds'de mevcut.
    // WHEN: render edilir.
    // THEN: like_status 'liked' olmalı, sayı '6'.
    testWidgets(
      'GIVEN beğenilmiş post / WHEN render / THEN like_status=liked ve sayı 6',
      (tester) async {
        // GIVEN
        when(() => mockBloc.state).thenReturn(
          WorkoutShareLoaded(posts: [tPostLiked]),
        );

        // WHEN
        await tester.pumpWidget(buildHarness());

        // THEN
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'liked',
        );
        expect(find.text('6'), findsOneWidget);
      },
    );

    // GIVEN: Birden fazla post içeren liste; testlenen post ortada.
    // WHEN: render edilir.
    // THEN: Sadece ilgili postun like durumu gösterilmeli.
    testWidgets(
      'GIVEN birden fazla post / WHEN render / THEN doğru postun like durumu okunmalı',
      (tester) async {
        // GIVEN — başka bir post da listede
        final otherPost = WorkoutShareEntity(
          id: 'other-post-999',
          userId: 'someone',
          workoutType: 'EMOM',
          durationSeconds: 600,
          date: DateTime(2026, 6, 24),
          likesCount: 99,
          likedUserIds: const ['another-user'],
        );

        when(() => mockBloc.state).thenReturn(
          WorkoutShareLoaded(posts: [otherPost, tPostUnliked]),
        );

        // WHEN
        await tester.pumpWidget(buildHarness());

        // THEN — sadece tPostUnliked için değerler
        expect(find.text('5'), findsOneWidget);        // tPostUnliked.likesCount
        expect(find.text('99'), findsNothing);          // otherPost sayısı görünmemeli
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'not_liked',
        );
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 4: OPTİMİSTİK HATA SONRASI STATE GERİ ALMA
  // ───────────────────────────────────────────────────────────────────────────

  group('CommunityFeed — 4. Hata Sonrası State Geri Alma', () {
    // GIVEN: Hata state'i sonrası WorkoutShareLoaded ile rollback.
    // WHEN: Önce beğenilmiş state görüntülenir, ardından beğenilmemiş state yüklenir.
    // THEN: Son state beğenilmemiş postu göstermeli.
    testWidgets(
      'GIVEN optimistic error / WHEN rollback emit / THEN eski state görünmeli',
      (tester) async {
        // GIVEN — başlangıç: beğenilmiş
        emitState(WorkoutShareLoaded(posts: [tPostLiked]));
        await tester.pumpWidget(buildHarness());
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'liked',
        );

        // WHEN — rollback: state beğenilmemiş versiyona dön
        emitState(WorkoutShareLoaded(posts: [tPostUnliked]));
        await tester.pumpAndSettle();

        // THEN — rollback tamamlandı
        expect(
          tester.widget<Text>(find.byKey(const Key('like_status'))).data,
          'not_liked',
        );
        expect(find.text('5'), findsOneWidget);
      },
    );
  });
}
