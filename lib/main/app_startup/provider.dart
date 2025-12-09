import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  // DBの初期化など、他の初期化処理があればここに追加

  // ...

  // freeRASPの初期化
  final deviceSecurityRepository = ref.read(deviceSecurityRepositoryProvider());
  await deviceSecurityRepository.init();
}
