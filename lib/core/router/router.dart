import 'package:flutter/material.dart';
import 'package:freerasp_sample/presentations/screens/home/screen.dart';
import 'package:freerasp_sample/presentations/screens/login/screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => _goRouter;

final _goRouter = GoRouter(
  // アプリが起動した時
  initialLocation: LoginScreen.path,
  // パスと画面の組み合わせ
  routes: [
    GoRoute(
      path: LoginScreen.path,
      name: LoginScreen.name,
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(),
        );
      },
    ),
    GoRoute(
      path: HomeScreen.path,
      name: HomeScreen.name,
      pageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        );
      },
    ),
  ],
  // 遷移ページがないなどのエラーが発生した時に、このページに行く
  errorPageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: Scaffold(
      body: Center(
        child: Text(state.error.toString()),
      ),
    ),
  ),
);
