import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class CandidatePhotoWidget extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;

  const CandidatePhotoWidget({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: AppColors.primaryGradient),
      ),
      child: photoUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _initials(),
                errorWidget: (_, __, ___) => _initials(),
              ),
            )
          : _initials(),
    );
  }

  Widget _initials() {
    return Center(
      child: Text(
        AppHelpers.getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}
