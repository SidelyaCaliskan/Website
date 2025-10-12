import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_constants.dart';

/// Bottom toolbar for editor actions
class BottomToolsBar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool canUndo;
  final bool canRedo;

  const BottomToolsBar({
    super.key,
    this.onUndo,
    this.onRedo,
    this.onSave,
    this.onShare,
    this.canUndo = false,
    this.canRedo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0033).withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryOrange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: Icons.undo,
            label: 'Undo',
            onTap: onUndo,
            isEnabled: canUndo,
          ),
          _buildToolButton(
            icon: Icons.redo,
            label: 'Redo',
            onTap: onRedo,
            isEnabled: canRedo,
          ),
          _buildToolButton(
            icon: Icons.save,
            label: 'Save',
            onTap: onSave,
            isEnabled: true,
          ),
          _buildToolButton(
            icon: Icons.share,
            label: 'Share',
            onTap: onShare,
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isEnabled,
  }) {
    final color = isEnabled
        ? AppConstants.primaryOrange
        : AppConstants.ghostWhite.withOpacity(0.3);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
