import 'package:go_router/go_router.dart';
import 'package:term_project/view/home.dart';
import 'package:term_project/view/profile.dart';
import 'package:term_project/view/list.dart';
import 'package:term_project/view/item_detail.dart';
import 'package:term_project/view/login_page.dart';
import 'package:term_project/view/result_page.dart';
import 'package:term_project/view/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:term_project/services/providers/refresh_provider.dart';
import 'package:term_project/src/features/chat/screens/chat_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
      routes: <RouteBase>[
        GoRoute(
          path: 'main',
          builder: (context, state) => const MainScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'profile',
              builder: (context, state) {
                final refreshCallback = Provider.of<RefreshProvider>(context, listen: false).refreshCallback;
                return ProfileScreen(refreshCallback: refreshCallback!);
              },
            ),
            GoRoute(
              path: 'list',
              builder: (context, state) => const ListScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'result',
                  builder: (context, state) => const DisplayPhotoPage(),
                ),
                GoRoute(
                  path: ':itemId',
                  builder: (context, state) => ItemDetailScreen(itemId: state.pathParameters['itemId']!, ),
                ),
              ],
            ),
            GoRoute(
              path: 'ai',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
