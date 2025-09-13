// add_person_dialog.dart
import 'package:flutter/material.dart';
import 'dart:math';

class AddPersonDialog extends StatefulWidget {
  final bool isOneWay;
  final Function(
    String personName,
    String fromLocation,
    String toLocation,
    String flightName,
    String flightClass,
    DateTime dateTime,
  )
  onAddPerson;

  const AddPersonDialog({
    Key? key,
    required this.isOneWay,
    required this.onAddPerson,
  }) : super(key: key);

  @override
  _AddPersonDialogState createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _personNameController;
  late TextEditingController _fromLocationController;
  late TextEditingController _toLocationController;
  late TextEditingController _flightNameController;

  String _selectedClass = 'ECO';
  DateTime _selectedDateTime = DateTime.now().add(Duration(days: 1));

  final List<String> _classes = ['ECO', 'BUS', 'FIRST'];

  // Sample data for random generation
  final List<String> _sampleNames = [
    'Mohammed Al Rashid',
    'Sarah Johnson',
    'Ahmed Hassan',
    'Emily Davis',
    'Omar Abdullah',
    'Jessica Wilson',
    'Hassan Al Maktoum',
    'Rachel Smith',
    'Ali Al Zahra',
    'Michelle Brown',
  ];

  final List<String> _sampleLocations = [
    'Dubai, UAE',
    'London, UK',
    'New York, USA',
    'Paris, France',
    'Tokyo, Japan',
    'Singapore',
    'Mumbai, India',
    'Cairo, Egypt',
    'Sydney, Australia',
    'Berlin, Germany',
    'Toronto, Canada',
    'Istanbul, Turkey',
  ];

  final List<String> _airlines = [
    'Emirates',
    'British Airways',
    'Air France',
    'Lufthansa',
    'Qatar Airways',
    'Singapore Airlines',
    'Etihad Airways',
    'KLM',
    'Turkish Airlines',
    'Virgin Atlantic',
  ];

  @override
  void initState() {
    super.initState();
    _generateRandomData();
  }

  void _generateRandomData() {
    final random = Random();

    _personNameController = TextEditingController(
      text: _sampleNames[random.nextInt(_sampleNames.length)],
    );

    final fromIndex = random.nextInt(_sampleLocations.length);
    int toIndex;
    do {
      toIndex = random.nextInt(_sampleLocations.length);
    } while (toIndex == fromIndex); // Ensure different locations

    _fromLocationController = TextEditingController(
      text: _sampleLocations[fromIndex],
    );
    _toLocationController = TextEditingController(
      text: _sampleLocations[toIndex],
    );

    final airline = _airlines[random.nextInt(_airlines.length)];
    final flightNumber = random.nextInt(9000) + 1000;
    _flightNameController = TextEditingController(
      text:
          '$airline ($airline${flightNumber.toString().substring(0, 2)}$flightNumber)',
    );

    _selectedClass = _classes[random.nextInt(_classes.length)];

    // Random future date within next 30 days
    _selectedDateTime = DateTime.now().add(
      Duration(
        days: random.nextInt(30) + 1,
        hours: random.nextInt(24),
        minutes: [0, 15, 30, 45][random.nextInt(4)], // Round to quarter hours
      ),
    );
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _flightNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New ${widget.isOneWay ? "One Way" : "Round Trip"} Request',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _generateRandomData();
                          });
                        },
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Random Data'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 16),

              // Form Fields
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _personNameController,
                      label: 'Person Name',
                      icon: Icons.person,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: _buildDropdownField()),
                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _fromLocationController,
                      label: 'From Location',
                      icon: Icons.flight_takeoff,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _toLocationController,
                      label: 'To Location',
                      icon: Icons.flight_land,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _flightNameController,
                      label: 'Flight Name',
                      icon: Icons.airplanemode_active,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: _buildDateTimeField()),
                ],
              ),
              SizedBox(height: 24),

              // Info Text
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isOneWay ? Colors.blue[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: widget.isOneWay ? Colors.blue : Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.isOneWay
                            ? 'This will create 1 booking request for one-way travel.'
                            : 'This will create 2 booking requests: outbound and return journey.',
                        style: TextStyle(
                          color: widget.isOneWay
                              ? Colors.blue[700]
                              : Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addPerson,
                    icon: Icon(Icons.add),
                    label: Text(
                      'Add ${widget.isOneWay ? "Request" : "Requests"}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedClass,
      decoration: InputDecoration(
        labelText: 'Class',
        prefixIcon: Icon(Icons.airline_seat_recline_extra),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _classes.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedClass = newValue!;
        });
      },
    );
  }

  Widget _buildDateTimeField() {
    return InkWell(
      onTap: _selectDateTime,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey[600]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date & Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '${_selectedDateTime.day} ${_getMonthName(_selectedDateTime.month)} ${_selectedDateTime.year} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addPerson() {
    if (_formKey.currentState!.validate()) {
      widget.onAddPerson(
        _personNameController.text.trim(),
        _fromLocationController.text.trim(),
        _toLocationController.text.trim(),
        _flightNameController.text.trim(),
        _selectedClass,
        _selectedDateTime,
      );
      Navigator.of(context).pop();
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
