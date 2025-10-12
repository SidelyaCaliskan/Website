import 'package:flutter/material.dart';
import '../../models/sticker_model.dart';

/// Widget for displaying and manipulating a single sticker with gestures
class StickerLayer extends StatefulWidget {
  final StickerModel sticker;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Offset) onPositionChanged;
  final Function(double) onScaleChanged;
  final Function(double) onRotationChanged;
  final VoidCallback onDelete;

  const StickerLayer({
    super.key,
    required this.sticker,
    required this.isSelected,
    required this.onTap,
    required this.onPositionChanged,
    required this.onScaleChanged,
    required this.onRotationChanged,
    required this.onDelete,
  });

  @override
  State<StickerLayer> createState() => _StickerLayerState();
}

class _StickerLayerState extends State<StickerLayer> {
  Offset _position = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  Offset _lastFocalPoint = Offset.zero;
  double _baseScale = 1.0;
  double _baseRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _position = widget.sticker.position;
    _scale = widget.sticker.scale;
    _rotation = widget.sticker.rotation;
  }

  @override
  void didUpdateWidget(StickerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sticker != widget.sticker) {
      _position = widget.sticker.position;
      _scale = widget.sticker.scale;
      _rotation = widget.sticker.rotation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanUpdate: _handlePanUpdate,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: Transform.rotate(
          angle: _rotation,
          child: Transform.scale(
            scale: _scale,
            child: Stack(
              children: [
                _buildSticker(),
                if (widget.isSelected) _buildSelectionBorder(),
                if (widget.isSelected) _buildDeleteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSticker() {
    const stickerSize = 100.0;

    return Container(
      width: stickerSize,
      height: stickerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: widget.sticker.isEmoji
          ? Center(
              child: Text(
                widget.sticker.emoji!,
                style: const TextStyle(
                  fontSize: 72,
                ),
              ),
            )
          : Image.asset(
              widget.sticker.assetPath,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to emoji if asset not found
                return Center(
                  child: Text(
                    widget.sticker.emoji ?? '❓',
                    style: const TextStyle(fontSize: 72),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSelectionBorder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Positioned(
      top: -12,
      right: -12,
      child: GestureDetector(
        onTap: widget.onDelete,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
    widget.onPositionChanged(_position);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _baseScale = _scale;
    _baseRotation = _rotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      // Single finger - drag
      final delta = details.focalPoint - _lastFocalPoint;
      setState(() {
        _position += delta;
      });
      widget.onPositionChanged(_position);
      _lastFocalPoint = details.focalPoint;
    } else if (details.pointerCount == 2) {
      // Two fingers - scale and rotate
      setState(() {
        _scale = _baseScale * details.scale;
        _scale = _scale.clamp(0.3, 3.0); // Limit scale range

        _rotation = _baseRotation + details.rotation;
      });
      widget.onScaleChanged(_scale);
      widget.onRotationChanged(_rotation);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _baseScale = _scale;
    _baseRotation = _rotation;
  }
}

/// Widget for managing all stickers on the canvas
class StickerCanvas extends StatelessWidget {
  final List<StickerModel> stickers;
  final String? selectedStickerId;
  final Function(String) onStickerTap;
  final Function(String, Offset) onStickerPositionChanged;
  final Function(String, double) onStickerScaleChanged;
  final Function(String, double) onStickerRotationChanged;
  final Function(String) onStickerDelete;
  final Size canvasSize;

  const StickerCanvas({
    super.key,
    required this.stickers,
    required this.selectedStickerId,
    required this.onStickerTap,
    required this.onStickerPositionChanged,
    required this.onStickerScaleChanged,
    required this.onStickerRotationChanged,
    required this.onStickerDelete,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: Stack(
        children: stickers.map((sticker) {
          return StickerLayer(
            key: ValueKey(sticker.id),
            sticker: sticker,
            isSelected: sticker.id == selectedStickerId,
            onTap: () => onStickerTap(sticker.id),
            onPositionChanged: (position) =>
                onStickerPositionChanged(sticker.id, position),
            onScaleChanged: (scale) =>
                onStickerScaleChanged(sticker.id, scale),
            onRotationChanged: (rotation) =>
                onStickerRotationChanged(sticker.id, rotation),
            onDelete: () => onStickerDelete(sticker.id),
          );
        }).toList(),
      ),
    );
  }
}
