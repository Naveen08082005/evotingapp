import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regNoCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  late final UserController _userController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _userController = Get.find<UserController>();
    _authController = Get.find<AuthController>();
    _userController.loadVerificationSettings();
  }

  @override
  void dispose() {
    for (final c in [_regNoCtrl, _nameCtrl, _mobileCtrl, _deptCtrl, _emailCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final settings = _userController.verificationSettings.value;
    if (settings == null) {
      Get.snackbar('Error', 'Verification settings not found.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final userId = _authController.userId!;
    final success = await _userController.selfVerify(
      userId: userId,
      registerNumber: _regNoCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      department: _deptCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      settings: settings,
    );

    if (success) {
      await _authController.refreshUser();
      _showSuccessDialog();
    } else {
      Get.snackbar(
        'Verification Failed',
        'The details you entered do not match our records. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verification Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your identity has been verified. You can now cast your vote.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final settings = _userController.verificationSettings.value;
        if (settings == null) {
          return const LoadingWidget(message: 'Loading settings...');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 46,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Verify Your Identity',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Enter your details as registered in the system.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                if (settings.requireRegisterNumber) ...[
                  CustomTextField(
                    label: 'Register Number',
                    hint: 'Your college register number',
                    controller: _regNoCtrl,
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                if (settings.requireFullName) ...[
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'As registered in records',
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                if (settings.requireMobileNumber) ...[
                  CustomTextField(
                    label: 'Mobile Number',
                    hint: '10-digit mobile number',
                    controller: _mobileCtrl,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                if (settings.requireDepartment) ...[
                  CustomTextField(
                    label: 'Department',
                    hint: 'Your department',
                    controller: _deptCtrl,
                    prefixIcon: Icons.school_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                if (settings.requireEmail) ...[
                  CustomTextField(
                    label: 'Email',
                    hint: 'Your registered email',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 16),
                Obx(() => GradientButton(
                      text: 'Verify Identity',
                      onPressed: _verify,
                      isLoading: _userController.isVerifying.value,
                      icon: Icons.verified_user_rounded,
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }
}
