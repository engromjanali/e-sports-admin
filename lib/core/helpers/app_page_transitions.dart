import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageTransitions {
  const AppPageTransitions._();

  static Page<dynamic> fade(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    );
  }
}
