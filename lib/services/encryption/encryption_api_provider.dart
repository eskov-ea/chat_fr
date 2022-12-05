// import 'package:encrypt/encrypt.dart';
//
// class EncryptionAPIProvider {
//
//   final Encrypter _encrypter;
//   final _iv = IV.fromLength(10);
//
//   EncryptionAPIProvider(this._encrypter);
//
//   String decrypt (String encryptedText) {
//     final encrypted = Encrypted.fromBase64(encryptedText);
//     return _encrypter.decrypt(encrypted, iv: _iv);
//   }
//
//   String encrypt(String plainText) {
//     return _encrypter.encrypt(plainText, iv: _iv).base64;
//   }
//
// }