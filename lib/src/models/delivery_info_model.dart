/// A data class to hold delivery information collected during checkout.
class DeliveryInfo {
  final String fullName;
  final String mobileNumber;
  final String addressLine1;
  final String? addressLine2;
  final String pincode;

  DeliveryInfo({
    required this.fullName,
    required this.mobileNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.pincode,
  });

  /// Factory constructor to create a [DeliveryInfo] from a map.
  factory DeliveryInfo.fromMap(Map<String, dynamic> map) {
    return DeliveryInfo(
      fullName: map['fullName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      addressLine1: map['addressLine1'] ?? '',
      addressLine2: map['addressLine2'],
      pincode: map['pincode'] ?? '',
    );
  }
}