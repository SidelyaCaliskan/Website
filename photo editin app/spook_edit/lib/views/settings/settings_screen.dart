import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/app_constants.dart';

/// Settings screen for app preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HalloweenGradients.spookyNight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildSettings(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppConstants.primaryOrange,
            iconSize: 28,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Text(
            'Settings',
            style: GoogleFonts.creepster(
              fontSize: 28,
              color: AppConstants.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          title: 'App Info',
          children: [
            _buildListTile(
              icon: Icons.info,
              title: 'Version',
              subtitle: AppConstants.version,
              trailing: null,
            ),
            _buildListTile(
              icon: Icons.description,
              title: 'About',
              subtitle: 'Halloween Photo Editor powered by Nano Banana AI',
              trailing: const Icon(Icons.chevron_right, color: AppConstants.primaryOrange),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: 'API Configuration',
          children: [
            _buildListTile(
              icon: Icons.key,
              title: 'API Key',
              subtitle: 'Configure your Nano Banana API key',
              trailing: const Icon(Icons.chevron_right, color: AppConstants.primaryOrange),
              onTap: () {
                // TODO: Open API key configuration
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: 'Share',
          children: [
            _buildListTile(
              icon: Icons.share,
              title: 'Share App',
              subtitle: 'Tell friends about SpookEdit',
              trailing: const Icon(Icons.chevron_right, color: AppConstants.primaryOrange),
              onTap: () {
                Share.share(
                  'Check out SpookEdit - The best Halloween photo editor! Create spooky masterpieces with AI-powered editing.',
                );
              },
            ),
            _buildListTile(
              icon: Icons.star,
              title: 'Rate App',
              subtitle: 'Show your support',
              trailing: const Icon(Icons.chevron_right, color: AppConstants.primaryOrange),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: 'Legal',
          children: [
            _buildListTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              trailing: const Icon(Icons.chevron_right, color: AppConstants.primaryOrange),
            ),
            _buildListTile(
              icon: Icons.gavel,
              title: 'Terms of Service',
              trailing: const Icon(Icons.chevron_right, color: AppConstants.primaryOrange),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.creepster(
              fontSize: 20,
              color: AppConstants.primaryOrange,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppConstants.primaryPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppConstants.primaryOrange.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryOrange),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppConstants.ghostWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppConstants.ghostWhite.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
