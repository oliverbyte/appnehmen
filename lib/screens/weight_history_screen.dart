import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';

// Helper function to format numbers with German comma
String _formatGermanNumber(double number, int decimalPlaces) {
  return number.toStringAsFixed(decimalPlaces).replaceAll('.', ',');
}

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

enum TimeRange {
  sevenDays('7 Tage', 7),
  fourteenDays('14 Tage', 14),
  fourWeeks('4 Wochen', 28),
  threeMonths('3 Monate', 90),
  sixMonths('6 Monate', 180),
  oneYear('1 Jahr', 365),
  fiveYears('5 Jahre', 1825),
  tenYears('10 Jahre', 3650);

  final String label;
  final int days;
  const TimeRange(this.label, this.days);
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  final _storageService = StorageService();
  List<WeightEntry> _history = [];
  double? _targetWeight;
  double? _currentWeight;
  bool _isLoading = true;
  TimeRange _selectedTimeRange = TimeRange.fourWeeks;

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackScreenView('weight_history');
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _storageService.getWeightHistory();
    final userData = await _storageService.getUserData();
    setState(() {
      _history = history;
      _targetWeight = userData?['targetWeight'] as double?;
      _currentWeight = userData?['currentWeight'] as double?;
      _isLoading = false;
    });
  }

  Future<void> _showAddWeightDialog() async {
    final weightController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Gewicht eintragen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Gewicht (kg)',
                hintText: 'z.B. 75,5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              autofocus: true,
            ),
            if (_currentWeight != null) ...[
              const SizedBox(height: 12),
              Text(
                'Dein aktuelles Gewicht: ${_formatGermanNumber(_currentWeight!, 1)} kg',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final normalizedText = weightController.text.replaceAll(',', '.');
              final weight = double.tryParse(normalizedText);
              if (weight != null && weight > 0 && weight < 500) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Bitte gib ein gültiges Gewicht ein'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Speichern',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result == true && weightController.text.isNotEmpty) {
      final normalizedText = weightController.text.replaceAll(',', '.');
      final weight = double.parse(normalizedText);
      
      await _storageService.addWeightEntry(weight);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gewicht gespeichert: ${_formatGermanNumber(weight, 1)} kg'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_history.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Gewichtsverlauf'),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Noch keine Einträge',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Füge dein erstes Gewicht hinzu!',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Filter history based on selected time range
    final now = DateTime.now();
    // Set cutoff to start of the day to ensure we include all entries from that day
    final cutoffDateTime = now.subtract(Duration(days: _selectedTimeRange.days));
    final cutoffDate = DateTime(cutoffDateTime.year, cutoffDateTime.month, cutoffDateTime.day);
    final filteredHistory = _history.where((entry) => !entry.date.isBefore(cutoffDate)).toList();
    
    // Use filtered history for chart, or show all if filtered is empty
    final chartHistory = filteredHistory.isEmpty ? _history : filteredHistory;

    final minWeight = chartHistory.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = chartHistory.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final chartMinY = (minWeight - weightRange * 0.1).floorToDouble();
    final chartMaxY = (maxWeight + weightRange * 0.1).ceilToDouble();

    // Calculate trend line using linear regression
    List<FlSpot> trendSpots = [];
    Color trendColor = Colors.grey;
    
    if (chartHistory.length >= 2) {
      final n = chartHistory.length;
      double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
      
      for (int i = 0; i < n; i++) {
        final x = i.toDouble();
        final y = chartHistory[i].weight;
        sumX += x;
        sumY += y;
        sumXY += x * y;
        sumXX += x * x;
      }
      
      final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
      final intercept = (sumY - slope * sumX) / n;
      
      // Generate trend line points
      trendSpots = [
        FlSpot(0, intercept),
        FlSpot(n - 1, slope * (n - 1) + intercept),
      ];
      
      // Determine trend color based on slope
      const threshold = 0.05; // kg per entry threshold for "neutral"
      if (slope.abs() < threshold) {
        trendColor = Colors.grey[600]!; // Neutral
      } else if (slope > 0) {
        trendColor = Colors.red[600]!; // Increasing (bad)
      } else {
        trendColor = Colors.green[600]!; // Decreasing (good)
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gewichtsverlauf'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildTimeRangeSelector(),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    minY: chartMinY,
                    maxY: chartMaxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.grey[800]!,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.asMap().entries.map((entry) {
                            // Only show tooltip for the first line (weight data), not the target line
                            if (entry.key == 0) {
                              return LineTooltipItem(
                                _formatGermanNumber(entry.value.y, 1),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()} kg',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < chartHistory.length) {
                              final date = chartHistory[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('dd.MM').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartHistory
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
                            .toList(),
                        isCurved: true,
                        color: Colors.green[600],
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green[100]!.withValues(alpha: 0.3),
                        ),
                      ),
                      // Trend line
                      if (trendSpots.isNotEmpty)
                        LineChartBarData(
                          spots: trendSpots,
                          isCurved: false,
                          color: trendColor,
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          dashArray: [8, 4],
                        ),
                      if (_targetWeight != null)
                        LineChartBarData(
                          spots: [
                            FlSpot(0, _targetWeight!),
                            FlSpot(chartHistory.length.toDouble() - 1, _targetWeight!),
                          ],
                          isCurved: false,
                          color: Colors.green[600],
                          barWidth: 2,
                          dashArray: [5, 5],
                          dotData: const FlDotData(show: false),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddWeightDialog,
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    'Neues Gewicht eintragen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TimeRange.values.map((range) {
            final isSelected = _selectedTimeRange == range;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  range.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTimeRange = range;
                    });
                  }
                },
                selectedColor: Colors.green[600],
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                side: BorderSide(
                  color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
                  width: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final startWeight = _history.first.weight;
    final currentWeight = _history.last.weight;
    final weightLoss = startWeight - currentWeight;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Startgewicht',
            '${_formatGermanNumber(startWeight, 1)} kg',
            Icons.play_arrow,
            Colors.grey,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Aktuell',
            '${_formatGermanNumber(currentWeight, 1)} kg',
            Icons.monitor_weight,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            weightLoss >= 0 ? 'Verloren' : 'Zugenommen',
            '${_formatGermanNumber(weightLoss.abs(), 1)} kg',
            weightLoss >= 0 ? Icons.trending_down : Icons.trending_up,
            weightLoss >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color[700], size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color[700]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alle Einträge (${_history.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._history.reversed.map((entry) {
          final index = _history.indexOf(entry);
          final isFirst = index == 0;
          final change = isFirst
              ? 0.0
              : entry.weight - _history[index - 1].weight;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy - HH:mm').format(entry.date),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (!isFirst)
                        Text(
                          change >= 0 ? '+${_formatGermanNumber(change, 1)} kg' : '${_formatGermanNumber(change, 1)} kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: change >= 0 ? Colors.red[600] : Colors.green[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${_formatGermanNumber(entry.weight, 1)} kg',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
