import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/halloween_prompt.dart';
import '../../providers/editor_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/spooky_snackbar.dart';

/// Processing Screen - Engaging loading experience during AI transformation
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pumpkinController;
  late AnimationController _glowController;
  late AnimationController _progressController;

  late Animation<double> _pumpkinRotation;
  late Animation<double> _glowAnimation;

  int _currentFactIndex = 0;
  Timer? _factTimer;
  bool _hasStartedProcessing = false;

  final List<String> _halloweenFacts = [
    '🎃 Creating spooky magic...',
    '👻 Summoning Halloween spirits...',
    '🦇 Adding mysterious effects...',
    '🕷️ Weaving spooky details...',
    '🌙 Conjuring moonlight magic...',
    '✨ Applying enchantments...',
    '💀 Perfecting the transformation...',
    '🕸️ Adding final touches...',
    '🧙 Casting Halloween spells...',
    '🎭 Crafting your spooky look...',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startFactRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start processing only once when dependencies are ready
    if (!_hasStartedProcessing) {
      _hasStartedProcessing = true;
      // Schedule processing to start after the current frame is complete
      // This prevents setState/notifyListeners from being called during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startProcessing();
      });
    }
  }

  void _setupAnimations() {
    // Pumpkin rotation animation
    _pumpkinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pumpkinRotation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _pumpkinController,
      curve: Curves.linear,
    ));

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _progressController.forward();
  }

  void _startFactRotation() {
    _factTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentFactIndex = (_currentFactIndex + 1) % _halloweenFacts.length;
        });
      }
    });
  }

  Future<void> _startProcessing() async {
    // Check if widget is still mounted
    if (!mounted) return;

    final prompt = ModalRoute.of(context)?.settings.arguments as HalloweenPrompt?;

    if (prompt == null) {
      if (mounted) {
        SpookySnackbar.showError(context, 'No style selected');
        Navigator.of(context).pop();
      }
      return;
    }

    // Use read instead of watch to avoid dependency on provider changes
    final provider = context.read<EditorProvider>();

    try {
      // Apply the Halloween prompt
      await provider.applyHalloweenPrompt(prompt);

      if (mounted) {
        // Navigate to result screen
        Navigator.of(context).pushReplacementNamed(
          AppConstants.resultRoute,
        );
      }
    } catch (e) {
      if (mounted) {
        SpookySnackbar.showError(
          context,
          'Transformation failed: $e',
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _pumpkinController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _factTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HalloweenGradients.spookyNight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildAnimatedPumpkin(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 24),
                _buildFactText(),
                const SizedBox(height: 40),
                _buildProgressBar(),
                const SizedBox(height: 16),
                _buildStatusText(provider),
                const Spacer(),
                _buildTips(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPumpkin() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pumpkinController, _glowController]),
      builder: (context, child) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryOrange
                    .withValues(alpha: _glowAnimation.value * 0.6),
                blurRadius: 50 * _glowAnimation.value,
                spreadRadius: 20 * _glowAnimation.value,
              ),
            ],
          ),
          child: Transform.rotate(
            angle: _pumpkinRotation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.pumpkinOrange,
                    AppConstants.bloodOrange,
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Transforming Your Photo',
      style: GoogleFonts.creepster(
        fontSize: 32,
        color: AppConstants.primaryOrange,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: AppConstants.primaryOrange.withValues(alpha: 0.5),
            blurRadius: 20,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFactText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        _halloweenFacts[_currentFactIndex],
        key: ValueKey<int>(_currentFactIndex),
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppConstants.ghostWhite.withValues(alpha: 0.9),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: AppConstants.primaryPurple.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progressController.value * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppConstants.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusText(EditorProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppConstants.primaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryOrange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              provider.statusMessage.isEmpty
                  ? 'Processing...'
                  : provider.statusMessage,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppConstants.ghostWhite.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppConstants.candyCornYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pro Tip',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Best results with well-lit photos showing clear facial features!',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppConstants.ghostWhite.withOpacity(0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
