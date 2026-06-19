import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifEnabled = true;
  bool _dailyReminder = true;
  bool _waterReminder = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('การตั้งค่า')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingSection(
            title: 'การแจ้งเตือน',
            children: [
              SwitchListTile(
                title: const Text('เปิดการแจ้งเตือน'),
                subtitle: const Text('รับการแจ้งเตือนจากแอป'),
                value: _notifEnabled,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _notifEnabled = v),
              ),
              SwitchListTile(
                title: const Text('แจ้งเตือนสรุปรายวัน'),
                subtitle: const Text('แจ้งเตือนตอน 20:00 น. ทุกวัน'),
                value: _dailyReminder && _notifEnabled,
                activeColor: AppColors.primary,
                onChanged: _notifEnabled
                    ? (v) => setState(() => _dailyReminder = v)
                    : null,
              ),
              SwitchListTile(
                title: const Text('แจ้งเตือนการดื่มน้ำ'),
                subtitle: const Text('แจ้งเตือนเมื่อดื่มน้ำไม่ครบ'),
                value: _waterReminder && _notifEnabled,
                activeColor: AppColors.primary,
                onChanged: _notifEnabled
                    ? (v) => setState(() => _waterReminder = v)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingSection(
            title: 'แอปพลิเคชัน',
            children: [
              ListTile(
                leading: const Icon(Icons.language_rounded,
                    color: AppColors.primary),
                title: const Text('ภาษา'),
                trailing: const Text(
                  'ไทย',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary),
                title: const Text('เกี่ยวกับแอป'),
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'NutriThaiFood AI',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2025 NutriThaiFood AI\nแอปติดตามโภชนาการอาหารไทยด้วย AI',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined,
                    color: AppColors.primary),
                title: const Text('นโยบายความเป็นส่วนตัว'),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppColors.shadowMedium, blurRadius: 8),
            ],
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
