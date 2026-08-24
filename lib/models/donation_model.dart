class DonationModel {
  final String id;
  final String channelName;
  final String upiId;
  final String qrCodeUrl;
  final String creatorPhotoUrl;

  DonationModel({
    required this.id,
    required this.channelName,
    required this.upiId,
    required this.qrCodeUrl,
    required this.creatorPhotoUrl,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'] as String,
      channelName: json['channelName'] as String,
      upiId: json['upiId'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
      creatorPhotoUrl: json['creatorPhotoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelName': channelName,
      'upiId': upiId,
      'qrCodeUrl': qrCodeUrl,
      'creatorPhotoUrl': creatorPhotoUrl,
    };
  }
}
