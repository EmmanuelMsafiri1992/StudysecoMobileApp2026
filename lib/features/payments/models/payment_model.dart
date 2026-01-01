class PaymentMethod {
  final int id;
  final String name;
  final String type; // bank_transfer, mobile_money, card
  final String? description;
  final String? instructions;
  final String? accountNumber;
  final String? accountName;
  final String? bankName;
  final String? icon;
  final String region; // malawian, south_african, international
  final List<String> supportedCurrencies;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.instructions,
    this.accountNumber,
    this.accountName,
    this.bankName,
    this.icon,
    required this.region,
    required this.supportedCurrencies,
    this.isActive = true,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? 'bank_transfer',
      description: json['description'],
      instructions: json['instructions'],
      accountNumber: json['account_number'],
      accountName: json['account_name'],
      bankName: json['bank_name'],
      icon: json['icon'],
      region: json['region'] ?? 'malawian',
      supportedCurrencies: (json['supported_currencies'] as List?)?.cast<String>() ?? ['MWK'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class AccessDuration {
  final int id;
  final String name;
  final int months;
  final double pricePerSubject;
  final String currency;
  final double? discount;
  final bool isPopular;

  AccessDuration({
    required this.id,
    required this.name,
    required this.months,
    required this.pricePerSubject,
    required this.currency,
    this.discount,
    this.isPopular = false,
  });

  String get displayName => '$months ${months == 1 ? 'Month' : 'Months'}';

  factory AccessDuration.fromJson(Map<String, dynamic> json) {
    return AccessDuration(
      id: json['id'],
      name: json['name'],
      months: json['months'] ?? 1,
      pricePerSubject: (json['price_per_subject'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'MWK',
      discount: json['discount']?.toDouble(),
      isPopular: json['is_popular'] ?? false,
    );
  }
}

class EnrollmentPricing {
  final int subjectsCount;
  final int durationMonths;
  final double subtotal;
  final double discount;
  final double total;
  final String currency;
  final String formattedTotal;
  final List<SubjectPrice> subjects;

  EnrollmentPricing({
    required this.subjectsCount,
    required this.durationMonths,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.currency,
    required this.formattedTotal,
    required this.subjects,
  });

  factory EnrollmentPricing.fromJson(Map<String, dynamic> json) {
    return EnrollmentPricing(
      subjectsCount: json['subjects_count'] ?? 0,
      durationMonths: json['duration_months'] ?? 1,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'MWK',
      formattedTotal: json['formatted_total'] ?? '',
      subjects: (json['subjects'] as List?)
              ?.map((s) => SubjectPrice.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class SubjectPrice {
  final int id;
  final String name;
  final double price;

  SubjectPrice({
    required this.id,
    required this.name,
    required this.price,
  });

  factory SubjectPrice.fromJson(Map<String, dynamic> json) {
    return SubjectPrice(
      id: json['id'],
      name: json['name'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class Payment {
  final int id;
  final int userId;
  final String type; // enrollment, extension
  final double amount;
  final String currency;
  final String status; // pending, verified, rejected
  final int paymentMethodId;
  final String paymentMethodName;
  final String? referenceNumber;
  final String? proofUrl;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  Payment({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethodId,
    required this.paymentMethodName,
    this.referenceNumber,
    this.proofUrl,
    this.adminNotes,
    required this.createdAt,
    this.verifiedAt,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'] ?? 'enrollment',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'MWK',
      status: json['status'] ?? 'pending',
      paymentMethodId: json['payment_method_id'],
      paymentMethodName: json['payment_method_name'] ?? json['payment_method']?['name'] ?? '',
      referenceNumber: json['reference_number'],
      proofUrl: json['proof_url'],
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
    );
  }
}
