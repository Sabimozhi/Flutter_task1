// booking_provider.dart
import 'package:flutter/material.dart';
import 'models.dart';

class BookingProvider with ChangeNotifier {
  bool _isOneWay = true;
  Set<int> _selectedRequests = {};
  Map<int, bool> _expandedRows = {};
  int _nextRequestId = 3; // Start from 3 since we have 2 existing requests

  bool get isOneWay => _isOneWay;
  Set<int> get selectedRequests => _selectedRequests;
  Map<int, bool> get expandedRows => _expandedRows;

  // Sample data
  final List<BookingRequest> _oneWayRequests = [
    BookingRequest(
      id: 1,
      personName: "Khalid Ibn Walid Ibn...",
      travelPath: "Muscat, Oman - Chennai, India",
      dateTime: "01 Jan 2026\n12:05 PM",
      flightName: "Air India (AI 123)",
      flightClass: "BUS",
      status: "New",
      vendorSelected: "Pending",
      contractStatus: "In Progress",
      vendors: [],
    ),
    BookingRequest(
      id: 2,
      personName: "Ahmed Al Mansouri",
      travelPath: "Aachen, Germany - Muscat, Oman",
      dateTime: "21 Sep 2025\n04:00 PM",
      flightName: "OMAN AIR (WY456)",
      flightClass: "ECO",
      status: "New",
      vendorSelected: "Pending",
      contractStatus: "In Progress",
      vendors: [],
    ),
  ];

  final List<BookingRequest> _roundTripRequests = [
    BookingRequest(
      id: 1,
      personName: "Khalid Ibn Walid Ibn...",
      travelPath: "Muscat, Oman - Chennai, India",
      dateTime: "01 Jan 2026\n12:05 PM",
      flightName: "Air India (AI 123)",
      flightClass: "BUS",
      status: "New",
      vendorSelected: "Pending",
      contractStatus: "In Progress",
      vendors: [],
    ),
    BookingRequest(
      id: 2,
      personName: "Khalid Ibn Walid Ibn...",
      travelPath: "Chennai, India - Muscat, Oman",
      dateTime: "15 Jan 2026\n08:30 AM",
      flightName: "Air India (AI 456)",
      flightClass: "BUS",
      status: "New",
      vendorSelected: "Pending",
      contractStatus: "In Progress",
      vendors: [],
    ),
  ];

  // All available vendors
  final List<Vendor> _allVendors = [
    Vendor(
      companyName: "Test Vendor Edited",
      contactPerson: "-",
      city: "Aabenraa",
      category: "Travel Agency",
      contactNumber: "9110673471",
      ticketsIssued: "",
      status: "Active",
      emailId: "new@yopmail.com",
      dateSent: "",
    ),
    Vendor(
      companyName: "Test Vendor Edited",
      contactPerson: "-",
      city: "Aabenraa",
      category: "Travel Agency",
      contactNumber: "9110133471",
      ticketsIssued: "",
      status: "Active",
      emailId: "n@yopmail.com",
      dateSent: "",
    ),
    Vendor(
      companyName: "Test Vendor Edited",
      contactPerson: "-",
      city: "Aabenraa",
      category: "Travel Agency",
      contactNumber: "9127133471",
      ticketsIssued: "",
      status: "Active",
      emailId: "visnity@yopmail.com",
      dateSent: "",
    ),
    Vendor(
      companyName: "Testing lab pvt ltd",
      contactPerson: "-",
      city: "Aabenraa",
      category: "Travel Agency",
      contactNumber: "9128533471",
      ticketsIssued: "",
      status: "Active",
      emailId: "vniy@yopmail.com",
      dateSent: "",
    ),
    Vendor(
      companyName: "Test pvt ltd",
      contactPerson: "-",
      city: "Aabenraa",
      category: "Travel Agency",
      contactNumber: "9898533471",
      ticketsIssued: "",
      status: "Active",
      emailId: "vni@yopmail.com",
      dateSent: "",
    ),
  ];

  List<BookingRequest> get currentRequests =>
      _isOneWay ? _oneWayRequests : _roundTripRequests;
  List<Vendor> get allVendors => _allVendors;

  void setTripType(bool isOneWay) {
    _isOneWay = isOneWay;
    _selectedRequests.clear();
    notifyListeners();
  }

