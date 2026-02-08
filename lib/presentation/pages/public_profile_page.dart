import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/account_type.dart';

class PublicProfilePage extends StatelessWidget {
  final UserEntity user;

  const PublicProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Satıcı Profili', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildInfoSection(),
            const SizedBox(height: 30),
            if (user.bio != null && user.bio!.isNotEmpty) _buildBioSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
          child: user.profileImageUrl == null ? const Icon(Icons.person, color: AppColors.primary, size: 60) : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.fullName ?? 'Bilinmeyen Satıcı',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (user.isVerified) ...[
              const SizedBox(width: 8),
              const Icon(Icons.verified, color: AppColors.primary, size: 24),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.accountType == AccountType.corporate ? (user.companyName ?? 'Kurumsal Satıcı') : 'Bireysel Satıcı',
          style: const TextStyle(fontSize: 16, color: AppColors.textHint),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            _buildInfoRow(Icons.location_on_outlined, 'Konum', '${user.city ?? ''} / ${user.district ?? ''}'),
            const Divider(height: 32, color: Colors.white10),
            _buildInfoRow(Icons.calendar_today_outlined, 'Üyelik Tipi', user.accountType == AccountType.corporate ? 'Kurumsal' : 'Bireysel'),
            if (user.phoneNumber != null && (user.isPhoneVisible ?? true)) ...[
              const Divider(height: 32, color: Colors.white10),
              _buildInfoRow(Icons.phone_outlined, 'Telefon', user.phoneNumber!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hakkında', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            user.bio!,
            style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    );
  }
}
