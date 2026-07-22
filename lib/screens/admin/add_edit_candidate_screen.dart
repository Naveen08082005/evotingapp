import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/candidate_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/candidate_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddEditCandidateScreen extends StatefulWidget {
  const AddEditCandidateScreen({super.key});

  @override
  State<AddEditCandidateScreen> createState() => _AddEditCandidateScreenState();
}

class _AddEditCandidateScreenState extends State<AddEditCandidateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _manifestoCtrl = TextEditingController();

  XFile? _selectedImage;
  CandidateModel? _editingCandidate;
  bool _isEdit = false;
  late final CandidateController _candidateController;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _candidateController = Get.find<CandidateController>();
    _authController = Get.find<AuthController>();

    final args = Get.arguments;
    if (args is CandidateModel) {
      _editingCandidate = args;
      _isEdit = true;
      _nameCtrl.text = args.name;
      _positionCtrl.text = args.position;
      _deptCtrl.text = args.department;
      _yearCtrl.text = args.year ?? '';
      _manifestoCtrl.text = args.manifesto ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _positionCtrl, _deptCtrl, _yearCtrl, _manifestoCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final userId = _authController.userId ?? '';

    if (_isEdit && _editingCandidate != null) {
      _candidateController.editCandidate(
        candidateId: _editingCandidate!.id,
        data: {
          'name': _nameCtrl.text.trim(),
          'position': _positionCtrl.text.trim(),
          'department': _deptCtrl.text.trim(),
          'year': _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
          'manifesto': _manifestoCtrl.text.trim(),
        },
        newPhotoFile: _selectedImage,
      );
    } else {
      _candidateController.addCandidate(
        name: _nameCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        department: _deptCtrl.text.trim(),
        manifesto: _manifestoCtrl.text.trim(),
        year: _yearCtrl.text.trim().isEmpty ? null : _yearCtrl.text.trim(),
        photoFile: _selectedImage,
        addedBy: userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Candidate' : 'Add Candidate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
        actions: _isEdit && _editingCandidate != null
            ? [
                PopupMenuButton<String>(
                  onSelected: (val) {
                    Get.find<CandidateController>()
                        .updateStatus(_editingCandidate!.id, val);
                    Get.back();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'approved', child: Text('✅ Approve')),
                    const PopupMenuItem(value: 'rejected', child: Text('❌ Reject')),
                    const PopupMenuItem(value: 'pending', child: Text('⏳ Set Pending')),
                  ],
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: _selectedImage != null
                            ? (kIsWeb
                                ? NetworkImage(_selectedImage!.path) as ImageProvider
                                : FileImage(File(_selectedImage!.path)) as ImageProvider)
                            : (_isEdit && _editingCandidate?.photoUrl != null
                                ? CachedNetworkImageProvider(
                                    _editingCandidate!.photoUrl!) as ImageProvider
                                : null),
                        child: (_selectedImage == null &&
                                (_editingCandidate?.photoUrl == null))
                            ? const Icon(Icons.person_add_rounded,
                                size: 48, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Tap to upload photo',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                label: 'Candidate Name',
                hint: 'Full name',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.validateName,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Position / Post',
                hint: 'e.g. President, Secretary',
                controller: _positionCtrl,
                prefixIcon: Icons.work_outline_rounded,
                validator: (v) => Validators.validateRequired(v, 'Position'),
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Department',
                hint: 'e.g. Computer Science',
                controller: _deptCtrl,
                prefixIcon: Icons.school_outlined,
                validator: Validators.validateDepartment,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Year (Optional)',
                hint: 'e.g. 3rd Year',
                controller: _yearCtrl,
                prefixIcon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                label: 'Manifesto',
                hint: 'Candidate\'s election manifesto...',
                controller: _manifestoCtrl,
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: Validators.validateManifesto,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              Obx(() => GradientButton(
                    text: _isEdit ? 'Update Candidate' : 'Add Candidate',
                    onPressed: _save,
                    isLoading: _candidateController.isSaving.value,
                    icon: _isEdit ? Icons.save_rounded : Icons.add_circle_rounded,
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
