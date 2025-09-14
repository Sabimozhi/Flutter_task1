import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_provider.dart';
import 'models.dart';
import 'vendor_selection_screen.dart';
import 'price_drawer.dart';
import 'bulk_price_drawer.dart';
import 'add_person_dialog.dart';

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildToggleSwitch(provider),
                    OutlinedButton.icon(
                      onPressed: () => _assignVendors(context, provider),
                      icon: Icon(Icons.assignment_add),
                      label: Text('Select & Assign Vendor'),
                      style: OutlinedButton.styleFrom(
                        // backgroundColor: Colors.blue,
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildTabBar(provider),
                SizedBox(height: 20),
                Expanded(
                  child: provider.currentTabIndex == 0
                      ? _buildUserTable(context, provider)
                      : _buildVendorTable(context, provider),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddPersonDialog(context, provider),
            icon: Icon(Icons.person_add),
            label: Text('Add Person'),
          ),
        );
      },
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BookingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => provider.setTabIndex(0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: provider.currentTabIndex == 0
                    ? Colors.blue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Group by Users',
                style: TextStyle(
                  color: provider.currentTabIndex == 0
                      ? Colors.white
                      : Colors.grey[700],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => provider.setTabIndex(1),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: provider.currentTabIndex == 1
                    ? Colors.blue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Group by Vendors',
                style: TextStyle(
                  color: provider.currentTabIndex == 1
                      ? Colors.white
                      : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // GROUP BY USERS TABLE
  Widget _buildUserTable(BuildContext context, BookingProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
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
                SizedBox(width: 40), // Expand
                Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Travel Path',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Flight',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.currentRequests.length,
              itemBuilder: (context, index) {
                final request = provider.currentRequests[index];
                final isExpanded = provider.expandedRows[request.id] ?? false;

                return Column(
                  children: [
                    // MAIN USER ROW
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value: provider.selectedRequests.contains(
                                request.id,
                              ),
                              onChanged: (value) =>
                                  provider.toggleRequestSelection(request.id),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              icon: Icon(
                                isExpanded ? Icons.remove : Icons.add,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                print(
                                  'User expand clicked for request ${request.id}, current state: $isExpanded',
                                );
                                provider.toggleRowExpansion(request.id);
                              },
                            ),
                          ),
                          Expanded(child: Text(request.personName)),
                          Expanded(child: Text(request.travelPath)),
                          Expanded(child: Text(request.flightName)),
                          Expanded(child: Text(request.status)),
                        ],
                      ),
                    ),

                    // VENDOR SUB-TABLE (Shows when expanded)
                    if (isExpanded)
                      Container(
                        margin: EdgeInsets.only(left: 80),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue[50]),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'S.No',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Company',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'City',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Price',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Actions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (request.vendors.isEmpty)
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No vendors assigned. Use "Select & Assign Vendor" to add vendors.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              ...request.vendors.asMap().entries.map((entry) {
                                int sNo = entry.key + 1;
                                AssignedVendor vendor = entry.value;
                                return Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '$sNo',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          vendor.companyName,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          vendor.city,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          vendor.price.isEmpty
                                              ? '-'
                                              : vendor.price,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: vendor.isAwarded
                                                ? Colors.green[100]
                                                : Colors.orange[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            vendor.isAwarded
                                                ? 'Awarded'
                                                : 'Pending',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: vendor.isAwarded
                                                  ? Colors.green[800]
                                                  : Colors.orange[800],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => _openPriceDrawer(
                                            context,
                                            vendor,
                                            request.id,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // GROUP BY VENDORS TABLE
  Widget _buildVendorTable(BuildContext context, BookingProvider provider) {
    final vendorGroups = provider.getVendorGroups();

    if (vendorGroups.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('No vendors assigned yet')),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
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
                SizedBox(width: 40), // Expand
                Expanded(
                  child: Text(
                    'Vendor Company',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'City',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vendorGroups.length,
              itemBuilder: (context, index) {
                final vendorGroup = vendorGroups[index];
                final isExpanded =
                    provider.expandedVendors[vendorGroup.companyName] ?? false;

                return Column(
                  children: [
                    // MAIN VENDOR ROW
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              icon: Icon(
                                isExpanded ? Icons.remove : Icons.add,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                print(
                                  'Vendor expand clicked for ${vendorGroup.companyName}, current state: $isExpanded',
                                );
                                provider.toggleVendorExpansion(
                                  vendorGroup.companyName,
                                );
                              },
                            ),
                          ),
                          Expanded(child: Text(vendorGroup.companyName)),
                          Expanded(child: Text(vendorGroup.vendorDetails.city)),
                          Expanded(
                            child: Text(
                              '${vendorGroup.totalRequests}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _openBulkPriceDrawer(context, vendorGroup),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // FAMILY MEMBERS SUB-TABLE (Shows when expanded)
                    if (isExpanded)
                      Container(
                        margin: EdgeInsets.only(left: 40),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Family Members (${vendorGroup.totalRequests} requests)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'S.No',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Person Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Travel Path',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Flight',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Price',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (vendorGroup.assignedVendors.isEmpty)
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No family members found for this vendor.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              ...vendorGroup.assignedVendors
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    int sNo = entry.key + 1;
                                    AssignedVendorWithRequest assignedVendor =
                                        entry.value;
                                    final request = assignedVendor.request;
                                    final vendor = assignedVendor.vendor;

                                    return Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$sNo',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              request.personName,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              request.travelPath,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              request.flightName,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              vendor.price.isEmpty
                                                  ? '-'
                                                  : vendor.price,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: vendor.isAwarded
                                                    ? Colors.green[100]
                                                    : Colors.orange[100],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                vendor.isAwarded
                                                    ? 'Awarded'
                                                    : 'Pending',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: vendor.isAwarded
                                                      ? Colors.green[800]
                                                      : Colors.orange[800],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _assignVendors(BuildContext context, BookingProvider provider) {
    if (provider.selectedRequests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one travel path')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VendorSelectionScreen()),
    );
  }

  void _openBulkPriceDrawer(BuildContext context, VendorGroup vendorGroup) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(child: BulkPriceDrawer(vendorGroup: vendorGroup)),
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

void _showAddPersonDialog(BuildContext context, BookingProvider provider) {
  showDialog(
    context: context,
    builder: (context) => AddPersonDialog(
      isOneWay: provider.isOneWay,
      onAddPerson: (name, from, to, flight, cls, date) {
        provider.addNewPerson(
          personName: name,
          fromLocation: from,
          toLocation: to,
          flightName: flight,
          flightClass: cls,
          dateTime: date,
        );
      },
    ),
  );
}
