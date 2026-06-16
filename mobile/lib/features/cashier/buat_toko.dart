import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

class BuatToko extends StatefulWidget {
  const BuatToko({super.key});

  @override
  State<BuatToko> createState() => _BuatToko();
}

class _BuatToko extends State<BuatToko> {
  // ===== CONTROLLERS =====
  // Controller = alat untuk ambil/kontrol isi TextField
  final TextEditingController _namaToko = TextEditingController();
  final TextEditingController _namaPengguna = TextEditingController();
  final TextEditingController _negara = TextEditingController();
  final TextEditingController _provinsi = TextEditingController();
  final TextEditingController _kecamatan = TextEditingController();
  final TextEditingController _alamat = TextEditingController();

  // ===== DROPDOWN =====
  String? _jenisUsaha; // null = belum dipilih
  final List<String> _listJenisUsaha = [
    'Retail / Toko Umum',
    'Restoran / Cafe',
    'Fashion',
    'Elektronik',
    'Kesehatan & Kecantikan',
    'Lainnya',
  ];

  // ===== DISPOSE =====
  // Wajib dispose controller supaya tidak bocor memori
  @override
  void dispose() {
    _namaToko.dispose();
    _namaPengguna.dispose();
    _negara.dispose();
    _provinsi.dispose();
    _kecamatan.dispose();
    _alamat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // supaya bisa scroll
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== JUDUL =====
              const Center(
                child: Text(
                  'Buat Toko kamu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== NAMA TOKO =====
              _buildTextField(controller: _namaToko, hint: 'Nama Toko'),

              const SizedBox(height: 12),

              // ===== NAMA PENGGUNA =====
              _buildTextField(controller: _namaPengguna, hint: 'Nama pengguna'),

              const SizedBox(height: 12),

              // ===== DROPDOWN JENIS USAHA =====
              _buildDropdown(),

              const SizedBox(height: 24),

              // ===== NEGARA =====
              _buildTextField(controller: _negara, hint: 'Negara'),

              const SizedBox(height: 12),

              // ===== PROVINSI =====
              _buildTextField(controller: _provinsi, hint: 'Provinsi'),

              const SizedBox(height: 12),

              // ===== KECAMATAN =====
              _buildTextField(controller: _kecamatan, hint: 'kecamatan'),

              const SizedBox(height: 12),

              // ===== ALAMAT (multiline) =====
              _buildTextArea(),

              // ===== KETERANGAN ALAMAT =====
              const Padding(
                padding: EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  'buatlah alamat toko yang benar agar orang lain mudah mencari toko kamu',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 32),

              // ===== TOMBOL SIMPAN =====
              _buildButton(
                label: 'Simpan',
                onTap: () {
                  // nanti isi logika simpan data di sini
                  //   print('Nama Toko: ${_namaToko.text}');
                  //   print('Jenis Usaha: $_jenisUsaha');
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ===== REUSABLE WIDGETS =====

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTextArea() {
    return TextField(
      controller: _alamat,
      maxLines: 4, // tinggi 4 baris
      minLines: 4, // minimal 4 baris
      decoration: InputDecoration(
        hintText: 'Masukan alamat toko kamu',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        // hilangkan garis bawah
        child: DropdownButton<String>(
          value: _jenisUsaha,
          hint: const Text(
            'Pilih jenis usaha',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          isExpanded: true, // lebar penuh
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _listJenisUsaha.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _jenisUsaha = value; // update pilihan
            });
          },
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4F72),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
