import 'dart:async';
import 'dart:collection';

/// Rate limiter for controlling API request frequency
/// Wallhaven API limit: 45 requests/minute
class RateLimiter {
  final int maxRequests;
  final Duration period;
  final Queue<DateTime> _requestTimestamps = Queue();
  final _lock = Completer<void>()..complete();

  RateLimiter({
    this.maxRequests = 45,
    this.period = const Duration(minutes: 1),
  });

  /// Acquire request permission, wait if limit is exceeded
  Future<void> acquire() async {
    await _lock.future;

    final now = DateTime.now();

    // Clean up expired timestamps
    while (_requestTimestamps.isNotEmpty &&
        now.difference(_requestTimestamps.first) >= period) {
      _requestTimestamps.removeFirst();
    }

    // If limit is reached, wait for the earliest request to expire
    if (_requestTimestamps.length >= maxRequests) {
      final waitTime = period - now.difference(_requestTimestamps.first);
      if (waitTime.inMilliseconds > 0) {
        await Future.delayed(waitTime + const Duration(milliseconds: 100));
      }
      // Recursive call to ensure quota is available after waiting
      return acquire();
    }

    _requestTimestamps.add(now);
  }

  /// Get current available request quota
  int get availableQuota {
    final now = DateTime.now();
    int count = 0;
    for (final timestamp in _requestTimestamps) {
      if (now.difference(timestamp) < period) {
        count++;
      }
    }
    return maxRequests - count;
  }
}
