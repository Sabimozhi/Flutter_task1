// vendor_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_provider.dart';
import 'models.dart';

class VendorSelectionScreen extends StatefulWidget {
  @override
  _VendorSelectionScreenState createState() => _VendorSelectionScreenState();
}

class _VendorSelectionScreenState extends State<VendorSelectionScreen> {
  Set<int> selectedVendors = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        final selectedRequestsList = provider.getSelectedRequestsList();

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text('Select & Assign Vendors'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            actions: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _submitVendors(provider, selectedRequestsList);
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Travel Paths
                _buildSelectedTravelPaths(selectedRequestsList),
                SizedBox(height: 20),

                // Vendor Details Section
                Text(
                  'Vendor Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 12),

                // Vendor List
                Expanded(child: _buildVendorList(provider.allVendors)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTravelPaths(List<BookingRequest> selectedRequests) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Travel Paths:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          // Travel Path Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'S.No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Travel Path',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date & Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Flight Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Class',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Travel Path Rows
          ...selectedRequests.asMap().entries.map((entry) {
            int index = entry.key;
            BookingRequest request = entry.value;
            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('${index + 1}')),
                  Expanded(flex: 4, child: Text(request.travelPath)),
                  Expanded(flex: 2, child: Text(request.dateTime)),
                  Expanded(flex: 2, child: Text(request.flightName)),
                  Expanded(flex: 1, child: Text(request.flightClass)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVendorList(List<Vendor> vendors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vendor Table Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 40), // Checkbox
                Expanded(
                  flex: 1,
                  child: Text(
                    'S.No',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Company Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'City',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Email id',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Contact Number',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Tickets Issued',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Comments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date Sent',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Vendor Rows
          Expanded(
            child: ListView.builder(
              itemCount: vendors.length,
              itemBuilder: (context, index) {
                final vendor = vendors[index];
                final isSelected = selectedVendors.contains(index);

                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                    color: isSelected ? Colors.blue[50] : Colors.white,
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedVendors.add(index);
                              } else {
                                selectedVendors.remove(index);
                              }
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          vendor.companyName,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          vendor.city,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          vendor.category,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          vendor.emailId,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          vendor.contactNumber,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          vendor.ticketsIssued.isEmpty
                              ? '-'
                              : vendor.ticketsIssued,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('-', style: TextStyle(fontSize: 12)),
                      ), // Comments
                      Expanded(
                        flex: 2,
                        child: Text(
                          vendor.dateSent.isEmpty ? '-' : vendor.dateSent,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vendor.status,
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submitVendors(
    BookingProvider provider,
    List<BookingRequest> selectedRequests,
  ) {
    if (selectedVendors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one vendor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Assign selected vendors to all selected requests
    Map<int, List<Vendor>> assignedVendors = {};
    List<Vendor> selected = provider.allVendors
        .where(
          (vendor) =>
              selectedVendors.contains(provider.allVendors.indexOf(vendor)),
        )
        .toList();

    for (var request in selectedRequests) {
      assignedVendors[request.id] = List.from(selected);
    }

    provider.assignVendorsToRequests(assignedVendors);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vendors assigned successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
