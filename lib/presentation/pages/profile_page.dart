import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/account_type.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/car/car_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../widgets/error_state_widget.dart';
import 'edit_profile_page.dart';
import 'my_listings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Çıkış Yap'),
                  content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Vazgeç'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthBloc>().add(const LogoutRequested());
                      },
                      child: const Text('Çıkış Yap', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdated) {
            // Reload profile after update
            context.read<UserBloc>().add(const GetUserProfileEvent());
          }
        },
        buildWhen: (_, current) =>
            current is UserLoading ||
            current is UserLoaded ||
            current is UserError,
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Avatar & name
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surfaceLight,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(user.fullName ?? 'İsim Bilgisi Yok', style: AppTextStyles.heading2),
                      const SizedBox(height: 4),
                      Text(user.email, style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Profili Düzenle',
                  onTap: () async {
                    final result = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<UserBloc>(),
                          child: EditProfilePage(user: user),
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context.read<UserBloc>().add(const GetUserProfileEvent());
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.list_alt,
                  label: 'İlanlarım',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<UserBloc>()),
                            BlocProvider.value(value: context.read<CarBloc>()),
                          ],
                          child: const MyListingsPage(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Info cards
                _buildProfileCard([
                  _buildInfoItem(Icons.email, 'Email', user.email),
                  _buildInfoItem(Icons.person_pin, 'Kullanıcı Adı', user.username),
                  _buildInfoItem(Icons.verified_user, 'Doğrulanmış', user.isVerified ? 'Evet' : 'Hayır'),
                  _buildInfoItem(Icons.account_box, 'Hesap Tipi',
                      user.accountType == AccountType.individual ? 'Bireysel' : 'Kurumsal'),
                ]),
                const SizedBox(height: 12),
                _buildProfileCard([
                  _buildInfoItem(Icons.phone, 'Telefon', user.phoneNumber ?? 'Belirtilmemiş'),
                  _buildInfoItem(Icons.location_city, 'Şehir', user.city ?? 'Belirtilmemiş'),
                  _buildInfoItem(Icons.map, 'İlçe', user.district ?? 'Belirtilmemiş'),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    _buildInfoItem(Icons.description, 'Bio', user.bio!),
                ]),

                if (user.accountType == AccountType.corporate) ...[
                  const SizedBox(height: 12),
                  _buildProfileCard([
                    _buildInfoItem(Icons.business_center, 'Şirket Adı', user.companyName ?? 'Belirtilmemiş'),
                    _buildInfoItem(Icons.receipt_long, 'Vergi Numarası', user.taxNumber ?? 'Belirtilmemiş'),
                    _buildInfoItem(Icons.phone_in_talk, 'Sabit Telefon', user.landlinePhone ?? 'Belirtilmemiş'),
                    _buildInfoItem(Icons.home_work, 'Adres', user.addressDetail ?? 'Belirtilmemiş'),
                    _buildInfoItem(Icons.public, 'Web Sitesi', user.website ?? 'Belirtilmemiş'),
                    _buildInfoItem(Icons.map, 'Haritalar', user.mapsUrl ?? 'Belirtilmemiş'),
                  ]),
                ],

                const SizedBox(height: 32),
              ],
            );
          } else if (state is UserError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<UserBloc>().add(const GetUserProfileEvent()),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: AppTextStyles.body),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildProfileCard(List<Widget> items) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: items),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: AppTextStyles.body),
      dense: true,
    );
  }
}
