import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/election_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';

class ElectionSettingsScreen extends StatelessWidget {
  const ElectionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ElectionController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Election Settings')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading settings...');
        }
        final el = controller.election.value;
        final vs = controller.verificationSettings.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Election Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: el == null
                        ? [Colors.grey.shade400, Colors.grey.shade600]
                        : el.isActive
                            ? AppColors.successGradient
                            : el.isCompleted
                                ? AppColors.primaryGradient
                                : AppColors.adminGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      el == null
                          ? 'No Election Created'
                          : el.isActive
                              ? '🟢 Election Active'
                              : el.isCompleted
                                  ? '✅ Election Completed'
                                  : '⏳ Election Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (el != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        el.title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (el.startedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Started: ${AppHelpers.formatDateTime(el.startedAt!)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Election Controls
              const _SectionLabel('Election Controls'),
              const SizedBox(height: 14),

              if (el == null) ...[
                _CreateElectionCard(controller: controller),
              ] else ...[
                if (el.isPending)
                  CustomButton(
                    text: 'Start Election',
                    onPressed: () => _confirmAction(
                      context,
                      'Start Election',
                      'This will allow students to start voting.',
                      () => controller.startElection(),
                    ),
                    isLoading: controller.isProcessing.value,
                    color: AppColors.success,
                    icon: Icons.play_circle_rounded,
                  ),
                if (el.isActive)
                  CustomButton(
                    text: 'Stop Election',
                    onPressed: () => _confirmAction(
                      context,
                      'Stop Election',
                      'This will end voting and finalize results.',
                      () => controller.stopElection(),
                    ),
                    isLoading: controller.isProcessing.value,
                    color: AppColors.error,
                    icon: Icons.stop_circle_rounded,
                  ),
                const SizedBox(height: 14),
                if (!el.isPending)
                  CustomButton(
                    text: 'Reset Election',
                    onPressed: () => _confirmAction(
                      context,
                      'Reset Election',
                      'This will erase ALL votes and reset the system. This cannot be undone.',
                      () => controller.resetElection(),
                      isDangerous: true,
                    ),
                    isLoading: controller.isProcessing.value,
                    isOutlined: true,
                    color: AppColors.error,
                    icon: Icons.refresh_rounded,
                  ),
                const SizedBox(height: 20),

                // Live Results toggle
                const _SectionLabel('Live Results'),
                const SizedBox(height: 10),
                _ToggleCard(
                  title: 'Enable Live Results',
                  subtitle: 'Allow students to view real-time vote counts',
                  value: controller.liveResultsEnabled,
                  onChanged: (val) => controller.toggleLiveResults(val),
                ),
              ],
              const SizedBox(height: 28),

              // Verification Settings
              if (vs != null) ...[
                const _SectionLabel('Verification Fields'),
                const SizedBox(height: 4),
                const Text(
                  'Select which fields students must provide to verify their identity before voting.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 14),
                _VerificationSettingsCard(
                  settings: vs,
                  controller: controller,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String message,
    VoidCallback action, {
    bool isDangerous = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              action();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? AppColors.error : AppColors.primary,
            ),
            child: Text(title, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CreateElectionCard extends StatefulWidget {
  final ElectionController controller;
  const _CreateElectionCard({required this.controller});

  @override
  State<_CreateElectionCard> createState() => _CreateElectionCardState();
}

class _CreateElectionCardState extends State<_CreateElectionCard> {
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            labelText: 'Election Title',
            hintText: 'e.g. Student Council Election 2025',
            prefixIcon: const Icon(Icons.title_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),
        Obx(() => CustomButton(
              text: 'Create Election',
              onPressed: () {
                if (_titleCtrl.text.trim().isEmpty) return;
                widget.controller.createElection(_titleCtrl.text.trim());
              },
              isLoading: widget.controller.isProcessing.value,
              icon: Icons.add_circle_rounded,
            )),
      ],
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Poppins')),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _VerificationSettingsCard extends StatelessWidget {
  final dynamic settings;
  final ElectionController controller;

  const _VerificationSettingsCard({required this.settings, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _VerifyToggle(
            label: 'Register Number',
            value: settings.requireRegisterNumber,
            onChanged: (v) => controller.updateVerificationSettings({'require_register_number': v}),
          ),
          _VerifyToggle(
            label: 'Full Name',
            value: settings.requireFullName,
            onChanged: (v) => controller.updateVerificationSettings({'require_full_name': v}),
          ),
          _VerifyToggle(
            label: 'Mobile Number',
            value: settings.requireMobileNumber,
            onChanged: (v) => controller.updateVerificationSettings({'require_mobile_number': v}),
          ),
          _VerifyToggle(
            label: 'Department',
            value: settings.requireDepartment,
            onChanged: (v) => controller.updateVerificationSettings({'require_department': v}),
          ),
          _VerifyToggle(
            label: 'Email',
            value: settings.requireEmail,
            onChanged: (v) => controller.updateVerificationSettings({'require_email': v}),
          ),
        ],
      ),
    );
  }
}

class _VerifyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _VerifyToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14))),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    );
  }
}
