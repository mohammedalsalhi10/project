import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  // المفتاح السري: يجب أن يكون بطول 32 حرفاً لخوارزمية AES-256
  // ملاحظة: في التطبيقات الحقيقية، لا يتم حفظ المفتاح كـ String بسيط هنا،
  // بل يتم توليده من كلمة المرور الرئيسية (Master Password) للمستخدم
  // أو حفظه في الـ Secure Storage. سنستخدم مفتاحاً ثابتاً مؤقتاً للتوضيح.
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  // شعاع التهيئة (IV) يضيف طبقة عشوائية للتشفير. بطول 16 حرفاً.
  static final _iv = encrypt.IV.fromLength(16);

  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // دالة تشفير النص
  static String encryptPassword(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64; // تحويل النتيجة إلى نص Base64 ليسهل حفظه
  }

  // دالة فك التشفير
  static String decryptPassword(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      return 'خطأ في فك التشفير';
    }
  }
}