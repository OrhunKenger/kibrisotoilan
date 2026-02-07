// frontend/mobile/lib/data/models/user_model.dart
import 'package:mobile/domain/entities/account_type.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required int id,
    required String email,
    required String username,
    String? fullName,
    String? phoneNumber,
    String? city,
    required String role,
    required bool isVerified,
    required AccountType accountType,
    String? profileImageUrl,
    String? bio,
    String? district,
    bool? isPhoneVisible,
    String? companyName,
    String? taxNumber, // Explicitly declared here
    String? landlinePhone,
    String? addressDetail,
    String? mapsUrl,
    String? website,
    int activeAdsCount = 0,
    int totalViewsCount = 0,
    int favoritesCount = 0,
  }) : super(
          id: id,
          email: email,
          username: username,
          fullName: fullName,
          phoneNumber: phoneNumber,
          city: city,
          role: role,
          isVerified: isVerified,
          accountType: accountType,
          profileImageUrl: profileImageUrl,
          bio: bio,
          district: district,
          isPhoneVisible: isPhoneVisible,
          companyName: companyName,
          taxNumber: taxNumber, // Passed as named parameter to super
          landlinePhone: landlinePhone,
          addressDetail: addressDetail,
          mapsUrl: mapsUrl,
          website: website,
          activeAdsCount: activeAdsCount,
          totalViewsCount: totalViewsCount,
          favoritesCount: favoritesCount,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Support both snake_case and camelCase keys

    return UserModel(
      id: json['id'] as int,
      email: (json['email'] as String? ?? ''),
      username: (json['username'] as String? ?? ''),
      fullName: (json['full_name'] ?? json['fullName']) as String?,
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']) as String?,
      city: json['city'] as String?,
      role: (json['role'] as String? ?? 'user'),
      isVerified: (json['is_verified'] ?? json['isVerified']) as bool,
      accountType: _accountTypeFromJson(
          (json['account_type'] as String? ?? json['accountType'] as String? ?? 'individual')),
      profileImageUrl: (json['profile_image_url'] ?? json['profileImageUrl']) as String?,
      bio: json['bio'] as String?,
      district: json['district'] as String?,
      isPhoneVisible: (json['is_phone_visible'] ?? json['isPhoneVisible']) as bool?,
      companyName: (json['company_name'] ?? json['companyName']) as String?,
      taxNumber: (json['tax_number'] ?? json['taxNumber']) as String?,
      landlinePhone: (json['landline_phone'] ?? json['landlinePhone']) as String?,
      addressDetail: (json['address_detail'] ?? json['addressDetail']) as String?,
      mapsUrl: (json['maps_url'] ?? json['mapsUrl']) as String?,
      website: json['website'] as String?,
      activeAdsCount: (json['active_ads_count'] ?? json['activeAdsCount']) as int? ?? 0,
      totalViewsCount: (json['total_views_count'] ?? json['totalViewsCount']) as int? ?? 0,
      favoritesCount: (json['favorites_count'] ?? json['favoritesCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'city': city,
      'role': role,
      'is_verified': isVerified,
      'account_type': accountType.name,
      'profile_image_url': profileImageUrl,
      'bio': bio,
      'district': district,
      'is_phone_visible': isPhoneVisible,
      'company_name': companyName,
      'tax_number': taxNumber,
      'landline_phone': landlinePhone,
      'address_detail': addressDetail,
      'maps_url': mapsUrl,
      'website': website,
      'active_ads_count': activeAdsCount,
      'total_views_count': totalViewsCount,
      'favorites_count': favoritesCount,
    };
  }

  static AccountType _accountTypeFromJson(String type) {
    switch (type.toLowerCase()) {
      case 'individual':
        return AccountType.individual;
      case 'corporate':
        return AccountType.corporate;
      default:
        throw Exception('Unknown AccountType: $type');
    }
  }
}