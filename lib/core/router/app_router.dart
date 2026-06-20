import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/exam_result.dart';
import '../../data/models/topic.dart';
import '../../data/repositories/progress_repository.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/exam/exam_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/achievements/achievements_screen.dart';
import '../../features/daily/daily_question_screen.dart';
import '../../features/flashcards/flashcards_screen.dart';
import '../../features/guide/guide_screens.dart';
import '../../features/listen/listen_mode_screen.dart';
import '../../features/practice/practice_screen.dart';
import '../../features/practice/weak_points_screen.dart';
import '../../features/practice/year_practice_screen.dart';
import '../../features/practice/years_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/result/review_screen.dart';
import '../../features/review/favorites_screen.dart';
import '../../features/review/wrong_answers_screen.dart';
import '../../features/signs/signs_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/topics/topic_detail_screen.dart';
import '../../features/topics/topics_screen.dart';
import 'main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootKey,
  redirect: (context, state) {
    final done = ProgressRepository().onboardingDone();
    final atOnboarding = state.matchedLocation == '/onboarding';
    if (!done && !atOnboarding) return '/onboarding';
    if (done && atOnboarding) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const OnboardingScreen(),
    ),
    // Alt navigasyon barlı ana kabuk
    StatefulShellRoute.indexedStack(
      builder: (c, s, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/signs', builder: (c, s) => const SignsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/topics',
            builder: (c, s) => const TopicsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (c, s) {
                  final topic = s.extra;
                  if (topic is! Topic) return const TopicsScreen();
                  return TopicDetailScreen(topic: topic);
                },
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/stats', builder: (c, s) => const StatsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ]),
      ],
    ),

    // Tam ekran rotalar (alt bar olmadan, kök navigatöre push edilir)
    GoRoute(
      path: '/exam',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const ExamScreen(),
    ),
    GoRoute(
      path: '/result',
      parentNavigatorKey: _rootKey,
      builder: (c, s) {
        final result = s.extra;
        if (result is! ExamResult) return const HomeScreen();
        return ResultScreen(result: result);
      },
    ),
    GoRoute(
      path: '/review',
      parentNavigatorKey: _rootKey,
      builder: (c, s) {
        final result = s.extra;
        if (result is! ExamResult) return const HomeScreen();
        return ReviewScreen(result: result);
      },
    ),
    GoRoute(
      path: '/practice/:category',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => PracticeScreen(category: s.pathParameters['category']!),
    ),
    GoRoute(
      path: '/years',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const YearsScreen(),
    ),
    GoRoute(
      path: '/years/:year',
      parentNavigatorKey: _rootKey,
      builder: (c, s) {
        final year = int.tryParse(s.pathParameters['year'] ?? '');
        if (year == null) return const YearsScreen();
        return YearPracticeScreen(year: year);
      },
    ),
    GoRoute(
      path: '/wrong',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const WrongAnswersScreen(),
    ),
    GoRoute(
      path: '/weak',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const WeakPointsScreen(),
    ),
    GoRoute(
      path: '/favorites',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/achievements',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const AchievementsScreen(),
    ),
    GoRoute(
      path: '/listen',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const ListenModeScreen(),
    ),
    GoRoute(
      path: '/flashcards',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const FlashcardsScreen(),
    ),
    GoRoute(
      path: '/guide',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const GuideHubScreen(),
    ),
    GoRoute(
      path: '/daily',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const DailyQuestionScreen(),
    ),
  ],
);
