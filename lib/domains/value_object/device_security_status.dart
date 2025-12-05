import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_security_status.freezed.dart';

/// デバイスセキュリティの状態
@freezed
sealed class DeviceSecurityStatus with _$DeviceSecurityStatus {
  /// チェック中
  const factory DeviceSecurityStatus.checking() = DeviceSecurityStatusChecking;

  /// チェック完了で安全
  const factory DeviceSecurityStatus.safe() = DeviceSecurityStatusSafe;

  /// 不正端末
  const factory DeviceSecurityStatus.threat({
    required String message,
  }) = DeviceSecurityStatusThreat;
}
