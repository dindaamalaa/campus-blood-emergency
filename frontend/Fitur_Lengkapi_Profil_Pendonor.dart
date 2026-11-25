import 'package:flutter/material.dart';
import '../../models/pendonor_profile.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final PendonorProfile? initialProfile;

  const CompleteProfileScreen({super.key, this.initialProfile});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _phoneController;
  late final TextEditingController _facultyController;

  late String _selectedBloodType;
  late bool _isWillingToDonate;
  bool _isSaving = false;

  static const List<String> _bloodTypes = ['A', 'B', 'AB', 'O', 'Belum Tahu'];

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController = TextEditingController(text: p?.namaLengkap ?? '');
    _nimController = TextEditingController(text: p?.nimIdCivitas ?? '');
    _phoneController = TextEditingController(text: p?.noTelepon ?? '');
    _facultyController = TextEditingController(text: p?.fakultasUnit ?? '');
    _selectedBloodType =
        _bloodTypes.contains(p?.golonganDarah) ? p!.golonganDarah : 'A';
    _isWillingToDonate = p?.bersediaDonor ?? true;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFD9383A),
        ),
      );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final draft = PendonorProfile(
      namaLengkap: _nameController.text.trim(),
      nimIdCivitas: _nimController.text.trim(),
      noTelepon: _phoneController.text.trim(),
      fakultasUnit: _facultyController.text.trim(),
      golonganDarah: _selectedBloodType,
      bersediaDonor: _isWillingToDonate,
    );

    final res = await ApiService.savePendonorProfile(draft);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!res.ok) {
      _showError(res.message);
      return;
    }

    final savedMap = res.raw['profile'];
    final savedProfile = savedMap is Map<String, dynamic>
        ? PendonorProfile.fromJson(savedMap)
        : draft;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          showSuccessBanner: true,
          initialProfile: savedProfile,
        ),
      ),
    );
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
        padding: const EdgeInsets.all(24),
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
              _buildField(
                controller: _nameController,
                hint: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _nimController,
                hint: 'NIM / ID Civitas',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _phoneController,
                hint: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _facultyController,
                hint: 'Fakultas / Unit',
                icon: Icons.apartment_outlined,
                textInputAction: TextInputAction.done,
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
                  final selected = _selectedBloodType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (isSel) {
                      if (isSel) setState(() => _selectedBloodType = type);
                    },
                    selectedColor: const Color(0xFF1E6BB8),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selected ? const Color(0xFF1E6BB8) : Colors.grey.shade400,
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
                    onChanged: (v) => setState(() => _isWillingToDonate = v),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: (val) {
        if (val == null || val.trim().isEmpty) return '$hint wajib diisi';
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
