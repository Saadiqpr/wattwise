import 'package:flutter/material.dart';

import '../models/appliance.dart';
import '../utils/energy_calculator.dart';

class BillEstimatorScreen extends StatefulWidget {
  const BillEstimatorScreen({
    super.key,
    required this.appliances,
    required this.tariff,
    required this.onTariffChanged,
  });

  final List<Appliance> appliances;
  final double tariff;
  final ValueChanged<double> onTariffChanged;

  @override
  State<BillEstimatorScreen> createState() => _BillEstimatorScreenState();
}

class _BillEstimatorScreenState extends State<BillEstimatorScreen> {
  late final TextEditingController _tariffController;

  @override
  void initState() {
    super.initState();
    _tariffController = TextEditingController(
      text: widget.tariff.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _tariffController.dispose();
    super.dispose();
  }

  void _updateTariff() {
    final value = double.tryParse(_tariffController.text.trim());

    if (value == null || !value.isFinite || value <= 0 || value > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid tariff greater than zero.'),
        ),
      );
      return;
    }

    widget.onTariffChanged(value);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Electricity tariff updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyKwh = EnergyCalculator.totalDailyEnergy(widget.appliances);
    final monthlyKwh = EnergyCalculator.totalMonthlyEnergy(widget.appliances);
    final dailyCost = EnergyCalculator.totalDailyCost(
      widget.appliances,
      widget.tariff,
    );
    final monthlyCost = EnergyCalculator.totalMonthlyCost(
      widget.appliances,
      widget.tariff,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bill Estimator',
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
                colors: [Color(0xFF219EBC), Color(0xFF49B8D1)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calculate_outlined, color: Colors.white, size: 34),
                SizedBox(height: 14),
                Text(
                  'Estimate your electricity bill',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Calculate expected energy costs from the appliances '
                  'you have registered.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Electricity Tariff',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172437),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tariffController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Cost per kWh (Rs.)',
              hintText: 'e.g. 60',
              prefixIcon: const Icon(
                Icons.currency_rupee,
                color: Color(0xFF219EBC),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _updateTariff,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF219EBC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('Update Tariff'),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Estimated Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172437),
            ),
          ),
          const SizedBox(height: 14),
          _resultCard(
            title: 'Daily Consumption',
            value: '${dailyKwh.toStringAsFixed(2)} kWh',
            icon: Icons.bolt,
            color: const Color(0xFF219EBC),
            background: const Color(0xFFE6F5F8),
          ),
          _resultCard(
            title: 'Monthly Consumption',
            value: '${monthlyKwh.toStringAsFixed(2)} kWh',
            icon: Icons.calendar_month,
            color: const Color(0xFF8875E8),
            background: const Color(0xFFF0EDFF),
          ),
          _resultCard(
            title: 'Estimated Daily Cost',
            value: 'Rs. ${dailyCost.toStringAsFixed(2)}',
            icon: Icons.payments_outlined,
            color: const Color(0xFFF59E0B),
            background: const Color(0xFFFFF3E4),
          ),
          _resultCard(
            title: 'Estimated Monthly Cost',
            value: 'Rs. ${monthlyCost.toStringAsFixed(2)}',
            icon: Icons.receipt_long,
            color: const Color(0xFF229B62),
            background: const Color(0xFFE8F7EF),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Note: This is a simplified estimate using a constant tariff '
              'and a 30-day month. Actual bills may include taxes, fixed '
              'charges, and different tariff slabs.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF80551A),
                height: 1.5,
              ),
            ),
          ),
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
