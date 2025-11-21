import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';

// Helper function to format numbers with German comma
String _formatGermanNumber(double number, int decimalPlaces) {
  return number.toStringAsFixed(decimalPlaces).replaceAll('.', ',');
}

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  final _storageService = StorageService();
  List<WeightEntry> _history = [];
  double? _targetWeight;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final history = await _storageService.getWeightHistory();
    final userData = await _storageService.getUserData();
    setState(() {
      _history = history;
      _targetWeight = userData?['targetWeight'] as double?;
      _isLoading = false;
    });
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

    final minWeight = _history.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = _history.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final chartMinY = (minWeight - weightRange * 0.1).floorToDouble();
    final chartMaxY = (maxWeight + weightRange * 0.1).ceilToDouble();

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
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: LineChart(
                  LineChartData(
                    minY: chartMinY,
                    maxY: chartMaxY,
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
                            if (value.toInt() >= 0 && value.toInt() < _history.length) {
                              final date = _history[value.toInt()].date;
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
                      show: true,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _history
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
                      if (_targetWeight != null)
                        LineChartBarData(
                          spots: [
                            FlSpot(0, _targetWeight!),
                            FlSpot(_history.length.toDouble() - 1, _targetWeight!),
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
              _buildHistoryList(),
            ],
          ),
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
