import 'dart:async';
import 'package:chat/bloc/error_handler_bloc/error_types.dart';
import 'package:chat/services/logger/logger_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class _Keys {
  static const token = 'token';
  static const userId = 'user_id';
  static const deviceID = 'device_id';
  static const os = 'os';
  static const sipContacts = 'sip_contacts';
}

class DataProvider {
  static const _secureStorage = FlutterSecureStorage();

  Future<String?> getToken() => _secureStorage.read(key: _Keys.token);

  Future<void> setToken(String value) {
    try {
      return _secureStorage.write(key: _Keys.token, value: value);
    } catch(err, stackTrace) {
      throw AppErrorException(AppErrorExceptionType.secureStorage, stackTrace.toString(), "setToken");
    }
  }

  Future<String?> getOs() => _secureStorage.read(key: _Keys.os);

  Future<void> setOs(String value) {
    return _secureStorage.write(key: _Keys.os, value: value);
  }

  Future<void> deleteToken() async {
    try {
      await _deleteToken();
    } catch (err) {
      print("Error deleting token: /n  $err");
    }
  }

  Future<void> _deleteToken() {
    return _secureStorage.delete(key: _Keys.token);
  }

  Future<String?> getUserId() async {
    final id = await _secureStorage.read(key: _Keys.userId);
    return id;
  }

  Future<void> setUserId(int value) {
    return _secureStorage.write(
      key: _Keys.userId,
      value: value.toString(),
    );
  }

  Future<void> deleteUserId() {
    return _secureStorage.delete(key: _Keys.userId);
  }

  Future<String?> getDeviceID() => _secureStorage.read(key: _Keys.deviceID);

  Future<void> setDeviceID(String value) {
    return _secureStorage.write(key: _Keys.deviceID, value: value);
  }

  Future<void> deleteDeviceID() {
    return _secureStorage.delete(key: _Keys.deviceID);
  }

  Future<void> setSipContacts(Map<String, String> value) {
    return _secureStorage.write(key: _Keys.sipContacts, value: value.toString());
  }

  Future<String?> getSipContacts() {
    return _secureStorage.read(key: _Keys.sipContacts);
  }

  Future<void> deleteSipContacts() {
    return _secureStorage.delete(key: _Keys.sipContacts);
  }

}