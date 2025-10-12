/// Models for fal.ai Nanobana API
/// Based on: https://fal.ai/models/fal-ai/nano-banana
library;

/// Request model for generating images with Nanobana
class NanoBananaRequest {
  final String prompt;
  final int numImages;
  final String outputFormat;
  final String aspectRatio;
  final bool syncMode;

  const NanoBananaRequest({
    required this.prompt,
    this.numImages = 1,
    this.outputFormat = 'jpeg',
    this.aspectRatio = '1:1',
    this.syncMode = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'num_images': numImages,
      'output_format': outputFormat,
      'aspect_ratio': aspectRatio,
      'sync_mode': syncMode,
    };
  }
}

/// Request model for editing images with Nanobana Edit API
class NanoBananaEditRequest {
  final String prompt;
  final List<String> imageUrls;
  final int numImages;
  final String outputFormat;
  final String? aspectRatio;

  const NanoBananaEditRequest({
    required this.prompt,
    required this.imageUrls,
    this.numImages = 1,
    this.outputFormat = 'jpeg',
    this.aspectRatio,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'image_urls': imageUrls,
      'num_images': numImages,
      'output_format': outputFormat,
      if (aspectRatio != null) 'aspect_ratio': aspectRatio,
    };
  }
}

/// Generated image file information
class NanoBananaImage {
  final String url;
  final String? contentType;
  final String? fileName;
  final int? fileSize;

  const NanoBananaImage({
    required this.url,
    this.contentType,
    this.fileName,
    this.fileSize,
  });

  factory NanoBananaImage.fromJson(Map<String, dynamic> json) {
    return NanoBananaImage(
      url: json['url'] as String,
      contentType: json['content_type'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      if (contentType != null) 'content_type': contentType,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
    };
  }
}

/// Response model for Nanobana API
class NanoBananaResponse {
  final List<NanoBananaImage> images;
  final String? description;

  const NanoBananaResponse({
    required this.images,
    this.description,
  });

  factory NanoBananaResponse.fromJson(Map<String, dynamic> json) {
    return NanoBananaResponse(
      images: (json['images'] as List<dynamic>)
          .map((e) => NanoBananaImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images.map((e) => e.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }
}

/// Queue status response
class NanoBananaQueueStatus {
  final String status; // IN_QUEUE, IN_PROGRESS, COMPLETED, ERROR
  final int? queuePosition;
  final List<String>? logs;

  const NanoBananaQueueStatus({
    required this.status,
    this.queuePosition,
    this.logs,
  });

  factory NanoBananaQueueStatus.fromJson(Map<String, dynamic> json) {
    return NanoBananaQueueStatus(
      status: json['status'] as String,
      queuePosition: json['queue_position'] as int?,
      logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => e['message'] as String)
          .toList(),
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isInQueue => status == 'IN_QUEUE';
  bool get hasError => status == 'ERROR';
}

/// Queue submission response
class NanoBananaQueueSubmission {
  final String requestId;

  const NanoBananaQueueSubmission({required this.requestId});

  factory NanoBananaQueueSubmission.fromJson(Map<String, dynamic> json) {
    return NanoBananaQueueSubmission(
      requestId: json['request_id'] as String,
    );
  }
}

/// Available aspect ratios
enum AspectRatio {
  square('1:1'),
  landscape169('16:9'),
  portrait916('9:16'),
  landscape219('21:9'),
  landscape43('4:3'),
  landscape32('3:2'),
  portrait23('2:3'),
  portrait54('5:4'),
  portrait45('4:5'),
  portrait34('3:4');

  final String value;
  const AspectRatio(this.value);
}

/// Output format options
enum OutputFormat {
  jpeg('jpeg'),
  png('png');

  final String value;
  const OutputFormat(this.value);
}
