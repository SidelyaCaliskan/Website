import 'package:flutter/material.dart';
import '../../services/nano_banana_service.dart';
import '../../models/nanobana_models.dart' as nb;
import '../../utils/app_constants.dart';

/// Test screen for Nanobana API integration
/// This demonstrates how to use the NanoBananaService
class NanoBananaTestScreen extends StatefulWidget {
  const NanoBananaTestScreen({super.key});

  @override
  State<NanoBananaTestScreen> createState() => _NanoBananaTestScreenState();
}

class _NanoBananaTestScreenState extends State<NanoBananaTestScreen> {
  final TextEditingController _promptController = TextEditingController();
  late NanoBananaService _service;

  bool _isLoading = false;
  String? _imageUrl;
  String? _errorMessage;
  String? _statusMessage;

  nb.AspectRatio _selectedAspectRatio = nb.AspectRatio.square;
  nb.OutputFormat _selectedFormat = nb.OutputFormat.jpeg;

  @override
  void initState() {
    super.initState();
    _service = NanoBananaService(apiKey: AppConstants.falApiKey);
    _promptController.text = 'A spooky haunted house at night with full moon';
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageUrl = null;
      _statusMessage = 'Submitting request...';
    });

    try {
      final response = await _service.generateImage(
        prompt: _promptController.text.trim(),
        aspectRatio: _selectedAspectRatio,
        outputFormat: _selectedFormat,
        onQueueUpdate: (status) {
          setState(() {
            _statusMessage = 'Status: ${status.status}';
            if (status.queuePosition != null) {
              _statusMessage = '$_statusMessage (Position: ${status.queuePosition})';
            }
          });
        },
      );

      setState(() {
        _isLoading = false;
        if (response.images.isNotEmpty) {
          _imageUrl = response.images.first.url;
          _statusMessage = 'Image generated successfully!';
        } else {
          _errorMessage = 'No images generated';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
        _statusMessage = null;
      });
    }
  }

  Future<void> _generateHalloweenFilter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageUrl = null;
      _statusMessage = 'Generating Halloween scene...';
    });

    try {
      // Use generateImage for testing Halloween-themed generation
      final response = await _service.generateImage(
        prompt: 'A spooky night scene with dark blue and purple tones, increased contrast, eerie moonlight, haunting and mysterious atmosphere',
        aspectRatio: _selectedAspectRatio,
        onQueueUpdate: (status) {
          setState(() {
            _statusMessage = 'Status: ${status.status}';
          });
        },
      );

      setState(() {
        _isLoading = false;
        if (response.images.isNotEmpty) {
          _imageUrl = response.images.first.url;
          _statusMessage = 'Halloween scene generated!';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nanobana API Test'),
        backgroundColor: AppConstants.primaryPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.darkPurple,
              AppConstants.primaryPurple.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prompt input
              TextField(
                controller: _promptController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter prompt',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Describe the image you want to generate...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppConstants.primaryOrange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppConstants.primaryOrange.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppConstants.primaryOrange, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Aspect ratio selector
              DropdownButtonFormField<nb.AspectRatio>(
                value: _selectedAspectRatio,
                dropdownColor: AppConstants.darkPurple,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Aspect Ratio',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: nb.AspectRatio.values.map((ratio) {
                  return DropdownMenuItem(
                    value: ratio,
                    child: Text(ratio.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAspectRatio = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Format selector
              DropdownButtonFormField<nb.OutputFormat>(
                value: _selectedFormat,
                dropdownColor: AppConstants.darkPurple,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Output Format',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: nb.OutputFormat.values.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(format.value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFormat = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Generate button
              ElevatedButton(
                onPressed: _isLoading ? null : _generateImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Generate Image',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 12),

              // Quick Halloween filter button
              OutlinedButton(
                onPressed: _isLoading ? null : _generateHalloweenFilter,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppConstants.primaryOrange, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Try Halloween Filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status message
              if (_statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryPurple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Error message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Generated image
              if (_imageUrl != null) ...[
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryOrange.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: const Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}