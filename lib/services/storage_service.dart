import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../controllers/auth_controller.dart';
import 'supabase_service.dart';

class StorageService {
  final _client = SupabaseService.client;

  // ─── Upload candidate photo ───────────────────────────────────────────────
  Future<String> uploadCandidatePhoto({
    required XFile imageFile,
    required String candidateId,
  }) async {
    if (AuthController.isDemoMode) {
      return 'https://placehold.co/150';
    }
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          'candidate_${candidateId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'candidates/$fileName';

      final bytes = await imageFile.readAsBytes();

      await _client.storage
          .from(SupabaseConstants.candidatePhotosBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage
          .from(SupabaseConstants.candidatePhotosBucket)
          .getPublicUrl(filePath);
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload candidate photo: ${e.message}');
    } catch (e) {
      throw AppStorageException('Failed to upload candidate photo: $e');
    }
  }

  // ─── Upload user photo ────────────────────────────────────────────────────
  Future<String> uploadUserPhoto({
    required XFile imageFile,
    required String userId,
  }) async {
    if (AuthController.isDemoMode) {
      return 'https://placehold.co/150';
    }
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'users/$fileName';

      final bytes = await imageFile.readAsBytes();

      await _client.storage
          .from(SupabaseConstants.userPhotosBucket)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage
          .from(SupabaseConstants.userPhotosBucket)
          .getPublicUrl(filePath);
    } on StorageException catch (e) {
      throw AppStorageException('Failed to upload user photo: ${e.message}');
    } catch (e) {
      throw AppStorageException('Failed to upload user photo: $e');
    }
  }

  // ─── Delete file ──────────────────────────────────────────────────────────
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
      throw AppStorageException('Failed to delete file: $e');
    }
  }

  // ─── Get public URL ───────────────────────────────────────────────────────
  String getPublicUrl({required String bucket, required String filePath}) {
    return _client.storage.from(bucket).getPublicUrl(filePath);
  }
}
