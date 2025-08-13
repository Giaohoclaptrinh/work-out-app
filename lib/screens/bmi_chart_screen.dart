import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common/color_extension.dart';
import '../services/daily_stats_service.dart';
import '../utils/debug_helper.dart';
import '../utils/settings_helper.dart';
import '../widgets/top_notification_banner.dart';

class BMIChartScreen extends StatefulWidget {
  const BMIChartScreen({super.key});

  @override
  State<BMIChartScreen> createState() => _BMIChartScreenState();
}

class _BMIChartScreenState extends State<BMIChartScreen> {
  final DailyStatsService _dailyStatsService = DailyStatsService();
  Map<String, dynamic>? _bmiProgress;
  List<Map<String, dynamic>> _weeklyStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final futures = await Future.wait([
        _dailyStatsService.getBMIProgress(),
        _dailyStatsService.getWeeklyStats(),
      ]);

      setState(() {
        _bmiProgress = futures[0] as Map<String, dynamic>?;
        _weeklyStats = futures[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      DebugHelper.logError('Error loading BMI chart data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsHelper.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'BMI Progress',
          style: SettingsHelper.getTitleStyle(context, color: Colors.white),
        ),
        backgroundColor: TColor.primaryColor1,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBMICard(),
                  const SizedBox(height: 20),
                  _buildChartSection(),
                  const SizedBox(height: 20),
                  _buildWeeklyStatsSection(),
                  const SizedBox(height: 20),
                  _buildLogTodayButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildBMICard() {
    final latestBMI = _getLatestBMI();
    final bmiStatus = _getBMIStatus(latestBMI);
    final bmiColor = _getBMIColor(latestBMI);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bmiColor, bmiColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: bmiColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current BMI',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latestBMI != null ? latestBMI.toStringAsFixed(1) : 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bmiStatus,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBMIIcon(latestBMI),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBMICategoryBar(latestBMI),
        ],
      ),
    );
  }

  Widget _buildBMICategoryBar(double? bmi) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildCategoryItem('Underweight', 18.5, Colors.blue, bmi),
          _buildCategoryItem('Normal', 25.0, Colors.green, bmi),
          _buildCategoryItem('Overweight', 30.0, Colors.orange, bmi),
          _buildCategoryItem('Obese', 40.0, Colors.red, bmi),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    double threshold,
    Color color,
    double? currentBMI,
  ) {
    final isCurrent = currentBMI != null && currentBMI < threshold;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isCurrent ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isCurrent ? color : Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              '< ${threshold.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 8,
                color: isCurrent ? color : Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    final chartData = _getChartData();

    if (chartData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No BMI data available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts and log your weight to see BMI progress',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SettingsHelper.getCardColor(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: TColor.primaryColor1, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'BMI Progress', // Rút gọn title
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TColor.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < chartData.length) {
                          final date = chartData[value.toInt()]['date'];
                          final dateParts = date.split('-');
                          return Text(
                            '${dateParts[1]}/${dateParts[2]}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                ),
                minY: 15,
                maxY: 35,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value['bmi']);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [TColor.primaryColor1, TColor.primaryColor2],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: TColor.primaryColor1,
                          strokeWidth: 3,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          TColor.primaryColor1.withValues(alpha: 0.3),
                          TColor.primaryColor2.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBMIRangeLegend(),
        ],
      ),
    );
  }

  Widget _buildBMIRangeLegend() {
    return Container(
      height: 35, // Giảm chiều cao
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildLegendItem(
              'Under',
              '< 18.5',
              Colors.blue,
            ), // Rút gọn text
          ),
          Expanded(child: _buildLegendItem('Normal', '18.5-25', Colors.green)),
          Expanded(
            child: _buildLegendItem(
              'Over',
              '25-30',
              Colors.orange,
            ), // Rút gọn text
          ),
          Expanded(child: _buildLegendItem('Obese', '> 30', Colors.red)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String range, Color color) {
    return Row(
      children: [
        Container(
          width: 8, // Giảm kích thước
          height: 8, // Giảm kích thước
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1), // Giảm border radius
          ),
        ),
        const SizedBox(width: 2), // Giảm khoảng cách
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 6, // Giảm xuống 6px
                fontWeight: FontWeight.w600,
                color: TColor.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              range,
              style: TextStyle(
                fontSize: 5, // Giảm xuống 5px
                color: Colors.grey.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyStatsSection() {
    if (_weeklyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColor.black,
            ),
          ),
          const SizedBox(height: 16),
          ..._weeklyStats.map((stat) => _buildStatRow(stat)),
        ],
      ),
    );
  }

  Widget _buildStatRow(Map<String, dynamic> stat) {
    final date = stat['date'] ?? '';
    final bmi = stat['bmi'];
    final weight = stat['weight_kg'];
    final netCalories = stat['net_calories_kcal'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TColor.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              bmi != null ? bmi.toStringAsFixed(1) : 'N/A',
              style: TextStyle(
                fontSize: 14,
                color: TColor.primaryColor1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              weight != null
                  ? SettingsHelper.formatWeight(context, (weight as num).toDouble())
                  : 'N/A',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$netCalories kcal',
              style: TextStyle(
                fontSize: 12,
                color: netCalories < 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTodayButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _logTodayStats,
        style: ElevatedButton.styleFrom(
          backgroundColor: TColor.primaryColor1,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Log Today\'s Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  double? _getLatestBMI() {
    if (_bmiProgress != null && _bmiProgress!['series'] != null) {
      final points = _bmiProgress!['series']['bmi']['points'] as List?;
      if (points != null && points.isNotEmpty) {
        final latestPoint = points.last;
        return (latestPoint['y_bmi'] as num?)?.toDouble();
      }
    }
    return null;
  }

  String _getBMIStatus(double? bmi) {
    if (bmi == null) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  IconData _getBMIIcon(double? bmi) {
    if (bmi == null) return Icons.help_outline;
    if (bmi < 18.5) return Icons.trending_down;
    if (bmi < 25) return Icons.check_circle;
    if (bmi < 30) return Icons.trending_up;
    return Icons.warning;
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return TColor.primaryColor1;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  List<Map<String, dynamic>> _getChartData() {
    if (_bmiProgress != null && _bmiProgress!['series'] != null) {
      final points = _bmiProgress!['series']['bmi']['points'] as List?;
      if (points != null) {
        return points.map((point) {
          return {
            'date': point['x_date'] ?? '',
            'bmi': (point['y_bmi'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();
      }
    }
    return [];
  }

  Future<void> _logTodayStats() async {
    try {
      await _dailyStatsService.autoLogTodayStats();

      // Reload data
      await _loadData();

      if (!mounted) return;
      showTopBanner(
        context,
        title: 'Daily Stats',
        message: 'Today\'s stats logged successfully!',
        backgroundColor: Colors.green,
        icon: Icons.check_circle_outline,
      );
    } catch (e) {
      DebugHelper.logError('Error logging today stats: $e');
      if (!mounted) return;
      showTopBanner(
        context,
        title: 'Error',
        message: 'Error: $e',
        backgroundColor: Colors.red,
        icon: Icons.error_outline,
      );
    }
  }
}
