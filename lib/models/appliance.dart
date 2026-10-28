class Appliance {
  final String name;
  final double powerWatts;
  final double hoursPerDay;
  final int quantity;

  Appliance({
    required this.name,
    required this.powerWatts,
    required this.hoursPerDay,
    this.quantity = 1,
  });

  double get dailyEnergyKwh => (powerWatts * hoursPerDay * quantity) / 1000;

  double get monthlyEnergyKwh => dailyEnergyKwh * 30;

  double dailyCost(double tariff) => dailyEnergyKwh * tariff;

  double monthlyCost(double tariff) => monthlyEnergyKwh * tariff;

  // Convert an appliance into JSON-compatible data.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'powerWatts': powerWatts,
      'hoursPerDay': hoursPerDay,
      'quantity': quantity,
    };
  }

  // Re-create an appliance from saved JSON data.
  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      name: json['name'] as String,
      powerWatts: (json['powerWatts'] as num).toDouble(),
      hoursPerDay: (json['hoursPerDay'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}
