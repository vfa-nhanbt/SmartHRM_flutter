import 'camera_service.dart';
import '../../../utils/injection_container.dart';
import 'ml_kit_services.dart';

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
