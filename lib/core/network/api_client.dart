import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  static const String _baseUrl = 'https://firestore.googleapis.com/v1/';

  ApiClient() {
    _dio = Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token if available
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request in debug mode
          _logRequest(options);

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) async {
          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              // Retry original request
              final newToken = await _getAuthToken();
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final response = await _dio.fetch(error.requestOptions);
                handler.resolve(response);
                return;
              }
            } catch (e) {
              // Token refresh failed, proceed with error
            }
          }

          // Log error in debug mode
          _logError(error);
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during GET request',
        originalException: e,
      );
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during POST request',
        originalException: e,
      );
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during PUT request',
        originalException: e,
      );
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during PATCH request',
        originalException: e,
      );
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during DELETE request',
        originalException: e,
      );
    }
  }

  // File upload
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      await _checkConnectivity();

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during file upload',
        originalException: e,
      );
    }
  }

  // Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _checkConnectivity();

      final response = await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(
        message: 'Unexpected error occurred during file download',
        originalException: e,
      );
    }
  }

  // Check network connectivity
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw const NetworkException(message: 'No internet connection available');
    }
  }

  // Get authentication token
  Future<String?> _getAuthToken() async {
    // TODO: Implement token retrieval from secure storage
    return null;
  }

  // Refresh authentication token
  Future<void> _refreshToken() async {
    // TODO: Implement token refresh logic
  }

  // Handle Dio errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const TimeoutException(
          message: 'Connection timeout. Please check your internet connection.',
          timeout: AppConstants.connectionTimeout,
        );
      case DioExceptionType.sendTimeout:
        return const TimeoutException(
          message: 'Send timeout. Please try again.',
          timeout: AppConstants.connectionTimeout,
        );
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
          message: 'Receive timeout. Please try again.',
          timeout: AppConstants.receiveTimeout,
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: _getErrorMessage(error.response),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled');
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'Connection error. Please check your internet connection.',
        );
      case DioExceptionType.unknown:
      default:
        return UnknownException(
          message: 'An unknown network error occurred',
          originalException: error,
        );
    }
  }

  // Get error message from response
  String _getErrorMessage(Response? response) {
    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;

      // Try to extract error message from common error response formats
      if (data.containsKey('error')) {
        if (data['error'] is Map<String, dynamic>) {
          final errorData = data['error'] as Map<String, dynamic>;
          return errorData['message'] ?? 'Server error occurred';
        } else if (data['error'] is String) {
          return data['error'] as String;
        }
      }

      if (data.containsKey('message')) {
        return data['message'] as String;
      }

      if (data.containsKey('errors') && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) {
          return errors.first.toString();
        }
      }
    }

    return 'Server error occurred (${response?.statusCode ?? 'Unknown'})';
  }

  // Logging methods (only in debug mode)
  void _logRequest(RequestOptions options) {
    // TODO: Implement proper logging
    print('REQUEST: ${options.method} ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      print('QUERY PARAMS: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('DATA: ${options.data}');
    }
  }

  void _logResponse(Response response) {
    // TODO: Implement proper logging
    print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
  }

  void _logError(DioException error) {
    // TODO: Implement proper logging
    print('ERROR: ${error.type} ${error.message}');
    if (error.response != null) {
      print(
        'ERROR RESPONSE: ${error.response?.statusCode} ${error.response?.data}',
      );
    }
  }

  // Dispose resources
  void dispose() {
    _dio.close();
  }
}
