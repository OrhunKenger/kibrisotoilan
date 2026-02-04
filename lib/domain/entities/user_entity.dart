// frontend/mobile/lib/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';
import 'package:mobile/domain/entities/account_type.dart'; // Import the AccountType enum

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? phoneNumber;
  final String? city;
  final String role; // e.g., "standard", "admin"
  final bool isVerified;
  final AccountType accountType;
  final String? profileImageUrl;
  final String? bio;
  final String? district;
  final bool? isPhoneVisible;
  final String? companyName;
  final String? taxNumber;
  final String? landlinePhone;
  final String? addressDetail;
  final String? mapsUrl;
  final String? website;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phoneNumber,
    this.city,
    required this.role,
    required this.isVerified,
    required this.accountType,
    this.profileImageUrl,
    this.bio,
    this.district,
    this.isPhoneVisible,
    this.companyName,
    this.taxNumber,
    this.landlinePhone,
    this.addressDetail,
    this.mapsUrl,
    this.website,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        fullName,
        phoneNumber,
        city,
        role,
        isVerified,
        accountType,
        profileImageUrl,
        bio,
        district,
        isPhoneVisible,
        companyName,
        taxNumber,
        landlinePhone,
        addressDetail,
        mapsUrl,
        website,
      ];
}
