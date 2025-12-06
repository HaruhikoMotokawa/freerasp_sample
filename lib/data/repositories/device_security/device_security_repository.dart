import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_sample/data/sources/local/talsec.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_security_repository.part_callback.dart';
part 'device_security_repository.part_talsec_config.dart';

class DeviceSecurityRepository {
  DeviceSecurityRepository(this.ref);
  final Ref ref;

  /// セキュリティ状態のストリームコントローラー
  final _statusController = StreamController<DeviceSecurityStatus>.broadcast();

  /// セキュリティ状態のストリーム
  Stream<DeviceSecurityStatus> get statusStream => _statusController.stream;

  /// リソースの解放
  Future<void> dispose() async {
    await _statusController.close();
  }

  Talsec get _talsec => ref.read(talsecProvider);

  /// 初期化: freeRASP を開始 + コールバックを設定
  Future<void> init() async {
    // チェック中状態を流す
    _statusController.add(const DeviceSecurityStatus.checking());

    // 検査完了時のコールバック登録
    _talsec.attachExecutionStateListener(_createExecutionStateCallback());

    // 脅威検知用コールバックの登録
    await _talsec.attachListener(_createThreatCallback());

    // freeRASP 開始
    await _talsec.start(_TalsecConfig.value);
  }
}
