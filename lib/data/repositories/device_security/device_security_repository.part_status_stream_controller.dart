part of 'device_security_repository.dart';

/// 現在の値を保持するStreamController
class _StatusStreamController {
  /// 現在の値（初期値は checking）
  DeviceSecurityStatus _value = const DeviceSecurityStatus.checking();

  final _controller = StreamController<DeviceSecurityStatus>.broadcast();

  /// 現在の値
  DeviceSecurityStatus get value => _value;

  /// 安全な状態かどうか（脅威が検出されていない）
  bool get isSafe => _value is! DeviceSecurityStatusThreat;

  /// 値を更新してストリームに流す
  void add(DeviceSecurityStatus value) {
    _value = value;
    _controller.add(value);
  }

  /// 現在の値を流してからストリームを返す
  Stream<DeviceSecurityStatus> watch() async* {
    yield _value;
    yield* _controller.stream;
  }

  /// リソースの解放
  Future<void> close() => _controller.close();
}
