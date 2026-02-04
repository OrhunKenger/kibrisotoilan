// frontend/mobile/lib/data/models/user_model.dart
import 'package:mobile/domain/entities/account_type.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.fullName,
    super.phoneNumber,
    super.city,
    required super.role,
    required super.isVerified,
    required super.accountType,
    super.profileImageUrl,
    super.bio,
    super.district,
    super.isPhoneVisible,
    super.companyName,
    super.taxNumber,
    super.landlinePhone,
    super.addressDetail,
    super.mapsUrl,
    super.website,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      city: json['city'] as String?,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool,
      accountType: _accountTypeFromJson(json['account_type'] as String),
      profileImageUrl: json['profile_image_url'] as String?,
      bio: json['bio'] as String?,
      district: json['district'] as String?,
      isPhoneVisible: json['is_phone_visible'] as bool?,
      companyName: json['company_name'] as String?,
      taxNumber: json['tax_number'] as String?,
      landlinePhone: json['landline_phone'] as String?,
      addressDetail: json['address_detail'] as String?,
      mapsUrl: json['maps_url'] as String?,
      website: json['website'] as String?,
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
