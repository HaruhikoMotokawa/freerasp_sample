import 'package:freerasp_sample/data/repositories/device_security/providers/device_security_repository_provider.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_security_status_provider.g.dart';

/// デバイスセキュリティ状態のProvider
@Riverpod(keepAlive: true)
class DeviceSecurityStatusNotifier extends _$DeviceSecurityStatusNotifier {
  @override
  Stream<DeviceSecurityStatus> build() {
    final repository = ref.read(deviceSecurityRepositoryProvider);
    return repository.statusStream;
  }

  @override
  bool updateShouldNotify(
    AsyncValue<DeviceSecurityStatus> previous,
    AsyncValue<DeviceSecurityStatus> next,
  ) {
    if (next.hasError || next.isLoading) return false;

    // もし一度でも不正が流れてきてきた場合、次にどんな値が流れてきても通知しない
    if (previous.value case final DeviceSecurityStatusThreat _) {
      return false;
    }

    // 基本は常に通知する
    return true;
  }
}
