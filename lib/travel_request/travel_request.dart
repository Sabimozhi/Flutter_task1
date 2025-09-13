// main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task1/travel_request/add_person_dialog.dart';
import 'booking_provider.dart';
import 'models.dart';
import 'vendor_selection_screen.dart';
import 'price_drawer.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text('Ticket Booking System'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row with Toggle and Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Toggle Switch
                    _buildToggleSwitch(provider),

                    // Select & Assign Vendor Button
                    ElevatedButton.icon(
                      onPressed: () => _assignVendors(context, provider),
                      icon: Icon(Icons.assignment_add),
                      label: Text('Select & Assign Vendor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Main Table
                Expanded(child: _buildMainTable(context, provider)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddPersonDialog(context, provider),
            icon: Icon(Icons.person_add),
            label: Text('Add Person'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _showAddPersonDialog(BuildContext context, BookingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AddPersonDialog(
        isOneWay: provider.isOneWay,
        onAddPerson:
            (
              personName,
              fromLocation,
              toLocation,
              flightName,
              flightClass,
              dateTime,
            ) {
              provider.addNewPerson(
                personName: personName,
                fromLocation: fromLocation,
                toLocation: toLocation,
                flightName: flightName,
                flightClass: flightClass,
                dateTime: dateTime,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    provider.isOneWay
                        ? 'New person added successfully!'
                        : 'New person added with round-trip requests!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
      ),
    );
  }

  Widget _buildToggleSwitch(BookingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => provider.setTripType(true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: provider.isOneWay ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'One Way',
                style: TextStyle(
                  color: provider.isOneWay ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => provider.setTripType(false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: !provider.isOneWay ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Round Trip',
                style: TextStyle(
                  color: !provider.isOneWay ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTable(BuildContext context, BookingProvider provider) {
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
          // Table Header
          _buildTableHeader(),

          // Table Body
          Expanded(
            child: ListView.builder(
              itemCount: provider.currentRequests.length,
              itemBuilder: (context, index) {
                final request = provider.currentRequests[index];
                final isExpanded = provider.expandedRows[request.id] ?? false;

                return Column(
                  children: [
                    // Main Row
                    _buildMainRow(context, provider, request),

                    // Expanded Vendor Table
                    if (isExpanded && request.vendors.isNotEmpty)
                      _buildVendorSubTable(context, provider, request),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 40), // Checkbox
          SizedBox(width: 40), // Expand icon
          Expanded(
            flex: 2,
            child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
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
            child: Text('Class', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Vendor Selected',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Contract Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainRow(
    BuildContext context,
    BookingProvider provider,
    BookingRequest request,
  ) {
    final isExpanded = provider.expandedRows[request.id] ?? false;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        color: provider.selectedRequests.contains(request.id)
            ? Colors.blue[50]
            : Colors.white,
      ),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 40,
            child: Checkbox(
              value: provider.selectedRequests.contains(request.id),
              onChanged: (bool? value) {
                provider.toggleRequestSelection(request.id);
              },
            ),
          ),
          // Expand Icon
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(
                isExpanded ? Icons.remove : Icons.add,
                color: Colors.blue,
              ),
              onPressed: () {
                provider.toggleRowExpansion(request.id);
              },
            ),
          ),
          Expanded(flex: 2, child: Text(request.personName)),
          Expanded(flex: 3, child: Text(request.travelPath)),
          Expanded(flex: 2, child: Text(request.dateTime)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    request.flightName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                if (request.status == "New")
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'New',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(request.flightClass)),
          Expanded(flex: 1, child: Text(request.status)),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: request.vendorSelected == "Checked"
                    ? Colors.green[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request.vendorSelected,
                style: TextStyle(
                  color: request.vendorSelected == "Checked"
                      ? Colors.green[800]
                      : Colors.orange[800],
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('${request.vendors.length}'),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.contractStatus,
                    style: TextStyle(color: Colors.green[800], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorSubTable(
    BuildContext context,
    BookingProvider provider,
    BookingRequest request,
  ) {
    return Container(
      margin: EdgeInsets.only(left: 80),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          // Vendor Details Header
          Container(
            padding: EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            child: Text(
              'Vendor Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          // Vendor Table Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50]),
            child: Row(
              children: [
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
                  flex: 2,
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
                    'Price',
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
                Expanded(
                  flex: 1,
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Vendor Rows
          ...request.vendors.asMap().entries.map((entry) {
            int sNo = entry.key + 1;
            AssignedVendor vendor = entry.value;
            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('$sNo', style: TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            vendor.companyName,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        if (vendor.isAwarded)
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Awarded',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(vendor.city, style: TextStyle(fontSize: 12)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      vendor.category,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(vendor.emailId, style: TextStyle(fontSize: 12)),
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
                      vendor.ticketsIssued.isEmpty ? '-' : vendor.ticketsIssued,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      vendor.price.isEmpty ? '-' : vendor.price,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                      onPressed: () {
                        _openPriceDrawer(context, vendor, request.id);
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _assignVendors(BuildContext context, BookingProvider provider) {
    if (provider.selectedRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one travel path'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VendorSelectionScreen()),
    );
  }

  void _openPriceDrawer(
    BuildContext context,
    AssignedVendor vendor,
    int requestId,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: PriceDrawer(vendor: vendor, requestId: requestId),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}
