# freeRASP Sample

> [!NOTE]
> このプロジェクトのFlutterSDKは **3.35.4** です。

## 概要

このプロジェクトは [freeRASP](https://pub.dev/packages/freerasp) を使用したFlutterアプリのセキュリティ実装サンプルです。

freeRASPは、Runtime Application Self-Protection（RASP）を提供するライブラリで、以下のような脅威を検出できます：

- 🔓 Root化/Jailbreak検出
- 🖥️ エミュレータ/シミュレータ検出
- 🐛 デバッガ接続検出
- 🪝 フッキング（Frida等）検出
- 📝 アプリ改ざん検出
- 🏪 非公式ストアからのインストール検出
- 🔑 パスコード未設定検出
- その他多数...

## 機能

### セキュリティチェック画面
アプリ起動時にfreeRASPによるセキュリティチェックを実行し、結果を表示します。

### 脅威検知時の自動対応
脅威が検知された場合、自動的にログイン画面に戻り、機密データへのアクセスを防ぎます。

### 脅威シミュレーション（デバッグ用）
ホーム画面のFABボタンで脅威検知をシミュレートできます。

## セットアップ

### 1. 依存関係のインストール
```bash
flutter pub get
```

### 2. コード生成
```bash
dart run build_runner build --delete-conflicting-outputs
```
または
```bash
derry build_runner
```

### 3. 設定の変更
`lib/data/repositories/device_security/device_security_repository.part_app_talsec_config.dart` を編集し、以下を設定してください：

- `watcherMail`: Talsecポータル向けのメールアドレス
- `packageName`: Androidのパッケージ名
- `signingCertHashes`: 署名証明書のハッシュ
- `bundleIds`: iOSのBundle ID
- `teamId`: Apple Developer Team ID

## 使用技術

- **freeRASP**: セキュリティ脅威検出
- **Riverpod**: 状態管理
- **Freezed**: イミュータブルクラス生成
- **go_router**: 画面遷移

## アーキテクチャ

RiverpodArchitectureを基本としています。

[Flutter App Architecture with Riverpod: An Introduction](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)

### 主要なディレクトリ構造

```
lib
├── core
│   ├── constants/        # 定数
│   ├── log/              # ロガー
│   └── router/           # ルーティング
├── data
│   ├── repositories/
│   │   └── device_security/  # freeRASP関連のリポジトリ
│   └── sources/
│       └── local/        # Talsecインスタンス
├── domains
│   └── value_object/     # DeviceSecurityStatus等
├── main
│   ├── app_startup/      # アプリ起動時の初期化
│   └── main_app/         # メインアプリ
└── presentations
    ├── screens/
    │   ├── home/         # ホーム画面
    │   └── login/        # ログイン（セキュリティチェック）画面
    └── theme/            # テーマ
```

## 参考リンク

- [freeRASP - pub.dev](https://pub.dev/packages/freerasp)
- [freeRASP - GitHub](https://github.com/AcuteaElf/Free-RASP-Flutter)
- [Talsec Security](https://www.talsec.app/)
