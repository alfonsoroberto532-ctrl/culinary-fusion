import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/mission.dart';
import '../theme/app_theme.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final pending = gameState.missions.where((m) => !m.claimed).toList();
    final claimed = gameState.missions.where((m) => m.claimed).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text('Misiones', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...pending.map((m) => _MissionCard(m: m, gameState: gameState)),
        if (claimed.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('${claimed.length} misiones completadas',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
        const SizedBox(height: 22),
        Text('Logros', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: gameState.achievements.map((a) {
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: softCardDecoration(
                radius: 16,
                color: a.unlocked ? AppColors.surfaceAlt : AppColors.surface,
                borderColor: a.unlocked ? AppColors.gold.withValues(alpha: 0.5) : const Color(0xFFF0E1C4),
              ),
              child: Opacity(
                opacity: a.unlocked ? 1 : 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(a.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Mission m;
  final GameState gameState;
  const _MissionCard({required this.m, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final progressValue = (m.progress / m.targetCount).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: softCardDecoration(
        radius: 16,
        color: m.isComplete ? const Color(0xFFFFF4D6) : AppColors.surface,
        borderColor: m.isComplete ? AppColors.gold.withValues(alpha: 0.5) : const Color(0xFFF0E1C4),
      ),
      child: Row(
        children: [
          Icon(
            m.isComplete ? Icons.emoji_events_rounded : Icons.flag_rounded,
            color: m.isComplete ? AppColors.goldDark : AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF0E4D2),
                    valueColor: AlwaysStoppedAnimation(m.isComplete ? AppColors.gold : AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.savings_rounded, size: 12, color: AppColors.goldDark),
                    const SizedBox(width: 2),
                    Text('${m.rewardCoins}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded, size: 12, color: AppColors.secondary),
                    const SizedBox(width: 2),
                    Text('${m.rewardXp} XP', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: m.isComplete ? AppColors.gold : const Color(0xFFE0D6C4),
              foregroundColor: m.isComplete ? AppColors.textDark : AppColors.textMuted,
            ),
            onPressed: m.isComplete ? () => gameState.claimMission(m.id) : null,
            child: Text('${m.progress}/${m.targetCount}'),
          ),
        ],
      ),
    );
  }
}
