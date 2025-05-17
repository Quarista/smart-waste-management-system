import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page buildMotionPage({
  required Widget child,
  String? name,
  double elevation = 10,
  double intensity = 0.3,
}) {
  return CustomTransitionPage(
    key: ValueKey(name ?? ''),
    child: child,
    transitionDuration: Duration(milliseconds: !(name == null) ? 300 : 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return name == 'AppLaunch'
          ? FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            )
          : name == 'FadeUp'
              ? FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                )
              : name == 'FadeDown'
                  ? FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    )
                  : name == 'FadeScale'
                      ? FadeScaleTransition(
                          animation: animation,
                          child: child,
                        )
                      : FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.5, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            )),
                            child: child,
                          ),
                        );
    },
  );
}
