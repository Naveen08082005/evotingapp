import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../controllers/auth_controller.dart';
import 'supabase_service.dart';

class StorageService {
  final _client = SupabaseService.client;

  // ── File validation ────────────────────────────────────────────────────────

  /// Validates [bytes] are a recognised image format by inspecting magic bytes.
  /// Supported: JPEG, PNG, WebP.
  static bool _isAllowedImageType(Uint8List bytes) {
    if (bytes.length < 4) return false;
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) return true;
    // WebP: 52 49 46 46 ... 57 45 42 50
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) return true;
    return false;
  }

  static void _validateImageFile(XFile imageFile, Uint8List bytes) {
    // Extension check
    final ext = imageFile.path.split('.').last.toLowerCase();
    if (!SupabaseConstants.allowedImageExtensions.contains(ext)) {
      throw AppStorageException(
          'Invalid file type. Only JPG, PNG, and WebP images are allowed.');
    }
    // File size check
    if (bytes.length > SupabaseConstants.maxUploadSizeBytes) {
      throw AppStorageException(
          'File size exceeds the 5 MB limit. Please choose a smaller image.');
    }
    // Magic-byte MIME check
    if (!_isAllowedImageType(bytes)) {
      throw AppStorageException(
          'File content does not match an allowed image format.');
    }
  }

  // ── Upload candidate photo ─────────────────────────────────────────────────
  Future<String> uploadCandidatePhoto({
    required XFile imageFile,
    required String candidateId,
  }) async {
    if (AuthController.isDemoMode) {
      return 'https://placehold.co/150';
    }
    try {
      final bytes = await imageFile.readAsBytes();
      _validateImageFile(imageFile, bytes);

      final ext = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          'candidate_${candidateId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = 'candidates/$fileName';

      await _client.storage
          .from(SupabaseConstants.candidatePhotosBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage
          .from(SupabaseConstants.candidatePhotosBucket)
          .getPublicUrl(filePath);
    } on AppStorageException {
      rethrow;
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload candidate photo: ${e.message}');
    } catch (e) {
      throw AppStorageException('Failed to upload candidate photo. Please try again.');
    }
  }

  // ── Upload user photo ──────────────────────────────────────────────────────
  Future<String> uploadUserPhoto({
    required XFile imageFile,
    required String userId,
  }) async {
    if (AuthController.isDemoMode) {
      return 'https://placehold.co/150';
    }
    try {
      final bytes = await imageFile.readAsBytes();
      _validateImageFile(imageFile, bytes);

      final ext = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final filePath = 'users/$fileName';

      await _client.storage
          .from(SupabaseConstants.userPhotosBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage
          .from(SupabaseConstants.userPhotosBucket)
          .getPublicUrl(filePath);
    } on AppStorageException {
      rethrow;
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload user photo: ${e.message}');
    } catch (e) {
      throw AppStorageException('Failed to upload user photo. Please try again.');
    }
  }

  // ── Delete file ────────────────────────────────────────────────────────────
  Future<void> deleteFile({
    required String bucket,
    required String filePath,
  }) async {
    if (AuthController.isDemoMode) return;
    try {
      await _client.storage.from(bucket).remove([filePath]);
    } on StorageException catch (e) {
      throw AppStorageException('Failed to delete file: ${e.message}');
    } catch (e) {
      throw AppStorageException('Failed to delete file. Please try again.');
    }
  }

  // ── Get public URL ─────────────────────────────────────────────────────────
  String getPublicUrl({required String bucket, required String filePath}) {
    return _client.storage.from(bucket).getPublicUrl(filePath);
  }
}
