import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_sample/data/sources/local/talsec.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class DeviceSecurityRepository {
  DeviceSecurityRepository(this.ref);
  final Ref ref;

  /// セキュリティ状態のストリームコントローラー
  final _statusController = StreamController<DeviceSecurityStatus>.broadcast();

  /// セキュリティ状態のストリーム
  Stream<DeviceSecurityStatus> get statusStream => _statusController.stream;

  /// Android設定
  static final _androidConfig = AndroidConfig(
    packageName: 'com.base.sample.app.base_sample',
    // デバッグ証明書のBase64-SHA256ハッシュ
    signingCertHashes: [
      'tgjD7tTWEyd0juKHzWS6/Hf00Sl0hdPHSJ69Mm+LSOc=',
    ],
    supportedStores: [],
  );

  /// iOS設定
  static final _iosConfig = IOSConfig(
    // iOS 向けなら実際の Bundle ID
    bundleIds: ['your.bundle.id'],
    // iOS 向けならあなたの Team ID
    teamId: 'YOUR_APPLE_TEAM_ID',
  );

  /// 共通設定
  static final _talsecConfig = TalsecConfig(
    watcherMail: _watcherMail,
    androidConfig: _androidConfig,
    iosConfig: _iosConfig,
    // 不正を検知した際にアプリを強制終了する場合は有効化
    // killOnBypass: true,
  );

  /// Talsec ポータル向けメール（任意）
  static const String _watcherMail = 'your_mail@example.com';

  Talsec get _talsec => ref.read(talsecProvider);

  /// 初期化: freeRASP を開始 + コールバックを設定
  Future<void> init() async {
    // チェック中状態を流す
    _statusController.add(const DeviceSecurityStatus.checking());

    // 実行状態のコールバックを登録（onAllChecksDoneで初期検査完了を検知）
    final executionStateCallback = RaspExecutionStateCallback(
      onAllChecksDone: () {
        // 検査完了時点で脅威が検出されていなければ安全
        _statusController.add(const DeviceSecurityStatus.safe());
      },
    );
    _talsec.attachExecutionStateListener(executionStateCallback);

    // 脅威検知用コールバックの登録
    final callback = ThreatCallback(
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
    await _talsec.attachListener(callback);

    // freeRASP 開始
    await _talsec.start(_talsecConfig);
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

  /// リソースの解放
  Future<void> dispose() async {
    await _statusController.close();
  }
}
