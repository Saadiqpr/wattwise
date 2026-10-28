import '../models/appliance.dart';

class EnergyCalculator {
  // Total daily energy consumption of all appliances
  static double totalDailyEnergy(List<Appliance> appliances) {
    return appliances.fold(
      0.0,
      (total, appliance) => total + appliance.dailyEnergyKwh,
    );
  }

  // Total monthly energy consumption
  static double totalMonthlyEnergy(List<Appliance> appliances) {
    return totalDailyEnergy(appliances) * 30;
  }

  // Estimated daily electricity cost
  static double totalDailyCost(List<Appliance> appliances, double tariff) {
    return totalDailyEnergy(appliances) * tariff;
  }

  // Estimated monthly electricity cost
  static double totalMonthlyCost(List<Appliance> appliances, double tariff) {
    return totalMonthlyEnergy(appliances) * tariff;
  }

  // Return appliances ranked from highest to lowest daily consumption
  static List<Appliance> rankByConsumption(List<Appliance> appliances) {
    final ranked = List<Appliance>.from(appliances);

    ranked.sort((a, b) => b.dailyEnergyKwh.compareTo(a.dailyEnergyKwh));

    return ranked;
  }

  // Percentage of total daily consumption used by an appliance
  static double usagePercentage(
    Appliance appliance,
    List<Appliance> appliances,
  ) {
    final total = totalDailyEnergy(appliances);

    if (total <= 0) {
      return 0;
    }

    return (appliance.dailyEnergyKwh / total) * 100;
  }

  // Estimated savings from reducing an appliance's daily usage
  static double monthlySavings({
    required Appliance appliance,
    required double reducedHoursPerDay,
    required double tariff,
  }) {
    final savedHours = appliance.hoursPerDay - reducedHoursPerDay;

    if (savedHours <= 0) {
      return 0;
    }

    final savedEnergy =
        (appliance.powerWatts * savedHours * appliance.quantity) / 1000;

    return savedEnergy * 30 * tariff;
  }
}
