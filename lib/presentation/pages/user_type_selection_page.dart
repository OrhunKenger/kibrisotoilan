import 'package:flutter/material.dart';
import 'package:mobile/presentation/pages/register_page.dart';
import 'package:mobile/presentation/pages/login_page.dart';
import '../../core/enums/account_type.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Logo section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'KıbrısOto',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hoş Geldiniz!',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size daha iyi hizmet verebilmemiz için\nhesap türünüzü seçin.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 40),
                _buildUserTypeCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'Bireysel',
                  subtitle: 'Kendi arabamı satmak/almak istiyorum.',
                  accountType: AccountType.individual,
                  gradientColors: [AppColors.primary, const Color(0xFF64B5F6)],
                ),
                const SizedBox(height: 20),
                _buildUserTypeCard(
                  context,
                  icon: Icons.business_outlined,
                  title: 'Galeri / Kurumsal',
                  subtitle: 'Oto galerim var, profesyonel satış yapacağım.',
                  accountType: AccountType.corporate,
                  gradientColors: [const Color(0xFFA5D6A7), const Color(0xFF81C784)],
                ),
                const SizedBox(height: 32),
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: AppTextStyles.caption.copyWith(fontSize: 13),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: AppTextStyles.button,
                    ),
                    child: const Text('Zaten hesabın var mı? Giriş Yap'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required AccountType accountType,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [gradientColors[0].withOpacity(0.15), gradientColors[1].withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RegisterPage(initialAccountType: accountType),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: gradientColors[0].withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: gradientColors[0],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: gradientColors[0].withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
