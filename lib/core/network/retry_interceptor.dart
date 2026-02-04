import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['retryCount'] ??= 0;
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      await Future.delayed(retryDelay * (retryCount + 1));
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return super.onError(e, handler);
        }
        return super.onError(
          DioException(requestOptions: err.requestOptions, error: e),
          handler,
        );
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
