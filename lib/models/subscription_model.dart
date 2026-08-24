enum PackageTier { initial, silver, bronze, gold, diamond }
enum SubscriptionStatus { active, inactive, expired, pendingUpgrade }

class SubscriptionPackageModel {
  final String id;
  final PackageTier tier;
  final String name;
  final double price;
  final String adLimits;
  final String displayPriority;
  final int maxVideos;
  final int durationDays;
  final List<String> features;

  SubscriptionPackageModel({
    required this.id,
    required this.tier,
    required this.name,
    required this.price,
    required this.adLimits,
    required this.displayPriority,
    required this.maxVideos,
    required this.durationDays,
    required this.features,
  });
}

class SubscriptionModel {
  final String id;
  final String publicationId;
  final PackageTier package;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;
  final String paymentId;

  SubscriptionModel({
    required this.id,
    required this.publicationId,
    required this.package,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentId,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      publicationId: json['publicationId'] as String,
      package: PackageTier.values.firstWhere(
        (e) => e.name == json['package'],
        orElse: () => PackageTier.silver,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      paymentId: json['paymentId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicationId': publicationId,
      'package': package.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'paymentId': paymentId,
    };
  }
}
