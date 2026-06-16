// Custom app-level exceptions (prefixed with 'App' to avoid Supabase name conflicts)

class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AppAuthException extends AppException {
  const AppAuthException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class AppStorageException extends AppException {
  const AppStorageException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

String parseSupabaseError(dynamic error) {
  final msg = error.toString().toLowerCase();
  if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
    return 'Invalid email or password. Please try again.';
  } else if (msg.contains('email already registered') || msg.contains('already registered')) {
    return 'This email is already registered.';
  } else if (msg.contains('network') || msg.contains('socket')) {
    return 'Network error. Please check your connection.';
  } else if (msg.contains('jwt') || msg.contains('token')) {
    return 'Session expired. Please login again.';
  } else if (msg.contains('duplicate') || msg.contains('unique')) {
    return 'This record already exists.';
  } else if (msg.contains('not found') || msg.contains('no rows')) {
    return 'Record not found.';
  } else if (msg.contains('permission') || msg.contains('policy')) {
    return 'You do not have permission to perform this action.';
  } else if (msg.contains('foreign key') || msg.contains('violates foreign key')) {
    if (msg.contains('candidates_added_by_fkey')) {
      return 'Failed to add candidate: The logged-in user is not registered in the admins table.';
    }
    return 'Database constraint error: A related record is missing.';
  }
  return 'Something went wrong. Please try again.';
}
