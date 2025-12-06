part of 'device_security_repository.dart';

/// 脅威の危険度
enum _ThreatLevel {
  /// 危険：アプリをブロック
  block,

  /// 監視：アプリは継続するが、Crashlytics等で集計
  monitor,

  /// 無視：ログも送らない（網羅のために定義）
  ignore,
}

/// 脅威の種類
enum _ThreatType {
  /// 動的フッキング（Frida等）を検知
  hooks(
    '動的フッキング（Frida等）が検出されました',
    level: _ThreatLevel.block,
  ),

  /// デバッガ接続を検知
  debug(
    'デバッガが検出されました',
    level: _ThreatLevel.block,
    ignoreInDebugMode: true,
  ),

  /// パスコード未設定を検知
  passcode(
    '端末にパスコードが設定されていません',
    level: _ThreatLevel.monitor,
  ),

  /// アプリ再インストールを検知（iOS only）
  deviceId(
    'アプリが再インストールされました',
    level: _ThreatLevel.ignore,
  ),

  /// エミュレータ/シミュレータを検知
  simulator(
    'エミュレータ/シミュレータが検出されました',
    level: _ThreatLevel.block,
    ignoreInDebugMode: true,
  ),

  /// アプリ整合性の違反を検知
  appIntegrity(
    'アプリの整合性に問題があります',
    level: _ThreatLevel.block,
  ),

  /// 難読化されていないことを検知
  obfuscationIssues(
    'アプリが難読化されていません',
    level: _ThreatLevel.monitor,
    ignoreInDebugMode: true,
  ),

  /// デバイスバインディング違反を検知
  deviceBinding(
    'デバイスバインディングに違反しています',
    level: _ThreatLevel.block,
  ),

  /// 非公式ストアからのインストールを検知
  unofficialStore(
    '非公式ストアからインストールされました',
    level: _ThreatLevel.block,
    ignoreInDebugMode: true,
  ),

  /// root/Jailbreakを検知
  privilegedAccess(
    'root化/Jailbreakが検出されました',
    level: _ThreatLevel.block,
  ),

  /// セキュアハードウェア未対応を検知
  secureHardwareNotAvailable(
    'セキュアハードウェアが利用できません',
    level: _ThreatLevel.monitor,
  ),

  /// システムVPNを検知
  systemVpn(
    'システムVPNが検出されました',
    level: _ThreatLevel.ignore,
  ),

  /// 開発者モードを検知
  devMode(
    '開発者モードが有効です',
    level: _ThreatLevel.monitor,
    ignoreInDebugMode: true,
  ),

  /// ADBを検知（Android only）
  adbEnabled(
    'ADBが有効です',
    level: _ThreatLevel.monitor,
    ignoreInDebugMode: true,
  ),

  /// マルウェアを検知（Android only）
  malware(
    'マルウェアが検出されました',
    level: _ThreatLevel.block,
  ),

  /// スクリーンショットを検知
  screenshot(
    'スクリーンショットが検出されました',
    level: _ThreatLevel.ignore,
  ),

  /// 画面録画を検知
  screenRecording(
    '画面録画が検出されました',
    level: _ThreatLevel.ignore,
  ),

  /// マルチインスタンスを検知
  multiInstance(
    '複数インスタンスが検出されました',
    level: _ThreatLevel.block,
  ),

  /// 安全でないWiFiを検知
  unsecureWifi(
    '安全でないWiFiが検出されました',
    level: _ThreatLevel.ignore,
  ),

  /// 時刻改ざんを検知
  timeSpoofing(
    '時刻の改ざんが検出されました',
    level: _ThreatLevel.block,
  ),

  /// 位置情報改ざんを検知
  locationSpoofing(
    '位置情報の改ざんが検出されました',
    level: _ThreatLevel.block,
  );

  const _ThreatType(
    this.message, {
    required this.level,
    this.ignoreInDebugMode = false,
  });

  /// ログ出力用のメッセージ
  final String message;

  /// 脅威の危険度
  final _ThreatLevel level;

  /// デバッグモードでは無視するかどうか
  final bool ignoreInDebugMode;
}
