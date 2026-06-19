/// Form field validators — all return Thai error messages or null if valid
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอกอีเมล';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
    if (value.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
    if (value != original) return 'รหัสผ่านไม่ตรงกัน';
    return null;
  }

  static String? required(String? value, [String fieldName = 'ข้อมูล']) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอก$fieldName';
    return null;
  }

  static String? positiveDouble(String? value, [String fieldName = 'ตัวเลข']) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอก$fieldName';
    final num = double.tryParse(value.trim());
    if (num == null) return 'กรุณากรอกตัวเลขให้ถูกต้อง';
    if (num <= 0) return '$fieldName ต้องมากกว่า 0';
    return null;
  }

  static String? positiveInt(String? value, [String fieldName = 'ตัวเลข']) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอก$fieldName';
    final num = int.tryParse(value.trim());
    if (num == null) return 'กรุณากรอกตัวเลขเต็มให้ถูกต้อง';
    if (num <= 0) return '$fieldName ต้องมากกว่า 0';
    return null;
  }

  static String? nonNegativeDouble(String? value, [String fieldName = 'ตัวเลข']) {
    if (value == null || value.trim().isEmpty) return 'กรุณากรอก$fieldName';
    final num = double.tryParse(value.trim());
    if (num == null) return 'กรุณากรอกตัวเลขให้ถูกต้อง';
    if (num < 0) return '$fieldName ต้องไม่ติดลบ';
    return null;
  }
}
