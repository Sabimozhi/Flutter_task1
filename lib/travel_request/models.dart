// models.dart
class BookingRequest {
  final int id;
  final String personName;
  final String travelPath;
  final String dateTime;
  final String flightName;
  final String flightClass;
  final String status;
  String vendorSelected;
  final String contractStatus;
  final List<AssignedVendor> vendors;

  BookingRequest({
    required this.id,
    required this.personName,
    required this.travelPath,
    required this.dateTime,
    required this.flightName,
    required this.flightClass,
    required this.status,
    required this.vendorSelected,
    required this.contractStatus,
    required this.vendors,
  });
}

class Vendor {
  final String companyName;
  final String contactPerson;
  final String city;
  final String category;
  final String contactNumber;
  final String ticketsIssued;
  final String status;
  final String emailId;
  final String dateSent;

  Vendor({
    required this.companyName,
    required this.contactPerson,
    required this.city,
    required this.category,
    required this.contactNumber,
    required this.ticketsIssued,
    required this.status,
    required this.emailId,
    required this.dateSent,
  });
}

class AssignedVendor extends Vendor {
  String price;
  bool isAwarded;
  final int requestId;

  AssignedVendor({
    required String companyName,
    required String contactPerson,
    required String city,
    required String category,
    required String contactNumber,
    required String ticketsIssued,
    required String status,
    required String emailId,
    required String dateSent,
    this.price = '',
    this.isAwarded = false,
    required this.requestId,
  }) : super(
         companyName: companyName,
         contactPerson: contactPerson,
         city: city,
         category: category,
         contactNumber: contactNumber,
         ticketsIssued: ticketsIssued,
         status: status,
         emailId: emailId,
         dateSent: dateSent,
       );

  factory AssignedVendor.fromVendor(Vendor vendor, int requestId) {
    return AssignedVendor(
      companyName: vendor.companyName,
      contactPerson: vendor.contactPerson,
      city: vendor.city,
      category: vendor.category,
      contactNumber: vendor.contactNumber,
      ticketsIssued: vendor.ticketsIssued,
      status: vendor.status,
      emailId: vendor.emailId,
      dateSent: vendor.dateSent,
      requestId: requestId,
    );
  }
}
