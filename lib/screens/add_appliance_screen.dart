import 'package:flutter/material.dart';

import '../models/appliance.dart';

class AddApplianceScreen extends StatefulWidget {
  final Appliance? appliance;

  const AddApplianceScreen({super.key, this.appliance});

  @override
  State<AddApplianceScreen> createState() => _AddApplianceScreenState();
}

class _AddApplianceScreenState extends State<AddApplianceScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _wattsController;
  late final TextEditingController _hoursController;
  late final TextEditingController _quantityController;

  String _category = 'Other';

  final List<String> _categories = [
    'Cooling',
    'Lighting',
    'Kitchen',
    'Electronics',
    'Other',
  ];

  bool get _isEditing => widget.appliance != null;

  @override
  void initState() {
    super.initState();

    final appliance = widget.appliance;

    _nameController = TextEditingController(text: appliance?.name ?? '');
    _wattsController = TextEditingController(
      text: appliance == null ? '' : appliance.powerWatts.toString(),
    );
    _hoursController = TextEditingController(
      text: appliance == null ? '' : appliance.hoursPerDay.toString(),
    );
    _quantityController = TextEditingController(
      text: appliance?.quantity.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wattsController.dispose();
    _hoursController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String? _validateNumber(
    String? value, {
    required String field,
    required double minimum,
    required double maximum,
    bool wholeNumber = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $field';
    }

    final number = double.tryParse(value.trim());

    if (number == null || !number.isFinite) {
      return 'Enter a valid number';
    }

    if (number < minimum || number > maximum) {
      return '$field must be between $minimum and $maximum';
    }

    if (wholeNumber && number != number.roundToDouble()) {
      return 'Enter a whole number';
    }

    return null;
  }

  void _saveAppliance() {
    if (!_formKey.currentState!.validate()) return;

    final appliance = Appliance(
      name: _nameController.text.trim(),
      powerWatts: double.parse(_wattsController.text.trim()),
      hoursPerDay: double.parse(_hoursController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),
    );

    Navigator.pop(context, appliance);
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF229B62);
    const ink = Color(0xFF172437);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Appliance' : 'Add Appliance',
          style: const TextStyle(fontWeight: FontWeight.bold, color: ink),
        ),
        backgroundColor: const Color(0xFFF7F9FC),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.electrical_services_rounded,
                      color: green,
                      size: 35,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Enter the appliance details to estimate '
                        'its electricity consumption.',
                        style: TextStyle(color: ink, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _fieldLabel('Appliance Name'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  hint: 'e.g. Air Conditioner',
                  icon: Icons.devices_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an appliance name';
                  }
                  if (value.trim().length > 40) {
                    return 'Name must be 40 characters or fewer';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _fieldLabel('Category'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _decoration(
                  hint: 'Select category',
                  icon: Icons.category_outlined,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),

              const SizedBox(height: 20),
              _fieldLabel('Power Rating (Watts)'),
              TextFormField(
                controller: _wattsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration(
                  hint: 'e.g. 1500',
                  icon: Icons.bolt_outlined,
                ),
                validator: (value) => _validateNumber(
                  value,
                  field: 'power',
                  minimum: 1,
                  maximum: 100000,
                ),
              ),

              const SizedBox(height: 20),
              _fieldLabel('Hours Used Per Day'),
              TextFormField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration(
                  hint: 'e.g. 5',
                  icon: Icons.schedule_outlined,
                ),
                validator: (value) => _validateNumber(
                  value,
                  field: 'hours',
                  minimum: 0,
                  maximum: 24,
                ),
              ),

              const SizedBox(height: 20),
              _fieldLabel('Quantity'),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: _decoration(
                  hint: 'e.g. 2',
                  icon: Icons.numbers_rounded,
                ),
                validator: (value) => _validateNumber(
                  value,
                  field: 'quantity',
                  minimum: 1,
                  maximum: 1000,
                  wholeNumber: true,
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saveAppliance,
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: Icon(
                    _isEditing ? Icons.save_outlined : Icons.add_rounded,
                  ),
                  label: Text(
                    _isEditing ? 'Save Changes' : 'Add Appliance',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF172437),
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF229B62)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF229B62), width: 1.5),
      ),
    );
  }
}
