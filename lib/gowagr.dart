import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gowagr/core/config/logger_service.dart';
import 'package:gowagr/core/utils/app_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoWagr extends ConsumerStatefulWidget {
  const GoWagr({super.key});

  @override
  ConsumerState<GoWagr> createState() => _GoWagrState();
}

class _GoWagrState extends ConsumerState<GoWagr> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        log.d("App moved to background");
        break;
      case AppLifecycleState.inactive:
        log.d("App is inactive");
        break;
      case AppLifecycleState.detached:
        log.d("App is being terminated");
        break;
      case AppLifecycleState.hidden:
        log.d("App is hidden");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            title: 'GoWagr',
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child ?? const SizedBox(),
              );
            },
          ),
        );
      },
      child: const SizedBox(),
    );
  }
}
