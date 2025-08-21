import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class SecureStorageService {
  static SecureStorageService? _instance;
  static SecureStorageService get instance {
    _instance ??= SecureStorageService._internal();
    return _instance!;
  }

  SecureStorageService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for storing different data
  static const String _privateKeyKey = 'private_key_encrypted';
  static const String _mnemonicKey = 'mnemonic_encrypted';
  static const String _encryptionKey = 'encryption_key';

  late final Encrypter _encrypter;
  late final IV _iv;

  Future<void> initialize() async {
    // Get or create encryption key
    String? keyString = await _storage.read(key: _encryptionKey);

    if (keyString == null) {
      final key = Key.fromSecureRandom(32);
      keyString = key.base64;
      await _storage.write(key: _encryptionKey, value: keyString);
    }

    final key = Key.fromBase64(keyString);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
  }

  // Store private key securely
  Future<void> storePrivateKey(String privateKey) async {
    await initialize();
    final encrypted = _encrypter.encrypt(privateKey, iv: _iv);
    await _storage.write(
      key: _privateKeyKey,
      value: '${encrypted.base64}:${_iv.base64}',
    );
  }

  // Retrieve private key
  Future<String?> getPrivateKey() async {
    await initialize();
    final encryptedData = await _storage.read(key: _privateKeyKey);

    if (encryptedData == null) return null;

    final parts = encryptedData.split(':');
    if (parts.length != 2) return null;

    final encrypted = Encrypted.fromBase64(parts[0]);
    final iv = IV.fromBase64(parts[1]);

    return _encrypter.decrypt(encrypted, iv: iv);
  }

  // Store mnemonic securely
  Future<void> storeMnemonic(String mnemonic) async {
    await initialize();
    final encrypted = _encrypter.encrypt(mnemonic, iv: _iv);
    await _storage.write(
      key: _mnemonicKey,
      value: '${encrypted.base64}:${_iv.base64}',
    );
  }

  // Retrieve mnemonic
  Future<String?> getMnemonic() async {
    await initialize();
    final encryptedData = await _storage.read(key: _mnemonicKey);

    if (encryptedData == null) return null;

    final parts = encryptedData.split(':');
    if (parts.length != 2) return null;

    final encrypted = Encrypted.fromBase64(parts[0]);
    final iv = IV.fromBase64(parts[1]);

    return _encrypter.decrypt(encrypted, iv: iv);
  }

  // Store wallet address (non-sensitive, can use regular storage)
  Future<void> storeWalletAddress(String address) async {
    await _storage.write(key: 'wallet_address', value: address);
  }

  // Get wallet address
  Future<String?> getWalletAddress() async {
    return await _storage.read(key: 'wallet_address');
  }

  // Check if wallet exists
  Future<bool> hasWallet() async {
    final address = await getWalletAddress();
    final privateKey = await getPrivateKey();
    return address != null && privateKey != null;
  }

  // Clear all wallet data
  Future<void> clearWalletData() async {
    await _storage.delete(key: _privateKeyKey);
    await _storage.delete(key: _mnemonicKey);
    await _storage.delete(key: 'wallet_address');
  }

  // Store other sensitive data
  Future<void> storeSecureData(String key, String value) async {
    await initialize();
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _storage.write(
      key: key,
      value: '${encrypted.base64}:${_iv.base64}',
    );
  }

  // Get other sensitive data
  Future<String?> getSecureData(String key) async {
    await initialize();
    final encryptedData = await _storage.read(key: key);

    if (encryptedData == null) return null;

    final parts = encryptedData.split(':');
    if (parts.length != 2) return null;

    final encrypted = Encrypted.fromBase64(parts[0]);
    final iv = IV.fromBase64(parts[1]);

    return _encrypter.decrypt(encrypted, iv: iv);
  }
}
