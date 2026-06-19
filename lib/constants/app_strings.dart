/// All Thai UI strings for NutriThaiFood AI
/// Supports localization extension later — just swap this class with an ARB loader
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'NutriThaiFood AI';
  static const String tagline = 'ติดตามโภชนาการอาหารไทยด้วย AI';

  // Auth
  static const String login = 'เข้าสู่ระบบ';
  static const String register = 'สมัครสมาชิก';
  static const String logout = 'ออกจากระบบ';
  static const String email = 'อีเมล';
  static const String password = 'รหัสผ่าน';
  static const String confirmPassword = 'ยืนยันรหัสผ่าน';
  static const String displayName = 'ชื่อที่แสดง';
  static const String forgotPassword = 'ลืมรหัสผ่าน?';
  static const String noAccount = 'ยังไม่มีบัญชี? ';
  static const String haveAccount = 'มีบัญชีแล้ว? ';
  static const String registerNow = 'สมัครสมาชิก';
  static const String loginNow = 'เข้าสู่ระบบ';

  // Navigation
  static const String home = 'หน้าแรก';
  static const String foodLog = 'บันทึกอาหาร';
  static const String randomMenu = 'สุ่มเมนู';
  static const String water = 'น้ำ';
  static const String profile = 'โปรไฟล์';

  // Dashboard
  static const String todayCalories = 'แคลอรี่วันนี้';
  static const String caloriesConsumed = 'กินแล้ว';
  static const String caloriesRemaining = 'เหลือ';
  static const String caloriesUnit = 'kcal';
  static const String protein = 'โปรตีน';
  static const String carbs = 'คาร์บ';
  static const String fat = 'ไขมัน';
  static const String gramsUnit = 'g';
  static const String waterIntake = 'การดื่มน้ำ';
  static const String streak = 'สตรีค';
  static const String days = 'วัน';
  static const String quests = 'ภารกิจ';
  static const String dailyGoal = 'เป้าหมายวันนี้';
  static const String goodMorning = 'สวัสดีตอนเช้า';
  static const String goodAfternoon = 'สวัสดีตอนบ่าย';
  static const String goodEvening = 'สวัสดีตอนเย็น';

  // Quick Actions
  static const String scanFood = 'สแกนอาหาร';
  static const String quickLog = 'บันทึกด่วน';
  static const String randomFood = 'สุ่มเมนู';
  static const String drinkWater = 'ดื่มน้ำ';

  // Meals
  static const String breakfast = 'มื้อเช้า';
  static const String lunch = 'มื้อกลางวัน';
  static const String dinner = 'มื้อเย็น';
  static const String snack = 'ของว่าง';
  static const String incompleteMeals = 'วันนี้คุณยังบันทึกอาหารไม่ครบ 3 มื้อ';
  static const String missingDinner = 'ยังไม่ได้บันทึกมื้อเย็น';
  static const String missingLunch = 'ยังไม่ได้บันทึกมื้อกลางวัน';
  static const String missingBreakfast = 'ยังไม่ได้บันทึกมื้อเช้า';

  // Food Log
  static const String addFood = 'เพิ่มอาหาร';
  static const String aiScan = 'สแกนด้วย AI';
  static const String foodHistory = 'ประวัติอาหาร';
  static const String quickManual = 'บันทึกด่วน';
  static const String gramBased = 'คำนวณตามกรัม';
  static const String foodName = 'ชื่ออาหาร';
  static const String calories = 'แคลอรี่';
  static const String servingSize = 'ปริมาณ 1 หน่วย';
  static const String save = 'บันทึก';
  static const String cancel = 'ยกเลิก';
  static const String confirm = 'ยืนยัน';
  static const String delete = 'ลบ';
  static const String edit = 'แก้ไข';
  static const String notes = 'หมายเหตุ (ไม่บังคับ)';
  static const String saveThisMenu = 'บันทึกเมนูนี้';

  // AI Scan
  static const String takingPhoto = 'ถ่ายภาพ';
  static const String uploadPhoto = 'อัปโหลดภาพ';
  static const String analyzing = 'กำลังวิเคราะห์...';
  static const String detectedFoods = 'อาหารที่ตรวจพบ';
  static const String confidence = 'ความแม่นยำ';
  static const String confirmFoods = 'ยืนยันรายการอาหาร';
  static const String editResult = 'แก้ไขผลลัพธ์';
  static const String aiScanTitle = 'สแกนอาหารด้วย AI';
  static const String tapToScan = 'แตะเพื่อถ่ายหรืออัปโหลดภาพอาหาร';

  // Gram-based
  static const String gramCalculation = 'คำนวณตามกรัม';
  static const String component = 'ส่วนประกอบ';
  static const String grams = 'กรัม';
  static const String addComponent = 'เพิ่มส่วนประกอบ';
  static const String calculate = 'คำนวณ';
  static const String totalNutrition = 'โภชนาการรวม';

  // Water
  static const String waterProgress = 'ดื่มน้ำแล้ว';
  static const String waterGoal = '8 แก้วต่อวัน';
  static const String glassOf = 'แก้ว';
  static const String ml = 'มล.';
  static const String tapGlass = 'แตะแก้วเพื่อบันทึกการดื่มน้ำ';
  static const String waterCompleted = 'ดื่มน้ำครบแล้ว! 🎉';

  // Profile
  static const String profileSetup = 'ตั้งค่าโปรไฟล์';
  static const String age = 'อายุ';
  static const String gender = 'เพศ';
  static const String male = 'ชาย';
  static const String female = 'หญิง';
  static const String heightCm = 'ส่วนสูง (ซม.)';
  static const String weightKg = 'น้ำหนัก (กก.)';
  static const String activityLevel = 'ระดับกิจกรรม';
  static const String goal = 'เป้าหมาย';
  static const String goalLose = 'ลดน้ำหนัก';
  static const String goalMaintain = 'คงน้ำหนัก';
  static const String goalGain = 'เพิ่มน้ำหนัก';
  static const String sedentary = 'ไม่ค่อยเคลื่อนไหว';
  static const String lightlyActive = 'เคลื่อนไหวเล็กน้อย';
  static const String moderatelyActive = 'เคลื่อนไหวปานกลาง';
  static const String veryActive = 'เคลื่อนไหวมาก';
  static const String extraActive = 'เคลื่อนไหวมากพิเศษ';
  static const String dailyTargets = 'เป้าหมายโภชนาการรายวัน';
  static const String bmr = 'BMR';
  static const String tdee = 'TDEE';
  static const String saveProfile = 'บันทึกโปรไฟล์';

  // Quests
  static const String todayQuests = 'ภารกิจวันนี้';
  static const String questCompleted = 'เสร็จแล้ว';
  static const String questInProgress = 'กำลังดำเนินการ';
  static const String drinkWaterQuest = 'ดื่มน้ำให้ครบ 8 แก้ว';
  static const String logMealsQuest = 'บันทึกอาหารให้ครบ 3 มื้อ';
  static const String hitProteinQuest = 'กินโปรตีนให้ถึงเป้าหมาย';
  static const String stayInCaloriesQuest = 'อย่าให้แคลอรี่เกินเป้าหมาย';
  static const String logOneFoodQuest = 'บันทึกอาหารอย่างน้อย 1 รายการวันนี้';

  // Random Menu
  static const String randomMenuTitle = 'สุ่มเมนูแนะนำ';
  static const String basedOnRemaining = 'แนะนำตามโควต้าที่เหลือ';
  static const String shuffleAgain = 'สุ่มใหม่';
  static const String noFoodMatch = 'ไม่พบเมนูที่เหมาะสม';

  // Errors
  static const String errorGeneral = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
  static const String errorNetwork = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
  static const String errorAuth = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
  static const String errorEmailExists = 'อีเมลนี้ถูกใช้งานแล้ว';
  static const String errorWeakPassword = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  static const String errorInvalidEmail = 'รูปแบบอีเมลไม่ถูกต้อง';
  static const String errorPasswordMismatch = 'รหัสผ่านไม่ตรงกัน';
  static const String errorRequired = 'กรุณากรอกข้อมูล';
  static const String errorPositiveNumber = 'กรุณากรอกตัวเลขที่มากกว่า 0';

  // Success
  static const String successSaved = 'บันทึกสำเร็จ!';
  static const String successDeleted = 'ลบสำเร็จ!';
  static const String successProfileSaved = 'บันทึกโปรไฟล์สำเร็จ!';
  static const String successFoodLogged = 'บันทึกอาหารสำเร็จ!';
  static const String successWaterLogged = 'บันทึกการดื่มน้ำสำเร็จ!';

  // Empty states
  static const String emptyFoodLog = 'ยังไม่มีรายการอาหาร\nกดปุ่มด้านบนเพื่อบันทึกอาหาร';
  static const String emptyHistory = 'ยังไม่มีประวัติอาหาร';
  static const String emptyQuests = 'ยังไม่มีภารกิจวันนี้';

  // Confirm delete
  static const String confirmDeleteTitle = 'ยืนยันการลบ';
  static const String confirmDeleteMessage = 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?';

  // Notifications
  static const String notifWater = 'วันนี้คุณยังดื่มน้ำไม่ครบ 8 แก้ว';
  static const String notifProtein = 'วันนี้คุณยังขาดโปรตีน';
  static const String notifMeals = 'วันนี้คุณยังบันทึกอาหารไม่ครบ 3 มื้อ';
  static const String notifStreak = 'อย่าลืมบันทึกอาหารวันนี้เพื่อรักษา streak ของคุณ';

  // Settings
  static const String settings = 'การตั้งค่า';
  static const String notifications = 'การแจ้งเตือน';
  static const String language = 'ภาษา';
  static const String about = 'เกี่ยวกับแอป';
  static const String version = 'เวอร์ชัน';
}
