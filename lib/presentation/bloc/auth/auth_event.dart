import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String username;
  final String password;
  final String? fullName;
  final String? phoneNumber;
  final String? city;
  final String accountType;
  final String? profileImageUrl;
  final String? bio;
  final String? district;
  final bool isPhoneVisible;
  final String? companyName;
  final String? taxNumber;
  final String? landlinePhone;
  final String? addressDetail;
  final String? mapsUrl;
  final String? website;

  const RegisterRequested({
    required this.email,
    required this.username,
    required this.password,
    this.fullName,
    this.phoneNumber,
    this.city,
    required this.accountType,
    this.profileImageUrl,
    this.bio,
    this.district,
    required this.isPhoneVisible,
    this.companyName,
    this.taxNumber,
    this.landlinePhone,
    this.addressDetail,
    this.mapsUrl,
    this.website,
  });

  @override
  List<Object> get props => [
        email,
        username,
        password,
        fullName ?? '',
        phoneNumber ?? '',
        city ?? '',
        accountType,
        profileImageUrl ?? '',
        bio ?? '',
        district ?? '',
        isPhoneVisible,
        companyName ?? '',
        taxNumber ?? '',
        landlinePhone ?? '',
        addressDetail ?? '',
        mapsUrl ?? '',
        website ?? '',
      ];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
