import 'package:flutter/material.dart';

import '../data/ingredients_data.dart';
import '../models/enums.dart';
import '../models/merge_item.dart';
import '../theme/app_theme.dart';
import '../theme/game_visuals.dart';
import 'fusion_burst_painter.dart';

class MergeTile extends StatefulWidget {
  final int index;
  final MergeItem? item;
  final bool selected;
  final bool justMerged;
  final void Function(int from, int to) onDropped;
  final void Function(int index) onTap;
  final VoidCallback? onBurstComplete;

  const MergeTile({
    super.key,
    required this.index,
    required this.item,
    required this.selected,
    required this.onDropped,
    required this.onTap,
    this.justMerged = false,
    this.onBurstComplete,
  });

  @override
  State<MergeTile> createState() => _MergeTileState();
}

class _MergeTileState extends State<MergeTile> with TickerProviderStateMixin {
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final AnimationController _burstController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _lastUid = widget.item?.uid;
    if (widget.item != null) {
      _popController.value = 1;
    }
    if (widget.justMerged) {
      _playBurst();
    }
  }

  @override
  void didUpdateWidget(covariant MergeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newUid = widget.item?.uid;
    if (newUid != null && newUid != _lastUid) {
      _popController.forward(from: 0);
    } else if (newUid == null) {
      _popController.value = 0;
    }
    _lastUid = newUid;
    if (widget.justMerged && !oldWidget.justMerged) {
      _playBurst();
    }
  }

  void _playBurst() {
    _burstController.forward(from: 0).whenCompleteOrCancel(() {
      widget.onBurstComplete?.call();
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredient = widget.item == null ? null : IngredientsData.byId[widget.item!.ingredientId];
    final rarity = ingredient?.rarity ?? Rarity.comun;
    final rarityColor = rarity.color;

    final content = ScaleTransition(
      scale: CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
      child: Container(
        margin: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          gradient: widget.item == null
              ? null
              : LinearGradient(
                  colors: [rarity.colorSoft, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: widget.item == null ? const Color(0xFFFBF3E7) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.selected
                ? AppColors.gold
                : (widget.item == null ? const Color(0xFFEFE1CB) : rarityColor.withValues(alpha: 0.55)),
            width: widget.selected ? 2.4 : 1.2,
          ),
          boxShadow: widget.item == null
              ? []
              : [
                  BoxShadow(
                    color: (widget.selected ? AppColors.gold : rarityColor).withValues(alpha: 0.28),
                    blurRadius: widget.selected ? 10 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: ingredient == null
            ? null
            : GameVisual(assetPath: ingredient.imagePath, emoji: ingredient.emoji, size: 26),
      ),
    );

    final tileWithBurst = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        content,
        if (widget.justMerged)
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) => IgnorePointer(
              child: CustomPaint(
                size: const Size(52, 52),
                painter: FusionBurstPainter(progress: _burstController.value, color: rarityColor),
              ),
            ),
          ),
      ],
    );

    final target = DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != widget.index,
      onAcceptWithDetails: (details) => widget.onDropped(details.data, widget.index),
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: highlighted
                ? [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 1)]
                : [],
          ),
          child: tileWithBurst,
        );
      },
    );

    if (widget.item == null) {
      return GestureDetector(onTap: () => widget.onTap(widget.index), child: target);
    }

    return Draggable<int>(
      data: widget.index,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 46,
          height: 46,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: rarityColor.withValues(alpha: 0.5), blurRadius: 12)],
            ),
            child: Center(
              child: GameVisual(assetPath: ingredient!.imagePath, emoji: ingredient.emoji, size: 32),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: target),
      child: GestureDetector(onTap: () => widget.onTap(widget.index), child: target),
    );
  }
}
