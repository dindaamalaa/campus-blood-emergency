import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facultyController = TextEditingController();

  String _selectedBloodType = 'A';
  bool _isWillingToDonate = true;
  bool _isSaving = false;

  final List<String> _bloodTypes = ['A', 'B', 'AB', 'O', 'Belum Tahu'];

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFD9383A),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final result = await ApiService.savePendonorProfile(
        namaLengkap: _nameController.text.trim(),
        nimIdCivitas: _nimController.text.trim(),
        noTelepon: _phoneController.text.trim(),
        fakultasUnit: _facultyController.text.trim(),
        golonganDarah: _selectedBloodType,
        bersediaDonor: _isWillingToDonate,
      );

      final data = result['data'] as Map<String, dynamic>;
      if (result['ok'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              showSuccessBanner: true,
              initialProfile: data['profile'] as Map<String, dynamic>?,
            ),
          ),
        );
      } else {
        _showError(data['message'] ?? 'Gagal menyimpan profil');
      }
    } catch (e) {
      _showError('Gagal terhubung ke server: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Lengkapi Profil Pendonor',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Identitas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _nameController,
                hint: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _nimController,
                hint: 'NIM / ID Civitas',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _phoneController,
                hint: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                controller: _facultyController,
                hint: 'Fakultas / Unit',
                icon: Icons.apartment_outlined,
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.water_drop, size: 20, color: Color(0xFFD9383A)),
                  SizedBox(width: 8),
                  Text(
                    'Golongan Darah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _bloodTypes.map((type) {
                  final isSelected = _selectedBloodType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedBloodType = type);
                      }
                    },
                    selectedColor: const Color(0xFF1E6BB8),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF1E6BB8) : Colors.grey.shade400,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Switch(
                    value: _isWillingToDonate,
                    activeColor: const Color(0xFF1E6BB8),
                    onChanged: (val) => setState(() => _isWillingToDonate = val),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Saya bersedia menjadi pendonor darah',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9383A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Profil Pendonor',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return '$hint wajib diisi';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
