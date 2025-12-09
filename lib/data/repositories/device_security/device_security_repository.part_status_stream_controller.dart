part of 'device_security_repository.dart';

/// 現在の値を保持するStreamController
final class _StatusStreamController {
  /// 現在の値（初期値は checking）
  DeviceSecurityStatus _value = const DeviceSecurityStatus.checking();

  final _streamController = StreamController<DeviceSecurityStatus>.broadcast();

  /// 安全な状態かどうか（脅威が検出されていない）
  bool get isSafe => _value is! DeviceSecurityStatusThreat;

  /// 値を更新してストリームに流す
  void _add(DeviceSecurityStatus value) {
    _value = value;
    _streamController.add(value);
  }

  /// 安全状態を通知
  void addSafe() => _add(const DeviceSecurityStatus.safe());

  /// 脅威検出を通知
  void addThreat(String message) =>
      _add(DeviceSecurityStatus.threat(message: message));

  /// 現在の値を流してからストリームを返す
  Stream<DeviceSecurityStatus> watch() {
    return Stream<DeviceSecurityStatus>.multi((sink) {
      // 1. controller.stream を購読
      final subscription = _streamController.stream.listen(
        sink.add,
        onError: sink.addError,
        onDone: sink.close,
      );

      sink
        // 2. 現在の値を即座に流す
        ..add(_value)

        // 3. キャンセル時にクリーンアップ
        ..onCancel = subscription.cancel;
    });
  }

  /// リソースの解放
  Future<void> close() => _streamController.close();
}
