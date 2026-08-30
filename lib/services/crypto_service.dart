import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class EncryptedPayload {
  final String ciphertext;
  final String nonce;
  final String tag;
  final String sha256;

  const EncryptedPayload({
    required this.ciphertext,
    required this.nonce,
    required this.tag,
    required this.sha256,
  });
}

class CryptoService {
  final AesGcm _aes = AesGcm.with256bits();
  late final SecretKey _key;

  Future<void> init() async {
    _key = await _aes.newSecretKey();
  }

  Future<EncryptedPayload> encrypt(String plaintext) async {
    final box = await _aes.encrypt(
      utf8.encode(plaintext),
      secretKey: _key,
    );
    final digest = await Sha256().hash(box.cipherText);

    return EncryptedPayload(
      ciphertext: base64Encode(box.cipherText),
      nonce: base64Encode(box.nonce),
      tag: base64Encode(box.mac.bytes),
      sha256: base64Encode(digest.bytes),
    );
  }

  Future<String> decrypt(EncryptedPayload payload) async {
    final bytes = base64Decode(payload.ciphertext);
    final digest = await Sha256().hash(bytes);
    if (base64Encode(digest.bytes) != payload.sha256) {
      throw StateError('Integrity check failed');
    }

    final box = SecretBox(
      bytes,
      nonce: base64Decode(payload.nonce),
      mac: Mac(base64Decode(payload.tag)),
    );

    final clear = await _aes.decrypt(box, secretKey: _key);
    return utf8.decode(clear);
  }
}
