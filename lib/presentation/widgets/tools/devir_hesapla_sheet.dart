import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/config/env_config.dart';

class DevirHesaplaOptionsSheet extends StatelessWidget {
  const DevirHesaplaOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Text('Araç Devir Hesaplayıcı', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('2026 KKTC Mevzuatına Göre', style: TextStyle(color: AppColors.textHint)),
          const SizedBox(height: 32),
          _buildOption(
            context,
            icon: Icons.camera_alt_outlined,
            title: 'Ruhsatı/Koçanı Tara',
            subtitle: 'OCR ile otomatik veri ayıkla',
            onTap: () => _handleOCR(context),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context,
            icon: Icons.edit_note_outlined,
            title: 'Bilgileri Elle Gir',
            subtitle: 'Verileri kendiniz yazın',
            onTap: () {
              Navigator.pop(context);
              _showCalculatorForm(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOCR(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image == null) return;

    if (!context.mounted) return;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String? weight;
      String? year;

      // Simple Regex for weight (4 digits near kg or Tare) and year (20xx)
      final weightRegex = RegExp(r'(\d{4})\s*(?:kg|KG|Tare|Ağırlık)');
      final yearRegex = RegExp(r'\b(20\d{2})\b');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text;
          
          if (weight == null) {
            final match = weightRegex.firstMatch(text);
            if (match != null) weight = match.group(1);
          }
          
          if (year == null) {
            final match = yearRegex.firstMatch(text);
            if (match != null) year = match.group(1);
          }
        }
      }

      textRecognizer.close();
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close options sheet
        _showCalculatorForm(context, initialWeight: weight, initialYear: year);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OCR Hatası: $e')));
      }
    }
  }

  void _showCalculatorForm(BuildContext context, {String? initialWeight, String? initialYear}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DevirHesaplaForm(initialWeight: initialWeight, initialYear: initialYear),
    );
  }
}

class DevirHesaplaForm extends StatefulWidget {
  final String? initialWeight;
  final String? initialYear;

  const DevirHesaplaForm({super.key, this.initialWeight, this.initialYear});

  @override
  State<DevirHesaplaForm> createState() => _DevirHesaplaFormState();
}

class _DevirHesaplaFormState extends State<DevirHesaplaForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCurrency = 'GBP';
  String _selectedFuelType = 'benzin';
  
  final Map<String, double> _rates = {'TL': 1.0, 'GBP': 42.5, 'EUR': 36.2, 'USD': 33.8}; // 2026 Tahmini kurlar
  
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _weightController.text = widget.initialWeight ?? '';
    _yearController.text = widget.initialYear ?? '';
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double priceInTl = double.parse(_priceController.text) * (_rates[_selectedCurrency] ?? 1.0);
      
      final dio = Dio();
      final response = await dio.get(
        '${EnvConfig.baseUrl}/hesapla-devir',
        queryParameters: {
          'agirlik': int.parse(_weightController.text),
          'yil': int.parse(_yearController.text),
          'satis_fiyati': priceInTl.toInt(),
          'yakit_tipi': _selectedFuelType,
        },
      );

      setState(() {
        _result = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hesaplama Hatası: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hesaplama Bilgileri', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Satış Fiyatı',
                            icon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildDropdown<String>(
                            value: _selectedCurrency,
                            items: ['TL', 'GBP', 'EUR', 'USD'],
                            onChanged: (v) => setState(() => _selectedCurrency = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFuelTypeToggle(),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Ağırlık (kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _yearController,
                            label: 'Model Yılı',
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _calculate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('HESAPLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 32),
                      _buildResultCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildToggleItem('Benzin/Dizel', 'benzin'),
          _buildToggleItem('Elektrikli', 'elektrik'),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, String value) {
    final isSelected = _selectedFuelType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFuelType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textHint,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString(), style: const TextStyle(color: AppColors.textPrimary)))).toList(),
          onChanged: onChanged,
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Gerekli' : null,
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('Tahmini Masraf Aralığı', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            _result!['tahmini_aralik'],
            style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32, color: Colors.white10),
          _buildDetailRow('Ağırlık Harcı', '${_result!['detaylar']['agirlik_harci']} TL'),
          const SizedBox(height: 12),
          _buildDetailRow('Noter Harcı (min)', '${_result!['detaylar']['noter_harci']} TL'),
          const SizedBox(height: 12),
          if (_result!['detaylar']['yas_indirimi'] > 0) ...[
            _buildDetailRow('Yaş İndirimi', '-${_result!['detaylar']['yas_indirimi']} TL'),
            const SizedBox(height: 12),
          ],
          _buildDetailRow('Evrak Masrafları', '${_result!['detaylar']['evrak_masraflari']} TL'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _result!['uyari'],
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textHint)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
