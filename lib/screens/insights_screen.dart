import 'package:flutter/material.dart';

import '../models/appliance.dart';
import '../utils/energy_calculator.dart';

const Color green = Color(0xFF229B62);
const Color blue = Color(0xFF219EBC);
const Color orange = Color(0xFFF59E0B);
const Color ink = Color(0xFF172437);
const Color purpleColor = Color(0xFF8875E8);
const Color pink = Color(0xFFE879A9);

class InsightsScreen extends StatelessWidget {
  final List<Appliance> appliances;
  final double tariff;

  const InsightsScreen({
    super.key,
    required this.appliances,
    required this.tariff,
  });

  @override
  Widget build(BuildContext context) {
    final ranked = EnergyCalculator.rankByConsumption(appliances);
    final dailyEnergy = EnergyCalculator.totalDailyEnergy(appliances);
    final monthlyEnergy = EnergyCalculator.totalMonthlyEnergy(appliances);
    final monthlyCost = EnergyCalculator.totalMonthlyCost(appliances, tariff);

    final topAppliance = ranked.isNotEmpty ? ranked.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Energy Insights',
          style: TextStyle(fontWeight: FontWeight.bold, color: ink),
        ),
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8875E8), Color(0xFF6253C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Your Energy Overview',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs ${monthlyCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Estimated monthly electricity cost',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryMetric(
                          'Daily usage',
                          '${dailyEnergy.toStringAsFixed(2)} kWh',
                        ),
                      ),
                      Expanded(
                        child: _summaryMetric(
                          'Monthly usage',
                          '${monthlyEnergy.toStringAsFixed(1)} kWh',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Energy analytics section
            const Text(
              'Energy Analytics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),

            _consumptionChart(ranked),

            const SizedBox(height: 18),

            _distributionChart(ranked),

            const SizedBox(height: 25),

            // Consumption breakdown
            const Text(
              'Consumption Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),

            if (ranked.isEmpty)
              _emptyCard(
                icon: Icons.electrical_services_rounded,
                title: 'No appliances yet',
                message:
                    'Add appliances to see your energy consumption insights.',
              )
            else
              ...ranked.asMap().entries.map((entry) {
                final index = entry.key;
                final appliance = entry.value;
                final share = EnergyCalculator.usagePercentage(
                  appliance,
                  appliances,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _colorForIndex(index).withAlpha(25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _iconForName(appliance.name),
                          color: _colorForIndex(index),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appliance.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${appliance.dailyEnergyKwh.toStringAsFixed(2)} kWh/day',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 9),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (share / 100).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE8EDF3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _colorForIndex(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${share.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs ${appliance.monthlyCost(tariff).toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 25),

            // Recommendations section
            const Text(
              'Smart Recommendations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),

            ..._buildRecommendations(ranked, dailyEnergy),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Bar chart showing the daily consumption of the top six appliances.
  Widget _consumptionChart(List<Appliance> ranked) {
    final topAppliances = ranked.take(6).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Consumption',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Compare energy use by appliance',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 20),

          if (topAppliances.isEmpty)
            const _ChartEmptyState(
              message: 'Add appliances to generate your chart.',
            )
          else
            ...topAppliances.asMap().entries.map((entry) {
              final index = entry.key;
              final appliance = entry.value;
              final maximum = topAppliances.first.dailyEnergyKwh;

              final barValue = maximum <= 0
                  ? 0.0
                  : (appliance.dailyEnergyKwh / maximum)
                        .clamp(0.0, 1.0)
                        .toDouble();

              return Padding(
                padding: const EdgeInsets.only(bottom: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appliance.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${appliance.dailyEnergyKwh.toStringAsFixed(2)} kWh',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: barValue,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFE8EDF3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _colorForIndex(index),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Distribution chart showing each appliance's percentage of total usage.
  Widget _distributionChart(List<Appliance> ranked) {
    final total = EnergyCalculator.totalDailyEnergy(ranked);

    final colors = <Color>[
      green,
      blue,
      orange,
      purpleColor,
      pink,
      const Color(0xFF5B8DEF),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Energy Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Share of total daily electricity use',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 18),

          if (ranked.isEmpty || total <= 0)
            const _ChartEmptyState(
              message: 'Usage distribution will appear once energy use is above zero.',
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: ranked.asMap().entries.map((entry) {
                    final index = entry.key;
                    final appliance = entry.value;
                    final share = appliance.dailyEnergyKwh / total;

                    return Expanded(
                      flex: (share * 10000).round().clamp(1, 10000),
                      child: Container(color: colors[index % colors.length]),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),

            ...ranked.asMap().entries.map((entry) {
              final index = entry.key;
              final appliance = entry.value;
              final share = total <= 0
                  ? 0.0
                  : (appliance.dailyEnergyKwh / total) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        appliance.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: ink),
                      ),
                    ),
                    Text(
                      '${share.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRecommendations(
    List<Appliance> ranked,
    double dailyEnergy,
  ) {
    if (ranked.isEmpty || dailyEnergy <= 0) {
      return [
        _recommendationCard(
          icon: Icons.lightbulb_outline_rounded,
          color: orange,
          title: 'Start tracking your energy',
          message: 'Add your household appliances and their daily usage to receive personalized suggestions.',
        ),
      ];
    }

    final top = ranked.first;
    final topShare = EnergyCalculator.usagePercentage(top, ranked);

    final recommendations = <Widget>[
      _recommendationCard(
        icon: Icons.bolt_rounded,
        color: orange,
        title: 'Focus on ${top.name}',
        message:
            'It is your highest energy consumer at ${topShare.toStringAsFixed(1)}% of daily usage. Reducing its operating time may lower your bill.',
      ),
    ];

    if (top.hoursPerDay >= 5) {
      recommendations.add(
        _recommendationCard(
          icon: Icons.schedule_rounded,
          color: blue,
          title: 'Review operating hours',
          message:
              '${top.name} runs for ${top.hoursPerDay.toStringAsFixed(1)} hours per day. Try reducing its use where practical.',
        ),
      );
    }

    recommendations.add(
      _recommendationCard(
        icon: Icons.eco_outlined,
        color: green,
        title: 'Set a realistic energy goal',
        message: 'Try reducing your household electricity use by 5–10% this month and compare your estimated usage again.',
      ),
    );

    return recommendations;
  }

  Widget _recommendationCard({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ink,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: green, size: 38),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE9EEF4)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(8),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Color _colorForIndex(int index) {
    const colors = <Color>[
      green,
      blue,
      orange,
      purpleColor,
      pink,
      Color(0xFF5B8DEF),
    ];

    return colors[index % colors.length];
  }

  IconData _iconForName(String name) {
    final value = name.toLowerCase();

    if (value.contains('ac') ||
        value.contains('air conditioner') ||
        value.contains('fan')) {
      return Icons.ac_unit_rounded;
    }

    if (value.contains('light') || value.contains('bulb')) {
      return Icons.lightbulb_outline_rounded;
    }

    if (value.contains('fridge') || value.contains('refrigerator')) {
      return Icons.kitchen_rounded;
    }

    if (value.contains('tv') || value.contains('television')) {
      return Icons.tv_rounded;
    }

    if (value.contains('washing')) {
      return Icons.local_laundry_service_rounded;
    }

    if (value.contains('computer') || value.contains('laptop')) {
      return Icons.computer_rounded;
    }

    if (value.contains('iron')) {
      return Icons.iron_rounded;
    }

    return Icons.electrical_services_rounded;
  }
}

class _ChartEmptyState extends StatelessWidget {
  final String message;

  const _ChartEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              size: 38,
              color: Color(0xFF9AA7B5),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
