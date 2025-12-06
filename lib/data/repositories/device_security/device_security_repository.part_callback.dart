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
      onHooks: () => _handleThreat(_ThreatType.hooks),
      onDebug: () => _handleThreat(_ThreatType.debug),
      onPasscode: () => _handleThreat(_ThreatType.passcode),
      onDeviceID: () => _handleThreat(_ThreatType.deviceId),
      onSimulator: () => _handleThreat(_ThreatType.simulator),
      onAppIntegrity: () => _handleThreat(_ThreatType.appIntegrity),
      onObfuscationIssues: () => _handleThreat(_ThreatType.obfuscationIssues),
      onDeviceBinding: () => _handleThreat(_ThreatType.deviceBinding),
      onUnofficialStore: () => _handleThreat(_ThreatType.unofficialStore),
      onPrivilegedAccess: () => _handleThreat(_ThreatType.privilegedAccess),
      onSecureHardwareNotAvailable: () =>
          _handleThreat(_ThreatType.secureHardwareNotAvailable),
      onSystemVPN: () => _handleThreat(_ThreatType.systemVpn),
      onDevMode: () => _handleThreat(_ThreatType.devMode),
      onADBEnabled: () => _handleThreat(_ThreatType.adbEnabled),
      onMalware: (info) => _handleThreat(_ThreatType.malware),
      onScreenshot: () => _handleThreat(_ThreatType.screenshot),
      onScreenRecording: () => _handleThreat(_ThreatType.screenRecording),
      onMultiInstance: () => _handleThreat(_ThreatType.multiInstance),
      onUnsecureWiFi: () => _handleThreat(_ThreatType.unsecureWifi),
      onTimeSpoofing: () => _handleThreat(_ThreatType.timeSpoofing),
      onLocationSpoofing: () => _handleThreat(_ThreatType.locationSpoofing),
    );
  }

  /// 脅威検知時の共通処理
  void _handleThreat(_ThreatType type) {
    // デバッグモードで無視する設定の場合
    if (kDebugMode && type.ignoreInDebugMode) {
      logger.d('${type.message}（デバッグモードでは無視）');
      return;
    }

    // 危険度に応じた処理
    switch (type.level) {
      case _ThreatLevel.block:
        // アプリをブロック
        logger.w('セキュリティ脅威: ${type.message}');
        // （例）FirebaseCrashlytics.instance.recordError(...);

        // 脅威検知状態を流す
        _statusController
            .add(DeviceSecurityStatus.threat(message: type.message));

      case _ThreatLevel.monitor:
        // Crashlytics等に送信（アプリは継続）
        logger.i('セキュリティ監視: ${type.message}');
      // （例）FirebaseCrashlytics.instance.recordError(...);

      case _ThreatLevel.ignore:
        // 何もしない（網羅のために定義）
        break;
    }
  }
}
