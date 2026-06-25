// ignore_for_file: lines_longer_than_80_chars

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fonksiyonel_fitness_timer/core/utils/level_badge.dart';
import 'package:fonksiyonel_fitness_timer/features/community/domain/entities/workout_share_entity.dart';
import 'package:fonksiyonel_fitness_timer/features/community/domain/entities/comment_entity.dart';
import 'package:fonksiyonel_fitness_timer/features/profile/domain/entities/user_profile_entity.dart';
import 'package:fonksiyonel_fitness_timer/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fonksiyonel_fitness_timer/features/profile/presentation/bloc/profile_event.dart';
import 'package:fonksiyonel_fitness_timer/features/profile/presentation/bloc/profile_state.dart';
import 'package:fonksiyonel_fitness_timer/features/profile/presentation/widgets/profile_header_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MOCK SINIFLAR
// ─────────────────────────────────────────────────────────────────────────────

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

// ─────────────────────────────────────────────────────────────────────────────
// TEST SABİTLERİ
// ─────────────────────────────────────────────────────────────────────────────

/// Level 14 — Beginner kademesi (6–15 arası).
/// LevelBadgeX.fromLevel(14) → LevelBadge.beginner → yeşil renk, madalya ikonu.
const _kTestLevel = 14;
const _kTestBio = 'Her antrenman bir adım ileri.';
const _kTestName = 'Erman Demir';

/// Test profil entity'si — bio dolu, favori hareket belirtilmiş.
const tUserProfile = UserProfileEntity(
  id: 'test-user-id-abcdef12',
  name: _kTestName,
  bio: _kTestBio,
  favoriteMove: 'Muscle-Up',
  totalWorkouts: 47,
  totalLikes: 132,
  totalComments: 28,
);

/// Tüm alanlarla doldurulmuş ProfileLoaded state.
const tProfileLoaded = ProfileLoaded(
  userProfile: tUserProfile,
  sharedWorkouts: <WorkoutShareEntity>[],
  userComments: <CommentEntity>[],
  likedWorkouts: <WorkoutShareEntity>[],
);

// ─────────────────────────────────────────────────────────────────────────────
// YARDIMCI — Widget Pump
// ─────────────────────────────────────────────────────────────────────────────

