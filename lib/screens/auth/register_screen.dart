import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    for (final c in [
      _emailCtrl, _passwordCtrl, _confirmPasswordCtrl,
      _nameCtrl, _regNoCtrl, _mobileCtrl, _deptCtrl, _yearCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    _authController.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      fullName: _nameCtrl.text.trim(),
      registerNumber: _regNoCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      department: _deptCtrl.text.trim(),
      year: _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Student Registration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fill in your college details to register',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 28),
                _sectionLabel('Personal Information'),
                const SizedBox(height: 12),
                CustomTextField(
                  label: AppStrings.fullName,
                  hint: 'Your full name',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.registerNumber,
                  hint: 'Enter your register number',
                  controller: _regNoCtrl,
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => Validators.validateRegisterNumber(
                    v,
                    settings: _authController.verificationSettings.value,
                  ),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.mobileNumber,
                  hint: '10-digit mobile number',
                  controller: _mobileCtrl,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validateMobile,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.department,
                  hint: 'e.g. Computer Science',
                  controller: _deptCtrl,
                  prefixIcon: Icons.school_outlined,
                  validator: Validators.validateDepartment,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Year (Optional)',
                  hint: 'e.g. 2nd Year',
                  controller: _yearCtrl,
                  prefixIcon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 24),
                _sectionLabel('Account Credentials'),
                const SizedBox(height: 12),
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'College email address',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.password,
                  hint: 'Min. 6 characters',
                  controller: _passwordCtrl,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordCtrl,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (v) =>
                      Validators.validateConfirmPassword(v, _passwordCtrl.text),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 32),
                Obx(() => GradientButton(
                      text: 'Create Account',
                      onPressed: _register,
                      isLoading: _authController.isLoading.value,
                      icon: Icons.app_registration_rounded,
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.alreadyHaveAccount,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.login),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontFamily: 'Poppins',
        letterSpacing: 0.5,
      ),
    );
  }
}
