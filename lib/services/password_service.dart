import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      // ตรวจสอบว่ามีผู้ใช้ที่ล็อกอินอยู่
      User? user = _auth.currentUser;
      if (user == null) return 'ไม่พบผู้ใช้ที่ล็อกอิน';

      // สร้าง credential สำหรับยืนยันตัวตน
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // ยืนยันตัวตนซ้ำเพื่อตรวจสอบรหัสผ่านปัจจุบัน
      await user.reauthenticateWithCredential(credential);
      
      // เปลี่ยนรหัสผ่าน
      await user.updatePassword(newPassword);
      return null; // ส่งค่า null เมื่อสำเร็จ
    } on FirebaseAuthException catch (e) {
      // จัดการข้อผิดพลาดต่างๆ
      switch (e.code) {
        case 'wrong-password':
          return 'รหัสผ่านปัจจุบันไม่ถูกต้อง';
        case 'weak-password':
          return 'รหัสผ่านใหม่ต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
        case 'requires-recent-login':
          return 'กรุณาล็อกอินใหม่เพื่อดำเนินการต่อ';
        default:
          return 'เกิดข้อผิดพลาด: ${e.message}';
      }
    }
  }
}