/// ProfileHeaderWidget, `BlocProvider<ProfileBloc>` gerektirir.
/// Bu sarmalayıcı test ortamında gerekli sağlayıcıyı enjekte eder.
Widget buildProfileHeader({
  required MockProfileBloc bloc,
  UserProfileEntity? profile,
  ProfileLoaded? profileState,
  int level = _kTestLevel,
}) {
  final resolvedProfile = profile ?? tUserProfile;
  final resolvedState = profileState ?? tProfileLoaded;

  return MaterialApp(
    // Google Fonts ağ isteği yapmaz — sadece sistem fontu kullanır
    home: Scaffold(
      body: SingleChildScrollView(
        child: BlocProvider<ProfileBloc>.value(
          value: bloc,
          child: ProfileHeaderWidget(
            profile: resolvedProfile,
            profileState: resolvedState,
            currentLevel: level,
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockProfileBloc mockProfileBloc;

  // Google Fonts'un ağ isteği yapmaması için override.
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    // Varsayılan state: ProfileLoaded
    when(() => mockProfileBloc.state).thenReturn(tProfileLoaded);
  });

  tearDown(() {
    mockProfileBloc.close();
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 1: SEVIYE ROZETİ — BEGINNER (Level 14)
  // ───────────────────────────────────────────────────────────────────────────

  group('ProfileHeader — 1. Seviye Rozeti Render (Level 14 · Beginner)', () {
    // GIVEN: Level 14 Beginner kullanıcı.
    // WHEN: ProfileHeaderWidget render edilir.
    // THEN: 'Seviye 14' metni ekranda görünmeli.
    testWidgets(
      'GIVEN level=14 / WHEN render / THEN "Seviye 14" metni görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN — _LevelSection RichText kullanır; TextSpan içeriğini arar.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('Seviye 14'),
          ),
          findsOneWidget,
        );
      },
    );

    // GIVEN: Level 14 — LevelBadgeX.fromLevel(14) → beginner → label 'Beginner'.
    // WHEN: ProfileHeaderWidget render edilir.
    // THEN: 'Beginner' etiketi ekranda görünmeli.
    testWidgets(
      'GIVEN level=14 / WHEN render / THEN "Beginner" tier etiketi görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN — tier etiketi doğrulanıyor
        final badge = LevelBadgeX.fromLevel(14);
        expect(badge, equals(LevelBadge.beginner));
        expect(badge.label, equals('Beginner'));
        // _LevelSection RichText kullanır; TextSpan içeriğini predicate ile bul.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('Beginner'),
          ),
          findsOneWidget,
        );
      },
    );

    // GIVEN: Beginner rozeti → renk 0xFF4CAF50 (Canlı Yeşil).
    // WHEN: LevelBadgeX.fromLevel(14) çağrılır.
    // THEN: badge.color yeşil olmalı.
    test(
      'GIVEN level=14 / WHEN LevelBadgeX.fromLevel / THEN renk yeşil olmalı',
      () {
        // GIVEN & WHEN
        final badge = LevelBadgeX.fromLevel(14);

        // THEN
        expect(badge, equals(LevelBadge.beginner));
        expect(badge.color, equals(const Color(0xFF4CAF50)));
      },
    );

    // GIVEN: Beginner rozeti.
    // WHEN: badge.icon okunur.
    // THEN: Icons.emoji_events_outlined (madalya) olmalı.
    test(
      'GIVEN beginner badge / WHEN icon okunur / THEN madalya ikonu olmalı',
      () {
        // GIVEN & WHEN
        final badge = LevelBadgeX.fromLevel(14);

        // THEN
        expect(badge.icon, equals(Icons.emoji_events_outlined));
      },
    );

    // GIVEN: Level 1 kullanıcı (Rookie).
    // WHEN: render edilir.
    // THEN: 'Rookie' etiketi görünmeli.
    testWidgets(
      'GIVEN level=1 (Rookie) / WHEN render / THEN "Rookie" etiketi görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(
          buildProfileHeader(bloc: mockProfileBloc, level: 1),
        );
        await tester.pumpAndSettle();

        // THEN
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('Rookie'),
          ),
          findsOneWidget,
        );
      },
    );

    // GIVEN: Level 61 kullanıcı (Elite).
    // WHEN: render edilir.
    // THEN: 'Elite' etiketi görünmeli.
    testWidgets(
      'GIVEN level=61 (Elite) / WHEN render / THEN "Elite" etiketi görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(
          buildProfileHeader(bloc: mockProfileBloc, level: 61),
        );
        await tester.pumpAndSettle();

        // THEN
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('Elite'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 2: BİYOGRAFİ VE KULLANICI BİLGİSİ
  // ───────────────────────────────────────────────────────────────────────────

  group('ProfileHeader — 2. Biyografi ve Kullanıcı Bilgisi', () {
    // GIVEN: Bio dolu profil ('Her antrenman bir adım ileri.').
    // WHEN: render edilir.
    // THEN: Bio metni ekranda tırnak içinde görünmeli.
    testWidgets(
      'GIVEN bio dolu profil / WHEN render / THEN bio tırnak içinde görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN — _BioSection tırnak ekler: '"Bio metni"'
        expect(find.textContaining(_kTestBio), findsOneWidget);
      },
    );

    // GIVEN: Kullanıcı adı 'Erman Demir'.
    // WHEN: render edilir.
    // THEN: Ad büyük font ile görünmeli.
    testWidgets(
      'GIVEN name dolu profil / WHEN render / THEN kullanıcı adı görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN
        expect(find.text(_kTestName), findsOneWidget);
      },
    );

    // GIVEN: Bio null olan profil.
    // WHEN: render edilir.
    // THEN: Bio metni ekranda görünmemeli.
    testWidgets(
      'GIVEN bio null profil / WHEN render / THEN bio metni görünmemeli',
      (tester) async {
        // GIVEN — bio null
        const profileNoBio = UserProfileEntity(
          id: 'test-user-id-abcdef12',
          name: _kTestName,
        );
        const stateNoBio = ProfileLoaded(
          userProfile: profileNoBio,
          sharedWorkouts: [],
          userComments: [],
          likedWorkouts: [],
        );
        when(() => mockProfileBloc.state).thenReturn(stateNoBio);

        await tester.pumpWidget(
          buildProfileHeader(
            bloc: mockProfileBloc,
            profile: profileNoBio,
            profileState: stateNoBio,
          ),
        );
        await tester.pumpAndSettle();

        // THEN — bio bölümü yok
        expect(find.textContaining(_kTestBio), findsNothing);
      },
    );

    // GIVEN: Favori hareket 'Muscle-Up' olan profil.
    // WHEN: render edilir.
    // THEN: 'Muscle-Up' metni ekranda görünmeli.
    testWidgets(
      'GIVEN favori hareket dolu / WHEN render / THEN "Muscle-Up" görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN
        expect(find.text('Muscle-Up'), findsOneWidget);
      },
    );

    // GIVEN: Name null profil.
    // WHEN: render edilir.
    // THEN: 'İsimsiz Sporcu' placeholder görünmeli.
    testWidgets(
      'GIVEN name null / WHEN render / THEN "İsimsiz Sporcu" görünmeli',
      (tester) async {
        // GIVEN
        const profileNoName = UserProfileEntity(id: 'test-user-id-abcdef12');
        const stateNoName = ProfileLoaded(
          userProfile: profileNoName,
          sharedWorkouts: [],
          userComments: [],
          likedWorkouts: [],
        );
        when(() => mockProfileBloc.state).thenReturn(stateNoName);

        await tester.pumpWidget(
          buildProfileHeader(
            bloc: mockProfileBloc,
            profile: profileNoName,
            profileState: stateNoName,
          ),
        );
        await tester.pumpAndSettle();

        // THEN
        expect(find.text('İsimsiz Sporcu'), findsOneWidget);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 3: PROFİL DÜZENLE — BOTTOM SHEET
  // ───────────────────────────────────────────────────────────────────────────

  group('ProfileHeader — 3. "Profil Düzenle" BottomSheet', () {
    // GIVEN: ProfileHeaderWidget render edilmiş.
    // WHEN: Düzenle ikonu (Icons.edit_outlined) tıklanır.
    // THEN: BottomSheet ekranda belirmeli ve 'Profili Düzenle' başlığı görünmeli.
    testWidgets(
      'GIVEN profil header render / WHEN edit ikona tıkla / THEN BottomSheet açılmalı',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // Düzenle ikonu ekranda mı?
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

        // WHEN — düzenle ikonuna tıkla
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // THEN — BottomSheet 'Profili Düzenle' başlığı ile açıldı
        expect(find.text('Profili Düzenle'), findsOneWidget);
      },
    );

    // GIVEN: BottomSheet açık.
    // WHEN: BottomSheet render edildi.
    // THEN: 'Kısa Biyografi' ve 'Favori Hareket' TextField'ları görünmeli.
    testWidgets(
      'GIVEN BottomSheet açık / WHEN render / THEN Bio ve FavoriteMove alanları görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // WHEN — sheet aç
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // THEN — form alanları görünmeli
        expect(find.text('Kısa Biyografi'), findsOneWidget);
        expect(find.text('Favori Hareket'), findsOneWidget);
      },
    );

    // GIVEN: BottomSheet açık.
    // WHEN: Mevcut bio değeri var.
    // THEN: Bio TextField başlangıçta mevcut bio metniyle dolu olmalı.
    testWidgets(
      'GIVEN mevcut bio var / WHEN BottomSheet açılır / THEN bio field dolu olmalı',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // WHEN — sheet aç
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // THEN — Bio TextField mevcut değer ile dolmuş
        // TextField'ları bul ve içerik kontrolü yap
        final bioField = find.widgetWithText(TextField, _kTestBio);
        expect(bioField, findsOneWidget);
      },
    );

    // GIVEN: BottomSheet açık.
    // WHEN: 'Kaydet' butonuna tıklanır.
    // THEN: BottomSheet kapanmalı (artık ekranda 'Profili Düzenle' görünmemeli).
    testWidgets(
      'GIVEN BottomSheet açık / WHEN Kaydet tıklanır / THEN sheet kapanmalı',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Profili Düzenle'), findsOneWidget);

        // WHEN — 'Kaydet' butonuna tıkla
        await tester.tap(find.text('Kaydet'));
        await tester.pumpAndSettle();

        // THEN — sheet kapandı
        expect(find.text('Profili Düzenle'), findsNothing);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 4: İSTATİSTİK SATIRI
  // ───────────────────────────────────────────────────────────────────────────

  group('ProfileHeader — 4. İstatistik Satırı', () {
    // GIVEN: 47 antrenman, 132 beğeni, 28 yorum değerli profil.
    // WHEN: render edilir.
    // THEN: İstatistik etiketleri ekranda görünmeli.
    testWidgets(
      'GIVEN profil istatistikleri / WHEN render / THEN Antrenman/Beğeni/Yorum etiketleri görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN
        expect(find.text('Antrenman'), findsOneWidget);
        expect(find.text('Beğeni'), findsOneWidget);
        expect(find.text('Yorum'), findsOneWidget);
      },
    );

    // GIVEN: totalWorkouts=47.
    // WHEN: render edilir.
    // THEN: '47' değeri ekranda görünmeli.
    testWidgets(
      'GIVEN totalWorkouts=47 / WHEN render / THEN "47" değeri görünmeli',
      (tester) async {
        // GIVEN
        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN
        expect(find.text('47'), findsOneWidget);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 5: AVATAR YÜKLEME DURUMU
  // ───────────────────────────────────────────────────────────────────────────

  group('ProfileHeader — 5. Avatar Yükleme Durumu', () {
    // GIVEN: BLoC AvatarUploading state'inde.
    // WHEN: ProfileHeaderWidget render edilir.
    // THEN: Dönen CircularProgressIndicator görünmeli (yükleme göstergesi).
    testWidgets(
      'GIVEN AvatarUploading state / WHEN render / THEN CircularProgressIndicator görünmeli',
      (tester) async {
        // GIVEN — yükleme state'i
        when(
          () => mockProfileBloc.state,
        ).thenReturn(const AvatarUploading(tProfileLoaded));

        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pump(); // Senkron frame

        // THEN
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    // GIVEN: BLoC ProfileLoaded state'inde, avatar URL yok.
    // WHEN: render edilir.
    // THEN: person ikonu (placeholder avatar) görünmeli.
    testWidgets(
      'GIVEN avatarUrl=null / WHEN render / THEN default person ikonu görünmeli',
      (tester) async {
        // GIVEN
        when(() => mockProfileBloc.state).thenReturn(tProfileLoaded);

        await tester.pumpWidget(buildProfileHeader(bloc: mockProfileBloc));
        await tester.pumpAndSettle();

        // THEN — person ikonu var (default avatar)
        expect(find.byIcon(Icons.person), findsOneWidget);
      },
    );
  });
}
