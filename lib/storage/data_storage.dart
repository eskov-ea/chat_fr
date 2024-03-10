import 'dart:async';
import 'package:chat/services/database/db_provider.dart';

abstract class _Keys {
  static const token = 'auth_token';
  static const userId = 'user_id';
}

class DataProvider {

  DataProvider._();
  static DataProvider? _instance;

  static DataProvider get storage {
    _instance ??= DataProvider._();
    return _instance!;
  }
  final _db = DBProvider.db;

  final _cache = <String, String?>{};

  Future<String?> getToken() async {
    if (_cache.containsKey(_Keys.token)) {
      return _cache[_Keys.token];
    } else {
      final token = await _db.getToken();
      _cache[_Keys.token] = token;
      return token;
    }
  }

  Future<void> setToken(String value) async {
    _cache[_Keys.token] = value;
    await _db.setToken(value);
  }

  // Future<void> deleteToken() async {
  //   _cache.remove(_Keys.token);
  //   await _db.deleteToken();
  // }

  Future<int?> getUserId() async {
    if (_cache.containsKey(_Keys.userId)) {
      return int.parse(_cache[_Keys.userId]!);
    } else {
      final userId = await _db.getUserId();
      _cache[_Keys.userId] = userId.toString();
      return userId;
    }
  }

  Future<void> setUserId(int value) async {
    _cache[_Keys.userId] = value.toString();
    await _db.setUserId(value);
  }

  // Future<void> deleteUserId() async {
  //   _cache.remove(_Keys.userId);
  //   await _db.deleteUserId();
  // }

  Future<String?> getDeviceID() async => await _db.getDeviceId();

  Future<void> setDeviceId(String value) async {
    await _db.setDeviceId(value);
  }

  // Future<void> deleteDeviceID() async {
  //   await _db.deleteDeviceId();
  // }

  Future<void> setSipContacts(Map<String, String> value) async {
    await _db.setSipContacts(value.toString());
  }

  Future<String?> getSipContacts() async => await _db.getSipContacts();

  // Future<void> deleteSipContacts() async {
  //   await _db.deleteSipContacts();
  // }

}