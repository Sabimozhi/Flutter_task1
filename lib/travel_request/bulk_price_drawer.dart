// bulk_price_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_provider.dart';
import 'models.dart';

enum PricingMode { lumpsum, individual }

class BulkPriceDrawer extends StatefulWidget {
  final VendorGroup vendorGroup;

  const BulkPriceDrawer({Key? key, required this.vendorGroup})
    : super(key: key);

  @override
  _BulkPriceDrawerState createState() => _BulkPriceDrawerState();
}

class _BulkPriceDrawerState extends State<BulkPriceDrawer> {
  Map<int, TextEditingController> _priceControllers = {};

  // New pricing mode variables
  PricingMode _pricingMode = PricingMode.lumpsum;
  final TextEditingController _lumpsumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Simple initialization - one controller per travel request in the vendor group
    for (var assignedVendor in widget.vendorGroup.assignedVendors) {
      final requestId = assignedVendor.request.id;
      _priceControllers[requestId] = TextEditingController(
        text: assignedVendor.vendor.price,
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    _lumpsumController.dispose();
    super.dispose();
  }

  // Count blocked paths (already awarded to other vendors)
  int _getBlockedPathsCount() {
    return widget.vendorGroup.assignedVendors
        .where(
          (assignedVendor) => _isRequestAlreadyAwarded(assignedVendor.request),
        )
        .length;
  }

  // Count available paths (not awarded to other vendors)
  int _getAvailablePathsCount() {
    return widget.vendorGroup.assignedVendors
        .where(
          (assignedVendor) => !_isRequestAlreadyAwarded(assignedVendor.request),
        )
        .length;
  }

  List<BookingRequest> _getAvailableRequests() {
    return widget.vendorGroup.assignedVendors
        .where(
          (assignedVendor) => !_isRequestAlreadyAwarded(assignedVendor.request),
        )
        .map((assignedVendor) => assignedVendor.request)
        .toList();
  }

  void _submitPrices(bool markAsAwarded) {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    Map<int, String> prices = {};

    if (_pricingMode == PricingMode.lumpsum) {
      // Handle lumpsum pricing
      final lumpsumPrice = _lumpsumController.text.trim();

      if (lumpsumPrice.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the total lumpsum price'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get all available requests
      final availableRequests = _getAvailableRequests();

      if (availableRequests.isEmpty) {
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

      // Assign the same lumpsum price to all available requests
      for (var request in availableRequests) {
        prices[request.id] = lumpsumPrice;
      }
    } else {
      // Handle individual pricing
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
                'Please enter price for ${assignedVendor.request.personName} - ${assignedVendor.request.travelPath}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        prices[requestId] = price;
      }
    }

    // Check if we have any valid prices to submit
    if (prices.isEmpty) {
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

    Navigator.of(context).pop();

    final totalUpdated = prices.length;
    String message = markAsAwarded
        ? '$totalUpdated prices updated and vendor marked as awarded!'
        : '$totalUpdated prices updated successfully!';

    if (_pricingMode == PricingMode.lumpsum) {
      message += ' (Lumpsum pricing applied)';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
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

              // Pricing Mode Selection
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Radio<PricingMode>(
                          value: PricingMode.lumpsum,
                          groupValue: _pricingMode,
                          onChanged: (PricingMode? value) {
                            setState(() {
                              _pricingMode = value!;
                            });
                          },
                        ),
                        Text(
                          'Total Lumpsum',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(width: 20),
                        Radio<PricingMode>(
                          value: PricingMode.individual,
                          groupValue: _pricingMode,
                          onChanged: (PricingMode? value) {
                            setState(() {
                              _pricingMode = value!;
                            });
                          },
                        ),
                        Text(
                          'Individual Ticket Price',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Conditional Content Based on Pricing Mode
              if (_pricingMode == PricingMode.lumpsum) ...[
                // Lumpsum Pricing Section
                Text(
                  'Total Lumpsum Price',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                // Show list of available travel paths
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travel Paths Included:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      ..._getAvailableRequests().map(
                        (request) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${request.personName} - ${request.travelPath}',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Lumpsum input field
                TextField(
                  controller: _lumpsumController,
                  decoration: InputDecoration(
                    labelText: 'Total lumpsum price for all travel paths',
                    hintText: 'Enter total price (e.g., ₹ 200000)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.currency_rupee),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                // Individual Pricing Section
                Text(
                  'Individual Travel Path Pricing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                // Travel Path List - Each path treated independently
                ...widget.vendorGroup.assignedVendors.map((assignedVendor) {
                  final requestId = assignedVendor.request.id;
                  final request = assignedVendor.request;
                  final isAlreadyAwarded = _isRequestAlreadyAwarded(request);

                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
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
                        // Travel Path Header
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
                                      fontWeight: FontWeight.w500,
                                      color: isAlreadyAwarded
                                          ? Colors.grey[500]
                                          : Colors.grey[700],
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
                            // Status indicators
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
                                  'Blocked',
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

                        // Price input or blocked message
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
                                    'Already awarded to another vendor',
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
                        else
                          // Price input for this specific travel path
                          TextField(
                            controller: _priceControllers[requestId]!,
                            decoration: InputDecoration(
                              labelText: 'Price for this travel path',
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
                }).toList(),
              ],

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
                        _pricingMode == PricingMode.lumpsum
                            ? 'Submit Lumpsum Price'
                            : 'Submit All Prices',
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
                            _pricingMode == PricingMode.lumpsum
                                ? 'Submit Lumpsum & Mark as Awarded'
                                : 'Submit All & Mark as Awarded',
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
