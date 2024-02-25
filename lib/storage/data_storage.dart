import 'dart:async';
import 'dart:developer';
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
IOSOptions _getIOSOptions() => const IOSOptions(
  accountName: "mcfef_chat_app_storage_service",
  accessibility: KeychainAccessibility.first_unlock
);
AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true
);

class DataProvider {
  static final _secureStorage = FlutterSecureStorage(
    aOptions: _getAndroidOptions(),
    iOptions: _getIOSOptions()
  );

  final _cache = <String, String?>{};

  Future<String?> getToken() async {
    if (_cache.containsKey(_Keys.token)) {
      return _cache[_Keys.token];
    } else {
      final token = await _secureStorage.read(key: _Keys.token);
      _cache[_Keys.token] = token;
      return token;
    }
  }

  Future<void> setToken(String value) async {
    _cache[_Keys.token] = value;
    await _secureStorage.write(key: _Keys.token, value: value);
    Logger.getInstance().sendDebugMessage(message: "Token was successfully saved to the device. Token: $value", operation: "Set token");
  }

  Future<String?> getOs() async => await _secureStorage.read(key: _Keys.os);

  Future<void> setOs(String value) async {
    await _secureStorage.write(key: _Keys.os, value: value);
  }


  Future<void> deleteToken() async {
    _cache.remove(_Keys.token);
    await _secureStorage.delete(key: _Keys.token);
  }

  Future<String?> getUserId() async {
    if (_cache.containsKey(_Keys.userId)) {
      return _cache[_Keys.userId];
    } else {
      final userId = await _secureStorage.read(key: _Keys.userId);
      _cache[_Keys.userId] = userId;
      return userId;
    }
  }

  Future<void> setUserId(int value) async {
    _cache[_Keys.userId] = value.toString();
    await _secureStorage.write(
      key: _Keys.userId,
      value: value.toString(),
    );
  }

  Future<void> deleteUserId() async {
    _cache.remove(_Keys.userId);
    await _secureStorage.delete(key: _Keys.userId);
  }

  Future<String?> getDeviceID() async => await _secureStorage.read(key: _Keys.deviceID);

  Future<void> setDeviceID(String value) async {
    await _secureStorage.write(key: _Keys.deviceID, value: value);
  }

  Future<void> deleteDeviceID() async {
    await _secureStorage.delete(key: _Keys.deviceID);
  }

  Future<void> setSipContacts(Map<String, String> value) async {
    await _secureStorage.write(key: _Keys.sipContacts, value: value.toString());
  }

  Future<String?> getSipContacts() async => await _secureStorage.read(key: _Keys.sipContacts);

  Future<void> deleteSipContacts() async {
    await _secureStorage.delete(key: _Keys.sipContacts);
  }

}