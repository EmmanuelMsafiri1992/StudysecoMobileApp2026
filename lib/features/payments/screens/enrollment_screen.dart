import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final ApiService _apiService = ApiService();
  int _currentStep = 0;
  bool _isLoading = true;
  String? _error;

  // Enrollment status
  Map<String, dynamic>? _enrollmentStatus;
  bool _canStartTrial = false;

  // Available data
  List<dynamic> _subjects = [];
  List<dynamic> _paymentMethods = [];
  List<dynamic> _accessDurations = [];

  // Selection state
  final Set<int> _selectedSubjectIds = {};
  int? _selectedDurationId;
  int? _selectedPaymentMethodId;
  String? _referenceNumber;
  File? _paymentProof;
  Map<String, dynamic>? _pricing;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load enrollment status
      debugPrint('Loading enrollment status...');
      final statusResponse = await _apiService.get('/enrollment/status');
      debugPrint('Enrollment status response: ${statusResponse.data}');
      _enrollmentStatus = statusResponse.data['data'];
      _canStartTrial = _enrollmentStatus?['can_start_trial'] ?? false;

      // If already enrolled, don't load other data
      if (_enrollmentStatus?['has_enrollment'] == true &&
          _enrollmentStatus?['enrollment']?['status'] == 'approved') {
        setState(() => _isLoading = false);
        return;
      }

      // Load subjects, payment methods, and durations in parallel
      debugPrint('Loading subjects, payment methods, and durations...');
      final results = await Future.wait([
        _apiService.get('/enrollment/subjects'),
        _apiService.get('/payment-methods'),
        _apiService.get('/access-durations'),
      ]);

      debugPrint('Subjects response: ${results[0].data}');
      debugPrint('Payment methods response: ${results[1].data}');
      debugPrint('Access durations response: ${results[2].data}');

      _subjects = results[0].data['data'] ?? [];
      _paymentMethods = results[1].data['data'] ?? [];
      _accessDurations = results[2].data['data'] ?? [];

      debugPrint('Loaded ${_subjects.length} subjects');
      debugPrint('Loaded ${_paymentMethods.length} payment methods');
      debugPrint('Loaded ${_accessDurations.length} access durations');

      // Set default duration if available
      if (_accessDurations.isNotEmpty) {
        _selectedDurationId = _accessDurations.first['id'];
      }
    } catch (e) {
      debugPrint('Error loading enrollment data: $e');
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculatePricing() async {
    if (_selectedSubjectIds.isEmpty || _selectedDurationId == null) return;

    try {
      final response = await _apiService.post('/enrollment/pricing', data: {
        'subject_ids': _selectedSubjectIds.toList(),
        'duration_id': _selectedDurationId,
        'currency': 'MWK',
      });
      setState(() {
        _pricing = response.data['data'];
      });
    } catch (e) {
      // Ignore pricing errors
    }
  }

  Future<void> _startTrial() async {
    if (_selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 subject')),
      );
      return;
    }

    if (_selectedSubjectIds.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trial is limited to 3 subjects')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.post('/enrollment/trial', data: {
        'subject_ids': _selectedSubjectIds.toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your 7-day free trial has started!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _paymentProof = File(image.path);
      });
    }
  }

  Future<void> _submitEnrollment() async {
    if (_paymentProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload payment proof')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.uploadFile(
        '/enrollment/submit',
        filePath: _paymentProof!.path,
        fieldName: 'payment_proof',
        additionalData: {
          'subject_ids': _selectedSubjectIds.toList(),
          'duration_id': _selectedDurationId,
          'payment_method_id': _selectedPaymentMethodId,
          if (_referenceNumber != null) 'reference_number': _referenceNumber,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enrollment submitted! Awaiting approval.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Debug info at top
    debugPrint('Building content - enrollmentStatus: $_enrollmentStatus');
    debugPrint('Building content - subjects count: ${_subjects.length}');
    debugPrint('Building content - error: $_error');

    // If already enrolled and approved
    if (_enrollmentStatus?['has_enrollment'] == true &&
        _enrollmentStatus?['enrollment']?['status'] == 'approved') {
      return _buildAlreadyEnrolled();
    }

    // If has pending enrollment
    if (_enrollmentStatus?['has_enrollment'] == true &&
        _enrollmentStatus?['enrollment']?['status'] == 'pending') {
      return _buildPendingEnrollment();
    }

    return Column(
      children: [
        // Debug panel - remove after testing
        Container(
          color: Colors.yellow.shade100,
          padding: const EdgeInsets.all(8),
          child: Text(
            'DEBUG: ${_subjects.length} subjects, ${_paymentMethods.length} methods, ${_accessDurations.length} durations\nError: ${_error ?? "none"}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              if (_currentStep < 2)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 0 ? 'Next' : 'Continue'),
                ),
              if (_currentStep == 2)
                ElevatedButton(
                  onPressed: _submitEnrollment,
                  child: const Text('Submit Enrollment'),
                ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('Select Subjects'),
          content: _buildSubjectSelection(),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Choose Plan'),
          content: _buildPlanSelection(),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Payment'),
          content: _buildPaymentStep(),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
      ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlreadyEnrolled() {
    final enrollment = _enrollmentStatus!['enrollment'];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: AppColors.success),
            const SizedBox(height: 24),
            const Text(
              'You are enrolled!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${enrollment['subjects_count']} subjects',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '${enrollment['days_remaining']} days remaining',
              style: const TextStyle(fontSize: 18, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingEnrollment() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 80, color: AppColors.warning),
            const SizedBox(height: 24),
            const Text(
              'Enrollment Pending',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your enrollment is awaiting approval.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_canStartTrial) ...[
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        '7-Day Free Trial',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Try up to 3 subjects free for 7 days!'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _selectedSubjectIds.isNotEmpty ? _startTrial : null,
                    child: const Text('Start Free Trial'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Or select subjects for paid enrollment:'),
          const SizedBox(height: 8),
        ],
        Text(
          'Selected: ${_selectedSubjectIds.length} subjects',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        if (_subjects.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('No subjects available. Please contact support.'),
                  ),
                ],
              ),
            ),
          )
        else
          ..._subjects.map((subject) => CheckboxListTile(
                title: Text(subject['name'] ?? 'Unknown'),
                subtitle: Text(subject['grade_level'] ?? ''),
                value: _selectedSubjectIds.contains(subject['id']),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedSubjectIds.add(subject['id']);
                    } else {
                      _selectedSubjectIds.remove(subject['id']);
                    }
                  });
                },
              )),
      ],
    );
  }

  Widget _buildPlanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Access Duration',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._accessDurations.map((duration) => RadioListTile<int>(
              title: Text(duration['name']),
              subtitle: Text(duration['display'] ?? '${duration['days']} days'),
              value: duration['id'],
              groupValue: _selectedDurationId,
              onChanged: (value) {
                setState(() {
                  _selectedDurationId = value;
                });
                _calculatePricing();
              },
            )),
        if (_pricing != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_pricing!['subject_count']} subjects'),
                      Text('${_pricing!['currency']} ${_pricing!['subtotal']}'),
                    ],
                  ),
                  if (_pricing!['discount'] > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount (${_pricing!['discount_percent']}%)'),
                        Text(
                          '-${_pricing!['currency']} ${_pricing!['discount']}',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _pricing!['formatted_total'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.map((method) => RadioListTile<int>(
              title: Text(method['name']),
              subtitle: Text(method['description'] ?? ''),
              secondary: Text(method['icon'] ?? '', style: const TextStyle(fontSize: 24)),
              value: method['id'],
              groupValue: _selectedPaymentMethodId,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethodId = value;
                });
              },
            )),
        if (_selectedPaymentMethodId != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Instructions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _paymentMethods.firstWhere(
                      (m) => m['id'] == _selectedPaymentMethodId,
                      orElse: () => {'account_details': ''},
                    )['account_details'] ?? '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Reference Number (Optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _referenceNumber = value,
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Payment Proof',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickImage,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _paymentProof != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_paymentProof!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to upload screenshot'),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_selectedSubjectIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one subject')),
        );
        return;
      }
      _calculatePricing();
    }

    if (_currentStep == 1) {
      if (_selectedDurationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a duration')),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
}
