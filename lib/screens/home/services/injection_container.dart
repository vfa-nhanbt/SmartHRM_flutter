import 'package:smarthrm_flutter/screens/home/services/camera_service.dart';
import 'package:smarthrm_flutter/screens/home/services/ml_kit_service.dart';
import 'package:smarthrm_flutter/utils/injection_container.dart';

class HomeInjectionContainer extends InjectionContainer {
  HomeInjectionContainer._internal();

  static final HomeInjectionContainer instance =
      HomeInjectionContainer._internal();

  @override
  Future<void> init() async {
    getIt.registerLazySingleton<CameraService>(
      () => CameraService(),
    );

    getIt.registerLazySingleton<MLKitService>(
      () => MLKitService(),
    );
  }
}
