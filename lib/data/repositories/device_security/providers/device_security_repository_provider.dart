import 'package:freerasp_sample/data/repositories/device_security/device_security_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_security_repository_provider.g.dart';

/// DeviceSecurityRepositoryのProvider（keepAlive）
@Riverpod(keepAlive: true)
DeviceSecurityRepository deviceSecurityRepository(Ref ref) {
  final repository = DeviceSecurityRepository(ref);
  ref.onDispose(repository.dispose);
  return repository;
}
