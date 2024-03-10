import 'dart:async';

import 'package:chat/models/error_model.dart';

abstract class IErrorHandlingRepository {

  final _controller = StreamController<AppErrorException>.broadcast();

  Stream<AppErrorException> get stream => _controller.stream.asBroadcastStream();

  void sink(AppErrorException payload) => _controller.sink.add(payload);
  void close() => _controller.close();

}

