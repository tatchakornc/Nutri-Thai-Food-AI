import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/quest_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/quest_card.dart';

class QuestScreen extends ConsumerWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(todayQuestsProvider);
    final completed = ref.watch(completedQuestsCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ภารกิจวันนี้')),
      body: questsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text('$e')),
        data: (quests) {
          if (quests.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.flag_rounded,
              title: 'ยังไม่มีภารกิจ',
              subtitle: 'ภารกิจจะปรากฏเมื่อคุณเริ่มบันทึกอาหาร',
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Text('🏆',
                          style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completed / ${quests.length} ภารกิจสำเร็จ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            completed == quests.length
                                ? 'ยอดเยี่ยม! คุณทำครบทุกภารกิจแล้ว!'
                                : 'เหลืออีก ${quests.length - completed} ภารกิจ สู้ต่อไป!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => QuestCard(quest: quests[i]),
                    childCount: quests.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
