class ComplaintResponseModel {
  final String id;
  final String message;
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final DateTime timestamp;

  const ComplaintResponseModel({
    required this.id,
    required this.message,
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
  });

  // Create from JSON
  factory ComplaintResponseModel.fromJson(Map<String, dynamic> json) {
    return ComplaintResponseModel(
      id: json['id'] as String,
      message: json['message'] as String,
      success: json['success'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'success': success,
      'data': data,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create success response
  factory ComplaintResponseModel.success({
    required String id,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return ComplaintResponseModel(
      id: id,
      message: message,
      success: true,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  // Create error response
  factory ComplaintResponseModel.error({
    required String id,
    required String message,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return ComplaintResponseModel(
      id: id,
      message: message,
      success: false,
      error: error,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  // Copy with method
  ComplaintResponseModel copyWith({
    String? id,
    String? message,
    bool? success,
    Map<String, dynamic>? data,
    String? error,
    DateTime? timestamp,
  }) {
    return ComplaintResponseModel(
      id: id ?? this.id,
      message: message ?? this.message,
      success: success ?? this.success,
      data: data ?? this.data,
      error: error ?? this.error,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ComplaintResponseModel{id: $id, message: $message, success: $success, error: $error}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplaintResponseModel &&
        other.id == id &&
        other.message == message &&
        other.success == success &&
        other.error == error;
  }

  @override
  int get hashCode {
    return id.hashCode ^ message.hashCode ^ success.hashCode ^ error.hashCode;
  }
}
