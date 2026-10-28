import 'package:flutter/material.dart';

import '../models/appliance.dart';
import '../utils/energy_calculator.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.appliances,
    required this.tariff,
    required this.onOpenAppliances,
    required this.onOpenBillEstimator,
    required this.onOpenInsights,
    required this.onOpenSimulator,
  });

  final List<Appliance> appliances;
  final double tariff;
  final VoidCallback onOpenAppliances;
  final VoidCallback onOpenBillEstimator;
  final VoidCallback onOpenInsights;
  final VoidCallback onOpenSimulator;

  static const Color green = Color(0xFF229B62);
  static const Color blue = Color(0xFF219EBC);
  static const Color orange = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8875E8);
  static const Color ink = Color(0xFF172437);

  @override
  Widget build(BuildContext context) {
    final dailyKwh = EnergyCalculator.totalDailyEnergy(appliances);
    final monthlyKwh = EnergyCalculator.totalMonthlyEnergy(appliances);
    final monthlyCost = EnergyCalculator.totalMonthlyCost(appliances, tariff);

    final highest = appliances.isEmpty
        ? null
        : EnergyCalculator.rankByConsumption(appliances).first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WattWise',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            Text(
              'Smart Energy Management',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: onOpenInsights,
            tooltip: 'View energy insights',
            icon: const Icon(Icons.insights_outlined, color: ink),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Your Energy Overview',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Understand your usage and find ways to save.',
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 22),

          // Monthly bill summary
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF229B62), Color(0xFF36B77A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.white70),
                    SizedBox(width: 9),
                    Text(
                      'Estimated Monthly Bill',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  'Rs. ${monthlyCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Based on registered appliances • 30 days',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 15),
                Text(
                  'Tariff: Rs. ${tariff.toStringAsFixed(2)} per kWh',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Energy Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Daily Usage',
                  value: '${dailyKwh.toStringAsFixed(2)} kWh',
                  subtitle: 'Per day',
                  icon: Icons.bolt,
                  color: blue,
                  background: const Color(0xFFE6F5F8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Appliances',
                  value: '${appliances.length}',
                  subtitle: 'Registered items',
                  icon: Icons.electrical_services,
                  color: orange,
                  background: const Color(0xFFFFF3E4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Monthly Usage',
                  value: '${monthlyKwh.toStringAsFixed(1)} kWh',
                  subtitle: '30-day estimate',
                  icon: Icons.bar_chart,
                  color: purple,
                  background: const Color(0xFFF0EDFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Top Consumer',
                  value: highest == null ? '—' : highest.name,
                  subtitle: highest == null
                      ? 'Add an appliance'
                      : '${highest.dailyEnergyKwh.toStringAsFixed(2)} kWh/day',
                  icon: Icons.trending_up,
                  color: green,
                  background: const Color(0xFFE8F7EF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // New weekly/monthly chart
          _UsageTrendChart(dailyKwh: dailyKwh, monthlyKwh: monthlyKwh),

          const SizedBox(height: 25),

          // Highest consumption appliance
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5EAF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: orange),
                    SizedBox(width: 9),
                    Text(
                      'Energy Insight',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  highest == null
                      ? 'Your energy report is ready to begin. Add your '
                            'household appliances to see consumption insights.'
                      : '${highest.name} is currently your highest energy '
                            'consumer at '
                            '${highest.dailyEnergyKwh.toStringAsFixed(2)} '
                            'kWh per day. Review its operating hours to '
                            'explore potential savings.',
                  style: const TextStyle(color: Colors.blueGrey, height: 1.6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _quickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Manage Appliances',
                  color: green,
                  onTap: onOpenAppliances,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickAction(
                  icon: Icons.calculate_outlined,
                  label: 'Estimate Bill',
                  color: blue,
                  onTap: onOpenBillEstimator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _quickAction(
                  icon: Icons.insights_outlined,
                  label: 'Energy Insights',
                  color: purple,
                  onTap: onOpenInsights,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickAction(
                  icon: Icons.eco_outlined,
                  label: 'Simulate Savings',
                  color: green,
                  onTap: onOpenSimulator,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          const Text(
            'All figures are estimates based on entered appliance data '
            'and a constant electricity tariff. Trend charts show '
            'projected usage, not recorded historical readings.',
            style: TextStyle(color: Colors.blueGrey, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 8),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 25),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Interactive usage chart with weekly and monthly views.
class _UsageTrendChart extends StatefulWidget {
  final double dailyKwh;
  final double monthlyKwh;

  const _UsageTrendChart({required this.dailyKwh, required this.monthlyKwh});

  @override
  State<_UsageTrendChart> createState() => _UsageTrendChartState();
}

class _UsageTrendChartState extends State<_UsageTrendChart> {
  bool _showWeekly = true;

  static const Color green = Color(0xFF229B62);
  static const Color blue = Color(0xFF219EBC);
  static const Color orange = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8875E8);
  static const Color ink = Color(0xFF172437);

  @override
  Widget build(BuildContext context) {
    final labels = _showWeekly
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['Week 1', 'Week 2', 'Week 3', 'Week 4'];

    // Projections use the current average daily consumption.
    // They are not actual historical meter readings.
    final values = _showWeekly
        ? List<double>.filled(7, widget.dailyKwh)
        : [
            widget.dailyKwh * 7,
            widget.dailyKwh * 7,
            widget.dailyKwh * 7,
            widget.dailyKwh * 9,
          ];

    final periodTotal = values.fold<double>(0, (total, value) => total + value);

    final maxValue = values.fold<double>(
      0,
      (maximum, value) => value > maximum ? value : maximum,
    );

    final average = values.isEmpty ? 0.0 : periodTotal / values.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart_rounded, color: green, size: 25),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Energy Usage Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Estimated electricity consumption',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),

          // Period selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _periodButton(
                    label: 'Weekly',
                    selected: _showWeekly,
                    onTap: () => setState(() => _showWeekly = true),
                  ),
                ),
                Expanded(
                  child: _periodButton(
                    label: 'Monthly',
                    selected: !_showWeekly,
                    onTap: () => setState(() => _showWeekly = false),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showWeekly ? '7-day projection' : '30-day projection',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${periodTotal.toStringAsFixed(2)} kWh',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Avg. ${average.toStringAsFixed(2)} kWh',
                  style: const TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (widget.dailyKwh <= 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: const Column(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 42,
                    color: Color(0xFF9AA7B5),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add appliances to generate your usage chart.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(values.length, (index) {
                  final value = values[index];
                  final ratio = maxValue <= 0
                      ? 0.0
                      : (value / maxValue).clamp(0.0, 1.0).toDouble();

                  final colors = [
                    green,
                    blue,
                    orange,
                    purple,
                    green,
                    blue,
                    orange,
                  ];

                  final barColor = colors[index % colors.length];

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 24,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final barHeight = constraints.maxHeight * ratio;

                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    width: double.infinity,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(7),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 20,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                labels[index],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

          const SizedBox(height: 15),

          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: Colors.blueGrey,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Projection based on current appliance usage. '
                  'Actual daily readings are not stored.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected ? green : Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }
}
