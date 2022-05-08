import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionDecryption {
  //for AES algorithm
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static encryptAES(text) {
    final encrypted = encrypter.encrypt(text, iv: iv);
    return encrypted;
  }

  static decryptAES(text) {
    final decrypted = encrypter.decrypt64(text, iv: iv);
    return decrypted;
  }
}
