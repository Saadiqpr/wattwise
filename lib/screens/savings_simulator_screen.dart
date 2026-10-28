import 'package:flutter/material.dart';

import '../models/appliance.dart';
import '../utils/energy_calculator.dart';

class SavingsSimulatorScreen extends StatefulWidget {
  const SavingsSimulatorScreen({
    super.key,
    required this.appliances,
    required this.tariff,
  });

  final List<Appliance> appliances;
  final double tariff;

  @override
  State<SavingsSimulatorScreen> createState() => _SavingsSimulatorScreenState();
}

class _SavingsSimulatorScreenState extends State<SavingsSimulatorScreen> {
  Appliance? _selectedAppliance;
  double? _reducedHours;
  double _targetPercent = 15;

  @override
  void didUpdateWidget(covariant SavingsSimulatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.appliances.contains(_selectedAppliance)) {
      _selectedAppliance = null;
      _reducedHours = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appliances = widget.appliances;
    final totalDailyKwh = EnergyCalculator.totalDailyEnergy(appliances);
    final originalMonthlyCost = EnergyCalculator.totalMonthlyCost(
      appliances,
      widget.tariff,
    );

    final selected = _selectedAppliance;
    final hours =
        _reducedHours ?? (selected == null ? 0 : selected.hoursPerDay);

    final validSelection = selected != null && appliances.contains(selected);

    final savedHours = validSelection
        ? (selected.hoursPerDay - hours).clamp(0.0, 24.0)
        : 0.0;

    final savedDailyKwh = validSelection
        ? selected.powerWatts * savedHours * selected.quantity / 1000
        : 0.0;

    final monthlySavedKwh = savedDailyKwh * 30;
    final monthlySavings = monthlySavedKwh * widget.tariff;
    final newMonthlyCost = (originalMonthlyCost - monthlySavings).clamp(
      0.0,
      double.infinity,
    );

    final estimatedReduction = totalDailyKwh > 0
        ? (savedDailyKwh / totalDailyKwh) * 100
        : 0.0;

    final targetAchieved = estimatedReduction >= _targetPercent;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings Simulator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF229B62), Color(0xFF36B77A)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco_outlined, color: Colors.white, size: 36),
                SizedBox(height: 14),
                Text(
                  'What if you used less?',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Experiment with daily usage and estimate your potential '
                  'electricity and cost savings.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '1. Select an Appliance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172437),
            ),
          ),
          const SizedBox(height: 12),
          if (appliances.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5F8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'No appliances registered. Add an appliance first to '
                'start simulating savings.',
                style: TextStyle(height: 1.5),
              ),
            )
          else
            DropdownButtonFormField<Appliance>(
              initialValue: validSelection ? selected : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Choose appliance',
                prefixIcon: const Icon(
                  Icons.electrical_services,
                  color: Color(0xFF229B62),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: appliances.map((appliance) {
                return DropdownMenuItem(
                  value: appliance,
                  child: Text(
                    '${appliance.name} (${appliance.powerWatts} W)',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (appliance) {
                setState(() {
                  _selectedAppliance = appliance;
                  _reducedHours = appliance?.hoursPerDay;
                });
              },
            ),
          if (validSelection) ...[
            const SizedBox(height: 24),
            const Text(
              '2. Adjust Daily Usage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172437),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Original usage: ${selected.hoursPerDay.toStringAsFixed(1)} '
              'hours per day',
              style: const TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'New daily usage',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${hours.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    color: Color(0xFF229B62),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: hours.clamp(0.0, selected.hoursPerDay),
              min: 0,
              max: selected.hoursPerDay > 0 ? selected.hoursPerDay : 1,
              divisions: selected.hoursPerDay > 0
                  ? (selected.hoursPerDay * 2).round().clamp(1, 48)
                  : 1,
              activeColor: const Color(0xFF229B62),
              label: '${hours.toStringAsFixed(1)} hours',
              onChanged: (value) {
                setState(() {
                  _reducedHours = value;
                });
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Less usage', style: TextStyle(color: Colors.blueGrey)),
                Text(
                  'Original usage',
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          ],
          const SizedBox(height: 25),
          const Text(
            '3. Your Savings Estimate',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172437),
            ),
          ),
          const SizedBox(height: 12),
          _resultCard(
            title: 'Estimated Monthly Savings',
            value: 'Rs. ${monthlySavings.toStringAsFixed(0)}',
            icon: Icons.savings_outlined,
            color: const Color(0xFF229B62),
            background: const Color(0xFFE8F7EF),
          ),
          _resultCard(
            title: 'Energy Saved per Month',
            value: '${monthlySavedKwh.toStringAsFixed(2)} kWh',
            icon: Icons.bolt,
            color: const Color(0xFF219EBC),
            background: const Color(0xFFE6F5F8),
          ),
          _resultCard(
            title: 'New Estimated Monthly Bill',
            value: 'Rs. ${newMonthlyCost.toStringAsFixed(0)}',
            icon: Icons.receipt_long,
            color: const Color(0xFF8875E8),
            background: const Color(0xFFF0EDFF),
          ),
          const SizedBox(height: 20),
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
                const Text(
                  'Monthly Reduction Target',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172437),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set a target for reducing total household energy '
                  'consumption. Current simulated reduction: '
                  '${estimatedReduction.toStringAsFixed(1)}%.',
                  style: const TextStyle(color: Colors.blueGrey, height: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Target'),
                    const Spacer(),
                    Text(
                      '${_targetPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF229B62),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _targetPercent,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: const Color(0xFF229B62),
                  label: '${_targetPercent.toStringAsFixed(0)}%',
                  onChanged: (value) {
                    setState(() {
                      _targetPercent = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      targetAchieved ? Icons.check_circle : Icons.flag_outlined,
                      color: targetAchieved
                          ? const Color(0xFF229B62)
                          : const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        targetAchieved
                            ? 'Target reached in this scenario!'
                            : 'Keep adjusting usage to reach your target.',
                        style: TextStyle(
                          color: targetAchieved
                              ? const Color(0xFF229B62)
                              : const Color(0xFF80551A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'These are simulated estimates based on your entered appliance '
            'ratings and a constant tariff. Actual savings may vary.',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.5),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _resultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172437),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
