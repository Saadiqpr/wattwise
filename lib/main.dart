import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/appliance.dart';
import 'screens/appliances_screen.dart';
import 'screens/bill_estimator_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/savings_simulator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WattWiseApp());
}

class WattWiseApp extends StatefulWidget {
  const WattWiseApp({super.key});

  @override
  State<WattWiseApp> createState() => _WattWiseAppState();
}

class _WattWiseAppState extends State<WattWiseApp> {
  static const String _appliancesKey = 'wattwise_appliances';
  static const String _tariffKey = 'wattwise_tariff';

  List<Appliance> _appliances = [];
  double _tariff = 60.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedAppliances = prefs.getString(_appliancesKey);
      final savedTariff = prefs.getDouble(_tariffKey);

      List<Appliance> loadedAppliances = [];

      if (savedAppliances != null) {
        try {
          final decoded = jsonDecode(savedAppliances) as List<dynamic>;

          loadedAppliances = decoded.map((item) {
            return Appliance.fromJson(Map<String, dynamic>.from(item as Map));
          }).toList();
        } catch (error) {
          debugPrint('Could not read saved appliances: $error');
        }
      }

      if (!mounted) return;

      setState(() {
        _appliances = loadedAppliances;
        _tariff = savedTariff != null && savedTariff > 0 ? savedTariff : 60.0;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Could not load WattWise data: $error');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAppliances(List<Appliance> appliances) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = jsonEncode(
        appliances.map((appliance) => appliance.toJson()).toList(),
      );

      final success = await prefs.setString(_appliancesKey, encoded);

      debugPrint('WattWise save success: $success');
      debugPrint('WattWise saved data: $encoded');
      debugPrint('WattWise stored data: ${prefs.getString(_appliancesKey)}');
    } catch (error, stackTrace) {
      debugPrint('WattWise save failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _saveTariff(double tariff) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_tariffKey, tariff);
    } catch (error) {
      debugPrint('Could not save tariff: $error');
    }
  }

  void _updateAppliances(List<Appliance> updatedAppliances) {
    final updatedList = List<Appliance>.from(updatedAppliances);

    setState(() {
      _appliances = updatedList;
    });

    _saveAppliances(updatedList);
  }

  void _updateTariff(double newTariff) {
    setState(() {
      _tariff = newTariff;
    });

    _saveTariff(newTariff);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WattWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF229B62),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9FC),
          foregroundColor: Color(0xFF172437),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: _isLoading
          ? const Scaffold(
              backgroundColor: Color(0xFFF7F9FC),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF229B62)),
                    SizedBox(height: 16),
                    Text(
                      'Loading WattWise...',
                      style: TextStyle(color: Color(0xFF172437), fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
          : DashboardScreen(
              appliances: _appliances,
              tariff: _tariff,
              onAppliancesChanged: _updateAppliances,
              onTariffChanged: _updateTariff,
            ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.appliances,
    required this.tariff,
    required this.onAppliancesChanged,
    required this.onTariffChanged,
  });

  final List<Appliance> appliances;
  final double tariff;
  final ValueChanged<List<Appliance>> onAppliancesChanged;
  final ValueChanged<double> onTariffChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardContent(
        appliances: widget.appliances,
        tariff: widget.tariff,
        onOpenAppliances: () => _openTab(1),
        onOpenBillEstimator: () => _openTab(2),
        onOpenInsights: () => _openTab(3),
        onOpenSimulator: () => _openTab(4),
      ),
      AppliancesScreen(
        appliances: widget.appliances,
        tariff: widget.tariff,
        onAppliancesChanged: widget.onAppliancesChanged,
      ),
      BillEstimatorScreen(
        appliances: widget.appliances,
        tariff: widget.tariff,
        onTariffChanged: widget.onTariffChanged,
      ),
      InsightsScreen(appliances: widget.appliances, tariff: widget.tariff),
      SavingsSimulatorScreen(
        appliances: widget.appliances,
        tariff: widget.tariff,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _openTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.electrical_services_outlined),
            selectedIcon: Icon(Icons.electrical_services),
            label: 'Appliances',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bill',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Savings',
          ),
        ],
      ),
    );
  }

  void _openTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
