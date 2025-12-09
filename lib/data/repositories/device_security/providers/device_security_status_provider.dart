import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_repository_provider.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_security_status_provider.g.dart';

/// デバイスセキュリティ状態のProvider
@Riverpod(keepAlive: true)
Stream<DeviceSecurityStatus> deviceSecurityStatus(Ref ref) {
  final repository = ref.read(deviceSecurityRepositoryProvider());
  return repository.watch();
}
