// bulk_price_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_provider.dart';
import 'models.dart';

class BulkPriceDrawer extends StatefulWidget {
  final VendorGroup vendorGroup;

  const BulkPriceDrawer({Key? key, required this.vendorGroup})
    : super(key: key);

  @override
  _BulkPriceDrawerState createState() => _BulkPriceDrawerState();
}

class _BulkPriceDrawerState extends State<BulkPriceDrawer> {
  Map<int, TextEditingController> _priceControllers = {};
  Map<int, bool> _includeOtherTripForRequest = {};
  Map<int, TextEditingController> _otherTripControllers = {};
  Map<int, BookingRequest?> _otherTripRequests = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final provider = Provider.of<BookingProvider>(context, listen: false);

    for (var assignedVendor in widget.vendorGroup.assignedVendors) {
      final requestId = assignedVendor.request.id;

      // Initialize price controller with existing price
      _priceControllers[requestId] = TextEditingController(
        text: assignedVendor.vendor.price,
      );

      // Initialize other trip checkbox state
      _includeOtherTripForRequest[requestId] = false;

      // Initialize other trip controller
      _otherTripControllers[requestId] = TextEditingController();

      // Find other trip request for round trips
      if (!provider.isOneWay) {
        try {
          _otherTripRequests[requestId] = provider.currentRequests.firstWhere(
            (r) =>
                r.personName == assignedVendor.request.personName &&
                r.id != requestId,
          );

          // Prefill other trip price if exists
          final otherTrip = _otherTripRequests[requestId];
          if (otherTrip != null) {
            final otherTripVendor = otherTrip.vendors.firstWhere(
              (v) => v.companyName == widget.vendorGroup.companyName,
              orElse: () => AssignedVendor(
                companyName: '',
                contactPerson: '',
                city: '',
                category: '',
                contactNumber: '',
                ticketsIssued: '',
                status: '',
                emailId: '',
                dateSent: '',
                price: '',
                isAwarded: false,
                requestId: 0,
              ),
            );
            if (otherTripVendor.companyName.isNotEmpty) {
              _otherTripControllers[requestId]!.text = otherTripVendor.price;
            }
          }
        } catch (e) {
          _otherTripRequests[requestId] = null;
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var controller in _otherTripControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Method to count blocked paths (already awarded to other vendors)
  int _getBlockedPathsCount() {
    int count = 0;
    for (var assignedVendor in widget.vendorGroup.assignedVendors) {
      if (_isRequestAlreadyAwarded(assignedVendor.request)) {
        count++;
      }

      // Also check other trip if checkbox is selected
      final requestId = assignedVendor.request.id;
      if (_includeOtherTripForRequest[requestId] == true &&
          _otherTripRequests[requestId] != null) {
        if (_isRequestAlreadyAwarded(_otherTripRequests[requestId]!)) {
          count++;
        }
      }
    }
    return count;
  }

  // Method to count available paths (not awarded to other vendors)
  int _getAvailablePathsCount() {
    int count = 0;
    for (var assignedVendor in widget.vendorGroup.assignedVendors) {
      if (!_isRequestAlreadyAwarded(assignedVendor.request)) {
        count++;
      }

      // Also check other trip if checkbox is selected
      final requestId = assignedVendor.request.id;
      if (_includeOtherTripForRequest[requestId] == true &&
          _otherTripRequests[requestId] != null) {
        if (!_isRequestAlreadyAwarded(_otherTripRequests[requestId]!)) {
          count++;
        }
      }
    }
    return count;
  }

  void _submitPrices(bool markAsAwarded) {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    Map<int, String> prices = {};
    Map<int, String> otherTripPrices = {};

    // Validate and collect prices
    for (var assignedVendor in widget.vendorGroup.assignedVendors) {
      final requestId = assignedVendor.request.id;

      // Skip if already awarded to another vendor
      if (_isRequestAlreadyAwarded(assignedVendor.request)) {
        continue;
      }

      final price = _priceControllers[requestId]!.text.trim();

      if (price.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter price for ${assignedVendor.request.personName}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      prices[requestId] = price;

      // Check other trip pricing
      if (_includeOtherTripForRequest[requestId] == true &&
          _otherTripRequests[requestId] != null) {
        final otherTrip = _otherTripRequests[requestId]!;

        // Skip if other trip is already awarded to another vendor
        if (_isRequestAlreadyAwarded(otherTrip)) {
          continue;
        }

        final otherPrice = _otherTripControllers[requestId]!.text.trim();
        if (otherPrice.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enter other trip price for ${assignedVendor.request.personName}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        otherTripPrices[otherTrip.id] = otherPrice;
      }
    }

    // Check if we have any valid prices to submit
    if (prices.isEmpty && otherTripPrices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No available paths to update. All paths are already awarded to other vendors.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Update all prices
    provider.updateMultipleVendorPrices(
      widget.vendorGroup.companyName,
      prices,
      markAsAwarded,
    );

    // Update other trip prices
    if (otherTripPrices.isNotEmpty) {
      provider.updateMultipleVendorPrices(
        widget.vendorGroup.companyName,
        otherTripPrices,
        markAsAwarded,
      );
    }

    Navigator.of(context).pop();

    final totalUpdated = prices.length + otherTripPrices.length;
    String message = markAsAwarded
        ? '$totalUpdated prices updated and vendor marked as awarded!'
        : '$totalUpdated prices updated successfully!';

    if (otherTripPrices.isNotEmpty) {
      message += ' (Including return trips)';
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
      width: MediaQuery.of(context).size.width * 0.5,
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
                      'Bulk Price Entry - ${widget.vendorGroup.companyName}',
                      style: TextStyle(
                        fontSize: 18,
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
              SizedBox(height: 16),

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
                    _buildInfoRow(
                      'Company Name',
                      widget.vendorGroup.vendorDetails.companyName,
                    ),
                    _buildInfoRow(
                      'City',
                      widget.vendorGroup.vendorDetails.city,
                    ),
                    _buildInfoRow(
                      'Category',
                      widget.vendorGroup.vendorDetails.category,
                    ),
                    _buildInfoRow(
                      'Contact',
                      widget.vendorGroup.vendorDetails.contactNumber,
                    ),
                    _buildInfoRow(
                      'Email',
                      widget.vendorGroup.vendorDetails.emailId,
                    ),
                    _buildInfoRow(
                      'Total Requests',
                      widget.vendorGroup.totalRequests.toString(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Individual Request Pricing
              Text(
                'Price for Each Family Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),

              // Request List
              ...widget.vendorGroup.assignedVendors.map((assignedVendor) {
                final requestId = assignedVendor.request.id;
                final request = assignedVendor.request;
                final hasOtherTrip = _otherTripRequests[requestId] != null;
                final includeOtherTrip =
                    _includeOtherTripForRequest[requestId] ?? false;
                final isAlreadyAwarded = _isRequestAlreadyAwarded(request);

                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAlreadyAwarded ? Colors.grey[100] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAlreadyAwarded
                          ? Colors.grey[400]!
                          : Colors.blue[200]!,
                      width: 2,
                    ),
                    boxShadow: isAlreadyAwarded
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Person and Trip Info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.personName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isAlreadyAwarded
                                        ? Colors.grey[600]
                                        : Colors.blue[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  request.travelPath,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isAlreadyAwarded
                                        ? Colors.grey[500]
                                        : Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${request.dateTime.split('\n')[0]} • ${request.flightName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isAlreadyAwarded
                                        ? Colors.grey[400]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (assignedVendor.vendor.isAwarded)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Awarded',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (isAlreadyAwarded)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Awarded to Another Vendor',
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Disable inputs if already awarded to another vendor
                      if (isAlreadyAwarded)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.block,
                                color: Colors.red[800],
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This travel path has already been awarded to another vendor. No further actions can be taken.',
                                  style: TextStyle(
                                    color: Colors.red[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Round trip checkbox
                        if (isRoundTrip && hasOtherTrip)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber[200]!),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: includeOtherTrip,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _includeOtherTripForRequest[requestId] =
                                          value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'Include price for return trip',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.amber[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isRoundTrip && hasOtherTrip) SizedBox(height: 12),

                        // Other trip price (if return trip and checkbox is checked)
                        if (includeOtherTrip &&
                            hasOtherTrip &&
                            _isReturnTrip(
                              request,
                              _otherTripRequests[requestId]!,
                            ))
                          Column(
                            children: [
                              _buildOtherTripPriceSection(
                                requestId,
                                _otherTripRequests[requestId]!,
                              ),
                              SizedBox(height: 12),
                            ],
                          ),

                        // Main trip price input
                        TextField(
                          controller: _priceControllers[requestId]!,
                          decoration: InputDecoration(
                            labelText: 'Price for this trip',
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

                        // Other trip price (if outbound trip and checkbox is checked)
                        if (includeOtherTrip &&
                            hasOtherTrip &&
                            !_isReturnTrip(
                              request,
                              _otherTripRequests[requestId]!,
                            ))
                          Column(
                            children: [
                              SizedBox(height: 12),
                              _buildOtherTripPriceSection(
                                requestId,
                                _otherTripRequests[requestId]!,
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                );
              }).toList(),

              SizedBox(height: 30),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitPrices(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Submit All Prices',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Always show the award button, but with different styling based on availability
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitPrices(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Submit All & Mark as Awarded',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_getBlockedPathsCount() > 0)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '${_getAvailablePathsCount()} available, ${_getBlockedPathsCount()} blocked',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Info text about blocked paths
                  if (_getBlockedPathsCount() > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Text(
                          'Note: ${_getBlockedPathsCount()} travel paths are already awarded to other vendors and will be skipped. ${_getAvailablePathsCount()} paths are available for awarding.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                          ),
                          textAlign: TextAlign.center,
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

  Widget _buildOtherTripPriceSection(int requestId, BookingRequest otherTrip) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Return Trip: ${otherTrip.travelPath}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _otherTripControllers[requestId]!,
            decoration: InputDecoration(
              labelText: 'Price for return trip',
              hintText: 'Enter price (e.g., ₹ 50000)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.currency_rupee),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  bool _isReturnTrip(BookingRequest current, BookingRequest other) {
    final currentParts = current.travelPath.split(' - ');
    final otherParts = other.travelPath.split(' - ');

    if (currentParts.length >= 2 && otherParts.length >= 2) {
      return currentParts[0] == otherParts[1] &&
          currentParts[1] == otherParts[0];
    }

    return false;
  }

  bool _isRequestAlreadyAwarded(BookingRequest request) {
    // Check if any other vendor is already awarded for this request
    return request.vendors.any(
      (vendor) =>
          vendor.companyName != widget.vendorGroup.companyName &&
          vendor.isAwarded,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
