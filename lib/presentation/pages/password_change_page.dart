import 'package:flutter/material.dart';
class PasswordChangePage extends StatelessWidget {
  const PasswordChangePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şifre Değiştir')),
      body: const Center(child: Text('Şifre değiştirme alanı')),
    );
  }
}