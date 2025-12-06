import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_sample/core/log/logger.dart';
import 'package:freerasp_sample/data/sources/local/talsec.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_security_repository.part_app_talsec_config.dart';
part 'device_security_repository.part_callback.dart';
part 'device_security_repository.part_threat_type.dart';

class DeviceSecurityRepository {
  DeviceSecurityRepository(this.ref);
  final Ref ref;

  /// セキュリティ状態のストリームコントローラー
  final _statusController = StreamController<DeviceSecurityStatus>.broadcast();

  /// セキュリティ状態のストリーム
  Stream<DeviceSecurityStatus> get statusStream => _statusController.stream;

  /// 設定
  ///
  /// テストで差し込めるようにgetterにしている
  TalsecConfig get config => _TalsecConfig.value;

  /// リソースの解放
  Future<void> dispose() async {
    await _statusController.close();
  }

  /// Talsec インスタンス
  Talsec get _talsec => ref.read(talsecProvider);

  /// 初期化: freeRASP を開始 + コールバックを設定
  Future<void> init() async {
    // チェック中状態を流す
    _statusController.add(const DeviceSecurityStatus.checking());

    // 検査完了時のコールバック登録：安全としみなしてストリームを流す
    _talsec.attachExecutionStateListener(_createExecutionStateCallback());

    // 脅威検知用コールバックの登録：脅威検知時に内容によってストリームを流す
    await _talsec.attachListener(_createThreatCallback());

    // freeRASP 開始
    await _talsec.start(config);
  }
}
