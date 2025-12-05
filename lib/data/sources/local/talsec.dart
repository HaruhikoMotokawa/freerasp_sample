import 'package:freerasp/freerasp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talsec.g.dart';

@Riverpod(keepAlive: true)
Talsec talsec(Ref ref) => Talsec.instance;
