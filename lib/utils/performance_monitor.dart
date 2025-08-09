import 'dart:async';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, _PerformanceMetric> _metrics = {};
  final List<String> _logs = [];

  /// Start tracking an operation
  void startOperation(String operationName) {
    _metrics[operationName] = _PerformanceMetric(
      name: operationName,
      startTime: DateTime.now(),
    );
    _log('🚀 Started: $operationName');
  }

  /// End tracking an operation
  void endOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final metric = _metrics[operationName];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      metric.metadata = metadata ?? {};

      final durationMs = metric.duration!.inMilliseconds;
      String emoji = '✅';

      if (durationMs > 3000) {
        emoji = '🐌'; // Very slow
      } else if (durationMs > 1000) {
        emoji = '⚠️'; // Slow
      } else if (durationMs > 500) {
        emoji = '📊'; // Moderate
      }

      _log('$emoji Completed: $operationName (${durationMs}ms)');

      if (metadata != null && metadata.isNotEmpty) {
        final metadataStr = metadata.entries
            .map((e) => '${e.key}: ${e.value}')
            .join(', ');
        _log('   📋 Metadata: $metadataStr');
      }
    }
  }

  /// Log a cache hit
  void logCacheHit(String operation, String cacheKey) {
    _log('📦 Cache HIT: $operation ($cacheKey)');
  }

  /// Log a cache miss
  void logCacheMiss(String operation, String cacheKey) {
    _log('🔄 Cache MISS: $operation ($cacheKey)');
  }

  /// Log a batch operation
  void logBatchOperation(String operation, int itemCount, Duration duration) {
    final durationMs = duration.inMilliseconds;
    final itemsPerSecond = itemCount / (durationMs / 1000);
    _log(
      '⚡ Batch $operation: $itemCount items in ${durationMs}ms (${itemsPerSecond.toStringAsFixed(1)} items/sec)',
    );
  }

  /// Log a query optimization
  void logQueryOptimization(
    String query,
    String optimization,
    Duration savedTime,
  ) {
    _log('🎯 Query Optimized: $query');
    _log('   💡 Optimization: $optimization');
    _log('   ⏱️ Time saved: ${savedTime.inMilliseconds}ms');
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final completedMetrics = _metrics.values
        .where((m) => m.duration != null)
        .toList();

    if (completedMetrics.isEmpty) {
      return {
        'totalOperations': 0,
        'averageDuration': 0,
        'slowestOperation': null,
        'fastestOperation': null,
      };
    }

    final durations = completedMetrics
        .map((m) => m.duration!.inMilliseconds)
        .toList();
    final average = durations.reduce((a, b) => a + b) / durations.length;

    final slowest = completedMetrics.reduce(
      (a, b) => a.duration!.inMilliseconds > b.duration!.inMilliseconds ? a : b,
    );

    final fastest = completedMetrics.reduce(
      (a, b) => a.duration!.inMilliseconds < b.duration!.inMilliseconds ? a : b,
    );

    return {
      'totalOperations': completedMetrics.length,
      'averageDuration': average.round(),
      'slowestOperation': {
        'name': slowest.name,
        'duration': slowest.duration!.inMilliseconds,
      },
      'fastestOperation': {
        'name': fastest.name,
        'duration': fastest.duration!.inMilliseconds,
      },
      'operations': completedMetrics
          .map(
            (m) => {
              'name': m.name,
              'duration': m.duration!.inMilliseconds,
              'metadata': m.metadata,
            },
          )
          .toList(),
    };
  }

  /// Get recent logs
  List<String> getRecentLogs({int limit = 50}) {
    return _logs.length <= limit
        ? List.from(_logs)
        : _logs.sublist(_logs.length - limit);
  }

  /// Clear all metrics and logs
  void clear() {
    _metrics.clear();
    _logs.clear();
    _log('🗑️ Performance monitor cleared');
  }

  /// Print performance report
  void printPerformanceReport() {
    final summary = getPerformanceSummary();

    print('\n📊 PERFORMANCE REPORT');
    print('═' * 50);
    print('Total Operations: ${summary['totalOperations']}');
    print('Average Duration: ${summary['averageDuration']}ms');

    if (summary['slowestOperation'] != null) {
      final slowest = summary['slowestOperation'];
      print('Slowest: ${slowest['name']} (${slowest['duration']}ms)');
    }

    if (summary['fastestOperation'] != null) {
      final fastest = summary['fastestOperation'];
      print('Fastest: ${fastest['name']} (${fastest['duration']}ms)');
    }

    print('\n📋 Recent Operations:');
    final operations = summary['operations'] as List;
    for (final op in operations.take(10)) {
      print('  • ${op['name']}: ${op['duration']}ms');
    }

    print('\n📝 Recent Logs:');
    final recentLogs = getRecentLogs(limit: 10);
    for (final log in recentLogs) {
      print('  $log');
    }
    print('═' * 50);
  }

  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] $message';
    _logs.add(logEntry);
    print(logEntry);

    // Keep only last 100 logs to prevent memory issues
    if (_logs.length > 100) {
      _logs.removeAt(0);
    }
  }
}

class _PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;
  Map<String, dynamic> metadata = {};

  _PerformanceMetric({required this.name, required this.startTime});
}

/// Performance monitoring extensions
extension PerformanceTracker<T> on Future<T> {
  Future<T> trackPerformance(
    String operationName, {
    Map<String, dynamic>? metadata,
  }) async {
    final monitor = PerformanceMonitor();
    monitor.startOperation(operationName);

    try {
      final result = await this;
      monitor.endOperation(operationName, metadata: metadata);
      return result;
    } catch (e) {
      monitor.endOperation(
        operationName,
        metadata: {...?metadata, 'error': e.toString()},
      );
      rethrow;
    }
  }
}
