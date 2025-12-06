part of 'device_security_repository.dart';

/// デバイスセキュリティRepositoryの設定
abstract final class _TalsecConfig {
  /// 共通設定
  static final value = TalsecConfig(
    watcherMail: _watcherMail,
    androidConfig: _androidConfig,
    iosConfig: _iosConfig,
    // 💡 不正を検知した際にアプリを強制終了する場合は有効化
    // killOnBypass: true,
  );

  /// Talsec ポータル向けメール（任意）
  static const String _watcherMail = 'your_mail@example.com';

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
}
