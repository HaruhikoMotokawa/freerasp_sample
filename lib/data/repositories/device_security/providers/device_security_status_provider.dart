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

  // チェック対象が不正端末だった場合チェックが始まると、
  // 異常系の状態が次々に流れてくる可能性がある。
  // そして最後にチェック完了が流れてくる。
  //
  // 便宜上、チェック完了 == 安全 としている。
  //
  // この順番の都合上、一度でも不正端末の状態が流れてきた場合は、
  // それ以降は状態が変わっても通知しないようにする。
  //
  // また、検知される不正の種類は一つとは限らないため、検知されたことはその都度ログを
  // 残すが、UIの状態は最初に検知されたものを維持するようにする。
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
