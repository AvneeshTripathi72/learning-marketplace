class PublicationModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String logoUrl;
  final String inquiryNumber;
  final bool isActive;

  PublicationModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.logoUrl,
    required this.inquiryNumber,
    required this.isActive,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      address: json['address'] as String,
      logoUrl: json['logoUrl'] as String,
      inquiryNumber: json['inquiryNumber'] as String? ?? '+91 98765 43210',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'logoUrl': logoUrl,
      'inquiryNumber': inquiryNumber,
      'isActive': isActive,
    };
  }
}