  void toggleRequestSelection(int requestId) {
    if (_isOneWay) {
      // One way - normal behavior
      if (_selectedRequests.contains(requestId)) {
        _selectedRequests.remove(requestId);
      } else {
        _selectedRequests.add(requestId);
      }
    } else {
      // Round trip - group selection by person
      final request = currentRequests.firstWhere((r) => r.id == requestId);
      final personRequests = currentRequests
          .where((r) => r.personName == request.personName)
          .toList();

      if (_selectedRequests.contains(requestId)) {
        // If any request for this person is selected, unselect all
        for (var req in personRequests) {
          _selectedRequests.remove(req.id);
        }
      } else {
        // If none selected for this person, select all
        for (var req in personRequests) {
          _selectedRequests.add(req.id);
        }
      }
    }
    notifyListeners();
  }

  bool isPersonFullySelected(String personName) {
    if (_isOneWay) return false;

    final personRequests = currentRequests
        .where((r) => r.personName == personName)
        .toList();
    return personRequests.isNotEmpty &&
        personRequests.every((req) => _selectedRequests.contains(req.id));
  }

  void addNewPerson({
    required String personName,
    required String fromLocation,
    required String toLocation,
    required String flightName,
    required String flightClass,
    required DateTime dateTime,
  }) {
    if (_isOneWay) {
      // Add single request for one way
      final newRequest = BookingRequest(
        id: _nextRequestId++,
        personName: personName,
        travelPath: "$fromLocation - $toLocation",
        dateTime:
            "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}\n${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}",
        flightName: flightName,
        flightClass: flightClass,
        status: "New",
        vendorSelected: "Pending",
        contractStatus: "In Progress",
        vendors: [],
      );
      _oneWayRequests.add(newRequest);
    } else {
      // Add two requests for round trip
      final outboundRequest = BookingRequest(
        id: _nextRequestId++,
        personName: personName,
        travelPath: "$fromLocation - $toLocation",
        dateTime:
            "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}\n${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}",
        flightName: flightName,
        flightClass: flightClass,
        status: "New",
        vendorSelected: "Pending",
        contractStatus: "In Progress",
        vendors: [],
      );

      final returnDate = dateTime.add(Duration(days: 7)); // Return after 7 days
      final returnRequest = BookingRequest(
        id: _nextRequestId++,
        personName: personName,
        travelPath: "$toLocation - $fromLocation",
        dateTime:
            "${returnDate.day} ${_getMonthName(returnDate.month)} ${returnDate.year}\n${returnDate.hour.toString().padLeft(2, '0')}:${returnDate.minute.toString().padLeft(2, '0')} ${returnDate.hour >= 12 ? 'PM' : 'AM'}",
        flightName: flightName.replaceAllMapped(
          RegExp(r'\d+'),
          (Match m) => (int.parse(m.group(0)!) + 100).toString(),
        ), // Different flight number for return
        flightClass: flightClass,
        status: "New",
        vendorSelected: "Pending",
        contractStatus: "In Progress",
        vendors: [],
      );

      _roundTripRequests.addAll([outboundRequest, returnRequest]);
    }
    notifyListeners();
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

  void toggleRowExpansion(int requestId) {
    _expandedRows[requestId] = !(_expandedRows[requestId] ?? false);
    notifyListeners();
  }

  void assignVendorsToRequests(Map<int, List<Vendor>> assignedVendors) {
    for (var entry in assignedVendors.entries) {
      final requestId = entry.key;
      final vendors = entry.value;

      final request = currentRequests.firstWhere((r) => r.id == requestId);
      request.vendors.clear();

      // Convert to AssignedVendor
      for (var vendor in vendors) {
        request.vendors.add(AssignedVendor.fromVendor(vendor, requestId));
      }

      request.vendorSelected = vendors.isNotEmpty ? "Checked" : "Pending";
    }
    _selectedRequests.clear();
    notifyListeners();
  }

  void updateVendorPrice(
    int requestId,
    String companyName,
    String price,
    bool markAsAwarded,
  ) {
    final request = currentRequests.firstWhere((r) => r.id == requestId);
    final vendorIndex = request.vendors.indexWhere(
      (v) => v.companyName == companyName,
    );

    if (vendorIndex != -1) {
      request.vendors[vendorIndex].price = price;
      if (markAsAwarded) {
        request.vendors[vendorIndex].isAwarded = true;
      }
      notifyListeners();
    }
  }

  List<BookingRequest> getSelectedRequestsList() {
    return currentRequests
        .where((request) => _selectedRequests.contains(request.id))
        .toList();
  }
}
