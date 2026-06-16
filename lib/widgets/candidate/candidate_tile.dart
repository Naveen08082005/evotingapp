import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/candidate_model.dart';

class CandidateTile extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CandidateTile({
    super.key,
    required this.candidate,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: AppColors.primaryGradient),
          ),
          child: candidate.photoUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: candidate.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _initials(),
                    errorWidget: (_, __, ___) => _initials(),
                  ),
                )
              : _initials(),
        ),
        title: Text(
          candidate.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${candidate.position} • ${candidate.department}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
      ),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        AppHelpers.getInitials(candidate.name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
    );
  }
}
