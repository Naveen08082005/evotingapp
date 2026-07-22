import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/election_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/verification_settings_model.dart';
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
                // Start / Stop Election Buttons
                if (el.isPending)
                  CustomButton(
                    text: 'Start Election',
                    onPressed: () => _confirmAction(
                      context,
                      'Start Election',
                      'This will allow verified students to cast their votes.',
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
                      'This will close voting and prevent any further vote submissions.',
                      () => controller.stopElection(),
                    ),
                    isLoading: controller.isProcessing.value,
                    color: AppColors.error,
                    icon: Icons.stop_circle_rounded,
                  ),
                const SizedBox(height: 12),

                // Publish Results Button
                CustomButton(
                  text: el.isPublished ? 'Unpublish Results' : 'Publish Official Results',
                  onPressed: () => _confirmAction(
                    context,
                    el.isPublished ? 'Unpublish Results' : 'Publish Results',
                    el.isPublished
                        ? 'Students will no longer see official results.'
                        : 'Official results will become visible to all students on their dashboards.',
                    () => controller.publishResults(!el.isPublished),
                  ),
                  isLoading: controller.isProcessing.value,
                  color: el.isPublished ? AppColors.warning : AppColors.primary,
                  icon: el.isPublished ? Icons.visibility_off_rounded : Icons.published_with_changes_rounded,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditElectionDialog(context, controller, el.title, el.description ?? ''),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit Title'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmAction(
                          context,
                          'Delete Election',
                          'Are you sure you want to delete "${el.title}"? This cannot be undone.',
                          () => controller.deleteElection(),
                          isDangerous: true,
                        ),
                        icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                        label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (!el.isPending)
                  CustomButton(
                    text: 'Reset All Votes & Reset Status',
                    onPressed: () => _confirmAction(
                      context,
                      'Reset Election',
                      'This will erase ALL votes and reset candidate vote counts to 0. This CANNOT be undone.',
                      () => controller.resetElection(),
                      isDangerous: true,
                    ),
                    isLoading: controller.isProcessing.value,
                    isOutlined: true,
                    color: AppColors.error,
                    icon: Icons.refresh_rounded,
                  ),
                const SizedBox(height: 20),

                // Live Results & Publication settings
                const _SectionLabel('Visibility & Results Settings'),
                const SizedBox(height: 10),
                _ToggleCard(
                  title: 'Enable Live Results',
                  subtitle: 'Allow students to view real-time vote counts while election is running',
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

  void _showEditElectionDialog(
    BuildContext context,
    ElectionController controller,
    String currentTitle,
    String currentDesc,
  ) {
    final titleCtrl = TextEditingController(text: currentTitle);
    final descCtrl = TextEditingController(text: currentDesc);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Election Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'Election Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                Get.back();
                controller.editElection(
                  titleCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
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

class _VerificationSettingsCard extends StatefulWidget {
  final VerificationSettingsModel settings;
  final ElectionController controller;

  const _VerificationSettingsCard({
    required this.settings,
    required this.controller,
  });

  @override
  State<_VerificationSettingsCard> createState() => _VerificationSettingsCardState();
}

class _VerificationSettingsCardState extends State<_VerificationSettingsCard> {
  late TextEditingController _minLenCtrl;
  late TextEditingController _maxLenCtrl;

  @override
  void initState() {
    super.initState();
    _minLenCtrl = TextEditingController(
        text: widget.settings.minRegisterNumberLength.toString());
    _maxLenCtrl = TextEditingController(
        text: widget.settings.maxRegisterNumberLength.toString());
  }

  @override
  void didUpdateWidget(covariant _VerificationSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _minLenCtrl.text = widget.settings.minRegisterNumberLength.toString();
      _maxLenCtrl.text = widget.settings.maxRegisterNumberLength.toString();
    }
  }

  @override
  void dispose() {
    _minLenCtrl.dispose();
    _maxLenCtrl.dispose();
    super.dispose();
  }

  void _saveLengthSetting(String key, String val) {
    final parsed = int.tryParse(val.trim());
    if (parsed != null && parsed >= 1) {
      widget.controller.updateVerificationSettings({key: parsed});
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;
    final c = widget.controller;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field Requirements',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          _VerifyToggle(
            label: 'Register Number Required',
            value: s.requireRegisterNumber,
            onChanged: (v) => c.updateVerificationSettings({'require_register_number': v}),
          ),
          _VerifyToggle(
            label: 'Full Name Required',
            value: s.requireFullName,
            onChanged: (v) => c.updateVerificationSettings({'require_full_name': v}),
          ),
          _VerifyToggle(
            label: 'Mobile Number Required',
            value: s.requireMobileNumber,
            onChanged: (v) => c.updateVerificationSettings({'require_mobile_number': v}),
          ),
          _VerifyToggle(
            label: 'Department Required',
            value: s.requireDepartment,
            onChanged: (v) => c.updateVerificationSettings({'require_department': v}),
          ),
          _VerifyToggle(
            label: 'Email Required',
            value: s.requireEmail,
            onChanged: (v) => c.updateVerificationSettings({'require_email': v}),
          ),
          const Divider(height: 28),
          const Text(
            'Register Number Validation Rules',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Configure dynamic length, character set, and duplicate constraints enforced during registration.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minLenCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Min Length',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (v) => _saveLengthSetting('min_register_number_length', v),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _maxLenCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Length',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (v) => _saveLengthSetting('max_register_number_length', v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VerifyToggle(
            label: 'Allow Duplicate Register Numbers',
            value: s.allowDuplicateRegisterNumber,
            onChanged: (v) => c.updateVerificationSettings({'allow_duplicate_register_number': v}),
          ),
          const SizedBox(height: 12),
          const Text(
            'Allowed Character Sets',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          _VerifyToggle(
            label: 'Letters (A-Z, a-z)',
            value: s.allowLetters,
            onChanged: (v) => c.updateVerificationSettings({'allow_letters': v}),
          ),
          _VerifyToggle(
            label: 'Numbers (0-9)',
            value: s.allowNumbers,
            onChanged: (v) => c.updateVerificationSettings({'allow_numbers': v}),
          ),
          _VerifyToggle(
            label: 'Hyphen (-)',
            value: s.allowHyphen,
            onChanged: (v) => c.updateVerificationSettings({'allow_hyphen': v}),
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
