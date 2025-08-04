import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gowagr/presentation/event_screen.dart';

class Routes {
  static const eventDash = 'eventDash';
}

class AppRouter {
  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  static getPage({
    required BuildContext context,
    required Widget child,
    required GoRouterState state,
    Duration? transitionDuration,
    Duration? reverseDuration,
  }) {
    return buildPageWithDefaultTransition(
      context: context,
      state: state,
      child: child,
      transitionDuration: transitionDuration,
      reverseDuration: reverseDuration,
    );
  }

  static Page<void> getNativePage({
    required BuildContext context,
    required Widget child,
    required GoRouterState state,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoPage<void>(
        child: child,
        key: state.pageKey,
        name: state.name,
      );
    } else {
      return MaterialPage<void>(
        child: child,
        key: state.pageKey,
        name: state.name,
      );
    }
  }

  static Page<void> buildPageWithDefaultTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration? transitionDuration,
    Duration? reverseDuration,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CustomTransitionPage(
        child: child,
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return CupertinoPageRoute(
            builder: (context) => child,
          ).buildTransitions(
            context,
            animation,
            secondaryAnimation,
            child,
          );
        },
        transitionDuration:
            transitionDuration ?? const Duration(milliseconds: 300),
        reverseTransitionDuration:
            reverseDuration ?? const Duration(milliseconds: 300),
      );
    } else {
      return CustomTransitionPage(
        child: child,
        key: state.pageKey,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return MaterialPageRoute(
            builder: (context) => child,
          ).buildTransitions(
            context,
            animation,
            secondaryAnimation,
            child,
          );
        },
        transitionDuration:
            transitionDuration ?? const Duration(milliseconds: 300),
        reverseTransitionDuration:
            reverseDuration ?? const Duration(milliseconds: 300),
      );
    }
  }

  static getPlatformPage({
    required Widget child,
    required BuildContext context,
  }) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(
        builder: (context) => child,
      );
    } else {
      return CupertinoPageRoute(
        builder: (context) => child,
      );
    }
  }

  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: Routes.eventDash.path,
    routes: routes,
    navigatorKey: parentNavigatorKey,
    errorPageBuilder: (context, state) {
      return getNativePage(
        context: context,
        state: state,
        child: const EventScreen(),
      );
    },
  );

  static String get currentRoute {
    final RouteMatch lastMatch =
        AppRouter.router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : AppRouter.router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  static String get currentName => currentRoute.name;

  static final routes = <GoRoute>[
    GoRoute(
      name: Routes.eventDash,
      path: Routes.eventDash.path,
      pageBuilder: (context, state) {
        return getNativePage(
          context: context,
          state: state,
          child: const EventScreen(),
        );
      },
    ),
  ];
}

extension PathString on String {
  String get path => startsWith('/') ? this : '/$this';
  String get name => split('/').last;
}

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    transitionDuration: const Duration(milliseconds: 300),
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      key: state.pageKey,
      child: child,
    ),
  );
}
