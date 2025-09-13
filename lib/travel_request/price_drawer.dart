// price_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_provider.dart';
import 'models.dart';

class PriceDrawer extends StatefulWidget {
  final AssignedVendor vendor;
  final int requestId;

  const PriceDrawer({Key? key, required this.vendor, required this.requestId})
    : super(key: key);

  @override
  _PriceDrawerState createState() => _PriceDrawerState();
}

class _PriceDrawerState extends State<PriceDrawer> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _otherTripPriceController =
      TextEditingController();
  bool _includePriceForOtherTrip = false;
  BookingRequest? _currentRequest;
  BookingRequest? _otherTripRequest;

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.vendor.price;
    _initializeTripRequests();
  }

  void _initializeTripRequests() {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    // Find current request
    _currentRequest = provider.currentRequests.firstWhere(
      (r) => r.id == widget.requestId,
    );

    // For round trip, find the other trip for the same person
    if (!provider.isOneWay) {
      _otherTripRequest = provider.currentRequests.firstWhere(
        (r) =>
            r.personName == _currentRequest!.personName &&
            r.id != widget.requestId,
        orElse: () => null as BookingRequest,
      );

      // If other trip exists and has this vendor, prefill the price
      if (_otherTripRequest != null) {
        final otherTripVendor = _otherTripRequest!.vendors.firstWhere(
          (v) => v.companyName == widget.vendor.companyName,
          orElse: () => null as AssignedVendor,
        );
        if (otherTripVendor != null) {
          _otherTripPriceController.text = otherTripVendor.price;
        }
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _otherTripPriceController.dispose();
    super.dispose();
  }

  void _submitPrice(bool markAsAwarded) {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final currentPrice = _priceController.text.trim();

    if (currentPrice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a price for the current trip'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Update current trip price
    provider.updateVendorPrice(
      widget.requestId,
      widget.vendor.companyName,
      currentPrice,
      markAsAwarded,
    );

    // If checkbox is checked and we have other trip data
    if (_includePriceForOtherTrip && _otherTripRequest != null) {
      final otherPrice = _otherTripPriceController.text.trim();
      if (otherPrice.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a price for the other trip'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Update other trip price
      provider.updateVendorPrice(
        _otherTripRequest!.id,
        widget.vendor.companyName,
        otherPrice,
        markAsAwarded,
      );
    }

    Navigator.of(context).pop();

    String message = markAsAwarded
        ? 'Price updated and vendor marked as awarded!'
        : 'Price updated successfully!';

    if (_includePriceForOtherTrip && _otherTripRequest != null) {
      message += ' (Both trips updated)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    final isRoundTrip = !provider.isOneWay;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Enter Vendor Price',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 20),

              // Vendor Information
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Company Name', widget.vendor.companyName),
                    _buildInfoRow('City', widget.vendor.city),
                    _buildInfoRow('Category', widget.vendor.category),
                    _buildInfoRow('Contact', widget.vendor.contactNumber),
                    _buildInfoRow('Email', widget.vendor.emailId),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Round Trip Checkbox (only show for round trips)
              if (isRoundTrip && _otherTripRequest != null)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _includePriceForOtherTrip,
                        onChanged: (bool? value) {
                          setState(() {
                            _includePriceForOtherTrip = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Include price for other trip',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Check this if vendor provided combined pricing for both trips',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (isRoundTrip && _otherTripRequest != null)
                SizedBox(height: 20),

              // Other Trip Price Input (show above current trip price if it's return trip)
              if (_includePriceForOtherTrip &&
                  _otherTripRequest != null &&
                  _isReturnTrip())
                Column(
                  children: [
                    _buildPriceSection(
                      'Price for Other Trip',
                      _otherTripRequest?.travelPath ?? '',
                      _otherTripPriceController,
                      false,
                    ),
                    SizedBox(height: 20),
                  ],
                ),

              // Current Trip Price Input
              _buildPriceSection(
                'Price for Current Trip',
                _currentRequest?.travelPath ?? '',
                _priceController,
                true,
              ),

              // Other Trip Price Input (show below current trip price if it's outbound trip)
              if (_includePriceForOtherTrip &&
                  _otherTripRequest != null &&
                  !_isReturnTrip())
                Column(
                  children: [
                    SizedBox(height: 20),
                    _buildPriceSection(
                      'Price for Other Trip',
                      _otherTripRequest?.travelPath ?? '',
                      _otherTripPriceController,
                      false,
                    ),
                  ],
                ),

              SizedBox(height: 50),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitPrice(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitPrice(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Submit & Mark as Awarded',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPriceSection(
    String title,
    String travelPath,
    TextEditingController controller,
    bool isCurrent,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? Colors.blue[300]! : Colors.green[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCurrent ? Colors.blue[700] : Colors.green[700],
            ),
          ),
          if (travelPath.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              travelPath,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter price (e.g., ₹ 50000)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.currency_rupee),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  bool _isReturnTrip() {
    if (_currentRequest == null || _otherTripRequest == null) return false;

    // Simple check: if current trip's "to" location matches other trip's "from" location
    final currentParts = _currentRequest!.travelPath.split(' - ');
    final otherParts = _otherTripRequest!.travelPath.split(' - ');

    if (currentParts.length >= 2 && otherParts.length >= 2) {
      return currentParts[0] == otherParts[1] &&
          currentParts[1] == otherParts[0];
    }

    return false;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
