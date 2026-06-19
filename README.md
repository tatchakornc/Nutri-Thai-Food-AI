<<<<<<< HEAD
# Nutri-Thai-Food-AI
=======
# Nutri Thai Food AI

แอปมือถือสำหรับช่วยวิเคราะห์ข้อมูลโภชนาการอาหารไทย (Flutter)

## สรุป
โปรเจคนี้เป็นแอป Flutter ที่ใช้สำหรับประเมิน/วิเคราะห์ข้อมูลโภชนาการอาหารไทย มีการเชื่อมต่อกับ Firebase และมีโค้ดฟังก์ชันฝั่งเซิร์ฟเวอร์ในโฟลเดอร์ `functions`.

## ความต้องการพื้นฐาน (Prerequisites)
- Flutter (ติดตั้งตามเวอร์ชัน stable ล่าสุด) และ Dart
- Android SDK (สำหรับรันบน Android) / Xcode (สำหรับรันบน iOS)
- Node.js & npm (สำหรับรันหรือดีพลอยฟังก์ชันในโฟลเดอร์ `functions`)
- (แนะนำ) Firebase CLI และ FlutterFire CLI เมื่อต้องการกำหนดค่า Firebase ใหม่

## การตั้งค่าเริ่มต้น (Setup)
1. เปิดคลังโปรเจคนี้
2. ติดตั้ง dependencies ของ Flutter:

   - รัน `flutter pub get`

3. ตรวจสอบไฟล์การตั้งค่า Firebase:
   - สำหรับ Android: ตรวจสอบว่า `android/app/google-services.json` อยู่ในโปรเจค (ไฟล์นี้ได้จาก Firebase console)
   - สำหรับ iOS: ตรวจสอบว่า `ios/Runner/GoogleService-Info.plist` อยู่ในโปรเจค (ถ้ายังไม่มี ให้ดาวน์โหลดจาก Firebase แล้วเพิ่มเข้า Xcode)
   - โปรเจคมีไฟล์ `firebase.json` และ `firebase_options.dart` (ถ้ามี) ซึ่งช่วยให้การเชื่อมต่อกับ Firebase ทำได้ง่ายขึ้น

4. หากต้องการสร้าง/อัพเดต `firebase_options.dart` ให้ใช้ FlutterFire CLI (ถ้ายังไม่ได้ติดตั้ง):
   - ติดตั้ง FlutterFire CLI (ถ้ายังไม่มี)
   - รันคำสั่ง configure ของ FlutterFire ตามเอกสารของ Firebase

## การรันแอป
- รันบนอุปกรณ์เชื่อมต่อหรือ emulator/simulator:
  - `flutter run` (เลือก device เมื่อถูกถาม)

- รันบน web:
  - `flutter run -d chrome`

- รันบน iOS (จาก macOS):
  - เปิด `ios/Runner.xcworkspace` ใน Xcode เมื่อต้องการทดสอบหรือ archive

## การสร้าง build สำหรับปล่อย
- Android (APK): `flutter build apk --release`
- Android (App Bundle): `flutter build appbundle --release`
- iOS: `flutter build ipa` หรือใช้ Xcode ในการ archive และส่งขึ้น App Store
- Web: `flutter build web`

## ฟังก์ชันฝั่งเซิร์ฟเวอร์ (functions)
โฟลเดอร์ `functions/` เป็น Node.js project สำหรับ Cloud Functions (ถ้ามี):
1. เข้าไปที่โฟลเดอร์ `functions`:
   - ติดตั้ง dependencies: `npm install`
2. สั่งรัน/ดีพลอยตามที่โปรเจคกำหนด (ดู `package.json` ภายในโฟลเดอร์ functions)

## การทดสอบ
- รัน unit/widget tests ของ Flutter:
  - `flutter test`

## การแก้ไขปัญหาเบื้องต้น (Troubleshooting)
- หากมีปัญหาเกี่ยวกับ Firebase:
  - ตรวจสอบว่าไฟล์ `google-services.json` / `GoogleService-Info.plist` ถูกวางไว้ในตำแหน่งที่ถูกต้อง
  - ตรวจสอบ `firebase_options.dart` หรือกำหนดค่าใหม่ด้วย FlutterFire CLI
- หากขึ้น error เกี่ยวกับ plugin native:
  - รัน `flutter clean` แล้ว `flutter pub get` แล้วลองรันใหม่
- หากมีปัญหาการ build บน iOS:
  - เปิด Xcode, ทำการ clean build folder, ติดตั้ง CocoaPods ใหม่ (`pod install` ในโฟลเดอร์ `ios`)

## หมายเหตุสำคัญ
- ไฟล์การตั้งค่า (เช่น `google-services.json`, `GoogleService-Info.plist`) มักจะไม่ควรเก็บในรีโมทสาธารณะ หากโปรเจคเป็น public ให้ระวังข้อมูลคีย์/คอนฟิกที่สำคัญ

## ถาม-ตอบ / ติดต่อ
หากต้องการความช่วยเหลือเพิ่มเติม หรือให้ปรับ README ให้เจาะจงกับการดีพลอยบน Firebase / CI/CD สามารถบอกมาว่าต้องการแพลตฟอร์มหรือขั้นตอนใดเป็นพิเศษ

---

(README นี้เป็นคำแนะนำเบื้องต้น หากต้องการให้ผมเติมคำสั่งหรือรายละเอียดเฉพาะของโปรเจค เช่น เวอร์ชัน Flutter ที่ใช้ รูปแบบการใช้งานภายในแอป หรือลำดับการดีพลอย ให้แจ้งมาได้เลย)
>>>>>>> c03df5e (chore: initial commit)
