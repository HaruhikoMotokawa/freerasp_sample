import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_sample/core/log/logger.dart';
import 'package:freerasp_sample/data/sources/local/talsec.dart';
import 'package:freerasp_sample/domains/value_object/device_security_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_security_repository.part_app_talsec_config.dart';
part 'device_security_repository.part_callback.dart';
part 'device_security_repository.part_status_stream_controller.dart';
part 'device_security_repository.part_threat_type.dart';

/// 不正端末検知の機能を提供するリポジトリ
///
/// freeRASP (Talsec) の初期化とコールバック設定を行い、
/// 検知された不正端末の状態をストリームで提供する
class DeviceSecurityRepository {
  DeviceSecurityRepository(this.ref);
  final Ref ref;

  /// セキュリティ状態のストリームコントローラー
  final _statusController = _StatusStreamController();

  /// Talsec インスタンス
  Talsec get _talsec => ref.read(talsecProvider);

  /// 設定
  ///
  /// テストで差し込めるようにgetterにしている
  TalsecConfig get config => _TalsecConfig.value;

  /// セキュリティ状態を監視するストリーム
  ///
  /// 購読開始時に現在の状態を即座に流し、以降は状態変化時に通知する
  Stream<DeviceSecurityStatus> watch() => _statusController.watch();

  /// リソースの解放
  Future<void> dispose() async => _statusController.close();

  /// 初期化: freeRASP を開始 + コールバックを設定
  Future<void> init() async {
    // 検査完了時のコールバック登録：安全としみなしてストリームを流す
    _talsec.attachExecutionStateListener(_createExecutionStateCallback());

    // 脅威検知用コールバックの登録：脅威検知時に内容によってストリームを流す
    await _talsec.attachListener(_createThreatCallback());

    // freeRASP 開始
    //
    // 原則は初回にのみ呼び出す。
    // 以後はアプリが生きている限りバックグラウンドで動作し続ける。
    await _talsec.start(config);
  }

  // coverage:ignore-start
  /// デバック用に脅威を検知した想定でストリームに流す
  ///
  /// コールバックを呼び出しているわけではないので注意
  @visibleForTesting
  void simulateThreatDetection(String message) {
    _statusController.addThreat(message);
  }
  // coverage:ignore-end
}
