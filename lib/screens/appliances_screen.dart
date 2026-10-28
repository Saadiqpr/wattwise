import 'package:flutter/material.dart';

import '../models/appliance.dart';
import 'add_appliance_screen.dart';

class AppliancesScreen extends StatelessWidget {
  const AppliancesScreen({
    super.key,
    required this.appliances,
    required this.tariff,
    required this.onAppliancesChanged,
  });

  final List<Appliance> appliances;
  final double tariff;
  final ValueChanged<List<Appliance>> onAppliancesChanged;

  Future<void> _addAppliance(BuildContext context) async {
    final appliance = await Navigator.push<Appliance>(
      context,
      MaterialPageRoute(builder: (_) => const AddApplianceScreen()),
    );

    if (appliance != null) {
      onAppliancesChanged([...appliances, appliance]);
    }
  }

  Future<void> _editAppliance(BuildContext context, int index) async {
    final updatedAppliance = await Navigator.push<Appliance>(
      context,
      MaterialPageRoute(
        builder: (_) => AddApplianceScreen(appliance: appliances[index]),
      ),
    );

    if (updatedAppliance != null) {
      final updatedList = List<Appliance>.from(appliances);
      updatedList[index] = updatedAppliance;
      onAppliancesChanged(updatedList);
    }
  }

  void _deleteAppliance(int index) {
    final updatedList = List<Appliance>.from(appliances);
    updatedList.removeAt(index);
    onAppliancesChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Appliances',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _addAppliance(context),
            tooltip: 'Add appliance',
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: appliances.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.electrical_services_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No appliances added yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your appliances to calculate energy usage.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _addAppliance(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Appliance'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bolt,
                          color: Color(0xFF229B62),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Monthly Consumption',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${appliances.fold<double>(0, (sum, item) => sum + item.monthlyEnergyKwh).toStringAsFixed(2)} kWh',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(appliances.length, (index) {
                  final appliance = appliances[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF229B62)
                            .withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.electrical_services,
                          color: Color(0xFF229B62),
                        ),
                      ),
                      title: Text(
                        appliance.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${appliance.powerWatts.toStringAsFixed(0)} W · '
                          '${appliance.hoursPerDay.toStringAsFixed(1)} hours/day · '
                          'Qty: ${appliance.quantity}\n'
                          '${appliance.monthlyEnergyKwh.toStringAsFixed(2)} kWh/month · '
                          'Rs ${appliance.monthlyCost(tariff).toStringAsFixed(0)}/month',
                        ),
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Appliance actions',
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editAppliance(context, index);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, index);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _addAppliance(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Appliance'),
                ),
              ],
            ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int index) async {
    final appliance = appliances[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Appliance?'),
        content: Text('Are you sure you want to delete "${appliance.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _deleteAppliance(index);
    }
  }
}
