part of 'device_security_repository.dart';

extension _CallbackExtension on DeviceSecurityRepository {
  /// 実行状態のコールバックを生成
  RaspExecutionStateCallback _createExecutionStateCallback() {
    return RaspExecutionStateCallback(
      onAllChecksDone: () {
        // 検査完了時点で脅威が検出されていなければ安全
        _statusController.add(const DeviceSecurityStatus.safe());
      },
    );
  }

  /// 脅威検知用コールバックを生成
  ThreatCallback _createThreatCallback() {
    return ThreatCallback(
      onAppIntegrity: () => _onThreatDetected('App integrity compromised'),
      onDebug: () => _onDebugModeOnly('Debugger detected'),
      onPrivilegedAccess: () =>
          _onThreatDetected('Privileged access (root/jailbreak) detected'),
      onSimulator: () => _onThreatDetected('Simulator/Emulator detected'),
      onUnofficialStore: () => _onDebugModeOnly('Unofficial store detected'),
      onHooks: () => _onThreatDetected('Hooks detected'),
      onDeviceBinding: () => _onThreatDetected('Device binding violation'),
      onSecureHardwareNotAvailable: () =>
          _onThreatDetected('Secure hardware not available'),
      onSystemVPN: () => _onThreatDetected('System VPN detected'),
      onDevMode: () => _onDebugModeOnly('Developer mode enabled'),
    );
  }

  /// 脅威検知時の処理
  void _onThreatDetected(String message) {
    log('⚠️ Security threat: $message');
    _statusController.add(DeviceSecurityStatus.threat(message: message));
  }

  /// デバッグモードでは無視、リリースモードでは脅威として扱う
  void _onDebugModeOnly(String message) {
    if (kDebugMode) {
      log('🔧 $message (ignored in debug mode)');
      return;
    }
    _onThreatDetected(message);
  }
}
