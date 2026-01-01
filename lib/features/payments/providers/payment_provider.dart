import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<PaymentMethod> _paymentMethods = [];
  List<AccessDuration> _accessDurations = [];
  List<Payment> _payments = [];
  EnrollmentPricing? _pricing;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<AccessDuration> get accessDurations => _accessDurations;
  List<Payment> get payments => _payments;
  EnrollmentPricing? get pricing => _pricing;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchPaymentMethods({String? region}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final queryParams = <String, dynamic>{};
      if (region != null) queryParams['region'] = region;

      final response = await _apiService.get('/payment-methods', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _paymentMethods = (response.data['data'] as List)
            .map((m) => PaymentMethod.fromJson(m))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAccessDurations() async {
    try {
      final response = await _apiService.get('/access-durations');

      if (response.statusCode == 200) {
        _accessDurations = (response.data['data'] as List)
            .map((d) => AccessDuration.fromJson(d))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> fetchPricing({
    required List<int> subjectIds,
    required int durationId,
    String currency = 'MWK',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('/enrollment/pricing', data: {
        'subject_ids': subjectIds,
        'duration_id': durationId,
        'currency': currency,
      });

      if (response.statusCode == 200) {
        _pricing = EnrollmentPricing.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitEnrollment({
    required List<int> subjectIds,
    required int durationId,
    required int paymentMethodId,
    required String paymentProof,
    required List<int> schoolIds,
    String? referenceNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.uploadFile(
        '/enrollment/submit',
        filePath: paymentProof,
        fieldName: 'payment_proof',
        additionalData: {
          'subject_ids': subjectIds,
          'duration_id': durationId,
          'payment_method_id': paymentMethodId,
          'school_ids': schoolIds,
          if (referenceNumber != null) 'reference_number': referenceNumber,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitExtension({
    required int durationId,
    required int paymentMethodId,
    required String paymentProof,
    String? referenceNumber,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.uploadFile(
        '/enrollment/extend',
        filePath: paymentProof,
        fieldName: 'payment_proof',
        additionalData: {
          'duration_id': durationId,
          'payment_method_id': paymentMethodId,
          if (referenceNumber != null) 'reference_number': referenceNumber,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      final response = await _apiService.get('/payments');

      if (response.statusCode == 200) {
        _payments = (response.data['data'] as List)
            .map((p) => Payment.fromJson(p))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    }
  }
}
