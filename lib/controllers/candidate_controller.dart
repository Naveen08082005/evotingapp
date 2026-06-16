import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../models/candidate_model.dart';
import '../repositories/candidate_repository.dart';
import '../services/storage_service.dart';

class CandidateController extends GetxController {
  final CandidateRepository _repo = CandidateRepository();
  final StorageService _storageService = StorageService();

  final RxList<CandidateModel> candidates = <CandidateModel>[].obs;
  final RxList<CandidateModel> filteredCandidates = <CandidateModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadCandidates();
    ever(searchQuery, (_) => _applyFilter());
    ever(statusFilter, (_) => _applyFilter());
  }

  Future<void> loadCandidates() async {
    try {
      isLoading.value = true;
      candidates.value = await _repo.getAllCandidates();
      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var list = candidates.toList();
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.position.toLowerCase().contains(q) ||
        c.department.toLowerCase().contains(q),
      ).toList();
    }
    if (statusFilter.value != 'all') {
      list = list.where((c) => c.status == statusFilter.value).toList();
    }
    filteredCandidates.value = list;
  }

  // ─── Add candidate ─────────────────────────────────────────────────────────
  Future<void> addCandidate({
    required String name,
    required String position,
    required String department,
    required String manifesto,
    String? year,
    XFile? photoFile,
    required String addedBy,
  }) async {
    try {
      isSaving.value = true;
      String? photoUrl;
      if (photoFile != null) {
        photoUrl = await _storageService.uploadCandidatePhoto(
          imageFile: photoFile,
          candidateId: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      final data = {
        'name': name,
        'position': position,
        'department': department,
        'manifesto': manifesto,
        if (year != null) 'year': year,
        if (photoUrl != null) 'photo_url': photoUrl,
        'status': 'pending',
        'vote_count': 0,
        'added_by': addedBy,
      };

      final candidate = await _repo.addCandidate(data);
      // Refresh the full list to avoid duplicate entries (especially in demo mode)
      await loadCandidates();
      Get.back();
      Get.snackbar('Success', 'Candidate added successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // ─── Edit candidate ────────────────────────────────────────────────────────
  Future<void> editCandidate({
    required String candidateId,
    required Map<String, dynamic> data,
    XFile? newPhotoFile,
  }) async {
    try {
      isSaving.value = true;
      if (newPhotoFile != null) {
        data['photo_url'] = await _storageService.uploadCandidatePhoto(
          imageFile: newPhotoFile,
          candidateId: candidateId,
        );
      }
      final updated = await _repo.updateCandidate(candidateId, data);
      final idx = candidates.indexWhere((c) => c.id == candidateId);
      if (idx != -1) candidates[idx] = updated;
      _applyFilter();
      Get.back();
      Get.snackbar('Success', 'Candidate updated successfully.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  // ─── Delete candidate ──────────────────────────────────────────────────────
  Future<void> deleteCandidate(String candidateId) async {
    try {
      await _repo.deleteCandidate(candidateId);
      candidates.removeWhere((c) => c.id == candidateId);
      _applyFilter();
      Get.snackbar('Deleted', 'Candidate removed.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Approve / Reject ──────────────────────────────────────────────────────
  Future<void> updateStatus(String candidateId, String status) async {
    try {
      await _repo.updateCandidateStatus(candidateId, status);
      final idx = candidates.indexWhere((c) => c.id == candidateId);
      if (idx != -1) {
        candidates[idx] = candidates[idx].copyWith(status: status);
        _applyFilter();
      }
      Get.snackbar('Updated', 'Candidate $status.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  void search(String query) => searchQuery.value = query;
  void setFilter(String filter) => statusFilter.value = filter;
  @override
  Future<void> refresh() => loadCandidates();
}
