import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/cyberpunk_theme.dart';
import '../widgets/cyberpunk_character.dart';
import '../models/car_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _pickupLocation = 'Downtown Branch';
  String _dropoffLocation = 'Downtown Branch';
  bool _includeInsurance = true;
  bool _includeGPS = false;
  bool _includeChildSeat = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Car car = ModalRoute.of(context)!.settings.arguments as Car;

    return Scaffold(
      appBar: AppBar(title: CyberpunkTheme.neonText('BOOK VEHICLE')),
      body: Container(
        decoration: BoxDecoration(gradient: CyberpunkTheme.backgroundGradient),
        child: FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car summary
                _buildCarSummary(car),

                const SizedBox(height: 30),

                // Date selection
                _buildDateSelection(),

                const SizedBox(height: 30),

                // Location selection
                _buildLocationSelection(),

                const SizedBox(height: 30),

                // Additional services
                _buildAdditionalServices(),

                const SizedBox(height: 40),

                // Booking summary
                _buildBookingSummary(car),

                const SizedBox(height: 30),

                // Book button
                _buildBookButton(car),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarSummary(Car car) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(car.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.fullName,
                  style: TextStyle(
                    color: CyberpunkTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  car.displayPrice,
                  style: TextStyle(
                    color: CyberpunkTheme.primaryNeon,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rajdhani',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Dates',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker('Start Date', _startDate, () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              }),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildDatePicker('End Date', _endDate, () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: CyberpunkTheme.darkSurface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: CyberpunkTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: CyberpunkTheme.textSecondary,
                fontSize: 12,
                fontFamily: 'Rajdhani',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: TextStyle(
                color: date != null
                    ? CyberpunkTheme.textPrimary
                    : CyberpunkTheme.textMuted,
                fontSize: 16,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup & Drop-off',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 15),
        _buildLocationDropdown('Pickup Location', _pickupLocation, (value) {
          setState(() {
            _pickupLocation = value!;
          });
        }),
        const SizedBox(height: 15),
        _buildLocationDropdown('Drop-off Location', _dropoffLocation, (value) {
          setState(() {
            _dropoffLocation = value!;
          });
        }),
      ],
    );
  }

  Widget _buildLocationDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: CyberpunkTheme.darkSurface,
        style: TextStyle(
          color: CyberpunkTheme.textPrimary,
          fontFamily: 'Rajdhani',
        ),
        underline: Container(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(
            value: 'Downtown Branch',
            child: Text('Downtown Branch'),
          ),
          DropdownMenuItem(
            value: 'Airport Branch',
            child: Text('Airport Branch'),
          ),
          DropdownMenuItem(
            value: 'Shopping Mall',
            child: Text('Shopping Mall'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Services',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 15),
        _buildServiceOption(
          'Insurance Coverage',
          'Comprehensive protection for your rental',
          '\$25/day',
          _includeInsurance,
          (value) {
            setState(() {
              _includeInsurance = value!;
            });
          },
        ),
        const SizedBox(height: 10),
        _buildServiceOption(
          'GPS Navigation',
          'Never get lost with built-in navigation',
          '\$10/day',
          _includeGPS,
          (value) {
            setState(() {
              _includeGPS = value!;
            });
          },
        ),
        const SizedBox(height: 10),
        _buildServiceOption(
          'Child Seat',
          'Safety seat for children under 12',
          '\$15/day',
          _includeChildSeat,
          (value) {
            setState(() {
              _includeChildSeat = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildServiceOption(
    String title,
    String description,
    String price,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: CyberpunkTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: CyberpunkTheme.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Rajdhani',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: TextStyle(
                    color: CyberpunkTheme.primaryNeon,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: CyberpunkTheme.primaryNeon,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(Car car) {
    int days = 0;
    if (_startDate != null && _endDate != null) {
      days = _endDate!.difference(_startDate!).inDays;
    }

    double basePrice = car.pricePerDay * days.toDouble();
    double insuranceCost = _includeInsurance ? 25.0 * days.toDouble() : 0.0;
    double gpsCost = _includeGPS ? 10.0 * days.toDouble() : 0.0;
    double childSeatCost = _includeChildSeat ? 15.0 * days.toDouble() : 0.0;
    double total = basePrice + insuranceCost + gpsCost + childSeatCost;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CyberpunkTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberpunkTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: TextStyle(
              color: CyberpunkTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(height: 15),
          _buildSummaryRow(
            'Vehicle (${days} days)',
            '\$${basePrice.toStringAsFixed(2)}',
          ),
          if (_includeInsurance)
            _buildSummaryRow(
              'Insurance',
              '\$${insuranceCost.toStringAsFixed(2)}',
            ),
          if (_includeGPS)
            _buildSummaryRow(
              'GPS Navigation',
              '\$${gpsCost.toStringAsFixed(2)}',
            ),
          if (_includeChildSeat)
            _buildSummaryRow(
              'Child Seat',
              '\$${childSeatCost.toStringAsFixed(2)}',
            ),
          const Divider(color: CyberpunkTheme.borderColor, height: 30),
          _buildSummaryRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal
                  ? CyberpunkTheme.primaryNeon
                  : CyberpunkTheme.textPrimary,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Rajdhani',
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal
                  ? CyberpunkTheme.primaryNeon
                  : CyberpunkTheme.textPrimary,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(Car car) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _startDate != null && _endDate != null
            ? () {
                _showBookingConfirmation(car);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberpunkTheme.primaryNeon,
          foregroundColor: CyberpunkTheme.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
    );
  }

  void _showBookingConfirmation(Car car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CyberpunkTheme.darkSurface,
        title: Text(
          'Booking Confirmed!',
          style: TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontFamily: 'Orbitron',
          ),
        ),
        content: Text(
          'Your booking for ${car.fullName} has been confirmed. You will receive a confirmation email shortly.',
          style: TextStyle(
            color: CyberpunkTheme.textSecondary,
            fontFamily: 'Rajdhani',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'OK',
              style: TextStyle(color: CyberpunkTheme.primaryNeon),
            ),
          ),
        ],
      ),
    );
  }
}
