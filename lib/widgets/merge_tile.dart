import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/ingredients_data.dart';
import '../models/enums.dart';
import '../models/ingredient.dart';
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
    duration: const Duration(milliseconds: 650),
  );
  String? _lastUid;
  bool _isDragging = false;

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
      // Antes: _popController.value = 0 (salto instantáneo). Ahora se
      // encoge suavemente, para que la celda origen no "desaparezca de
      // golpe" cuando el ítem se mueve a otra celda.
      _popController.animateTo(0,
          duration: const Duration(milliseconds: 150), curve: Curves.easeIn);
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
    final ingredient = widget.item == null
        ? null
        : IngredientsData.byId[widget.item!.ingredientId];
    final rarity = ingredient?.rarity ?? Rarity.comun;
    final rarityColor = rarity.color;

    final content = ScaleTransition(
      scale: CurvedAnimation(
          parent: _popController,
          curve: Curves.elasticOut,
          reverseCurve: Curves.easeIn),
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
          color:
              widget.item == null ? Colors.white.withValues(alpha: 0.55) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.selected
                ? AppColors.gold
                : (widget.item == null
                    ? const Color(0xFFEFE1CB)
                    : rarityColor.withValues(alpha: 0.55)),
            width: widget.selected ? 2.4 : 1.2,
          ),
          boxShadow: widget.item == null
              ? []
              : [
                  BoxShadow(
                    color: (widget.selected ? AppColors.gold : rarityColor)
                        .withValues(alpha: 0.28),
                    blurRadius: widget.selected ? 10 : 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: ingredient == null
            ? null
            : GameVisual(
                assetPath: ingredient.imagePath,
                emoji: ingredient.emoji,
                size: 26),
      ),
    );

    final tileWithBurst = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (widget.justMerged)
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) {
              final glowOpacity =
                  (1 - _burstController.value).clamp(0.0, 1.0) * 0.65;
              return IgnorePointer(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        rarityColor.withValues(alpha: glowOpacity),
                        Colors.transparent
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        content,
        if (widget.justMerged)
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) => IgnorePointer(
              child: CustomPaint(
                size: const Size(52, 52),
                painter: FusionBurstPainter(
                    progress: _burstController.value, color: rarityColor),
              ),
            ),
          ),
        if (widget.justMerged && ingredient != null)
          AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) {
              final t = Curves.easeOut.transform(_burstController.value);
              final opacity =
                  (1 - _burstController.value * 1.2).clamp(0.0, 1.0);
              return Positioned(
                top: -14 - (22 * t),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child:
                        _MergeLabel(text: ingredient.name, color: rarityColor),
                  ),
                ),
              );
            },
          ),
      ],
    );

    final target = DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != widget.index,
      onAcceptWithDetails: (details) {
        HapticFeedback.lightImpact();
        widget.onDropped(details.data, widget.index);
      },
      builder: (context, candidateData, rejectedData) {
        final highlighted = candidateData.isNotEmpty;
        return AnimatedScale(
          scale: highlighted ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: highlighted
                  ? [
                      BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.45),
                          blurRadius: 10,
                          spreadRadius: 1)
                    ]
                  : [],
            ),
            child: tileWithBurst,
          ),
        );
      },
    );

    if (widget.item == null) {
      return GestureDetector(
          onTap: () => widget.onTap(widget.index), child: target);
    }

    return Draggable<int>(
      data: widget.index,
      onDragStarted: () {
        HapticFeedback.selectionClick();
        setState(() => _isDragging = true);
      },
      onDragEnd: (_) => setState(() => _isDragging = false),
      onDraggableCanceled: (_, __) => setState(() => _isDragging = false),
      feedback:
          _DragFeedback(rarityColor: rarityColor, ingredient: ingredient!),
      childWhenDragging: AnimatedScale(
        scale: 0.88,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: 0.32,
          duration: const Duration(milliseconds: 150),
          child: target,
        ),
      ),
      child: AnimatedScale(
        scale: _isDragging ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: GestureDetector(
            onTap: () => widget.onTap(widget.index), child: target),
      ),
    );
  }
}

/// Tarjeta que sigue al dedo mientras se arrastra un ingrediente. Al
/// aparecer, hace un pequeño "pop" con rebote (como si el jugador
/// realmente lo hubiera levantado) en vez de saltar directo a tamaño
/// completo, y mantiene una leve inclinación para sensación orgánica.
class _DragFeedback extends StatefulWidget {
  final Color rarityColor;
  final Ingredient ingredient;
  const _DragFeedback({required this.rarityColor, required this.ingredient});

  @override
  State<_DragFeedback> createState() => _DragFeedbackState();
}

class _DragFeedbackState extends State<_DragFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      child: Transform.rotate(
        angle: 0.06,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 52,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: widget.rarityColor.withValues(alpha: 0.6),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: widget.rarityColor.withValues(alpha: 0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Center(
                child: GameVisual(
                    assetPath: widget.ingredient.imagePath,
                    emoji: widget.ingredient.emoji,
                    size: 34),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta que aparece justo encima de la celda al fusionar, mostrando
/// el nombre del resultado mientras flota hacia arriba y se desvanece.
/// Reemplaza el burst "mudo": ahora el jugador ve exactamente qué obtuvo.
class _MergeLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _MergeLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
