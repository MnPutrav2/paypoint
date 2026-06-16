import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import 'widgets/field_foto_produk.dart';
import 'widgets/field_kategori_dropdown.dart';
import 'package:kasir_offline/core/index.dart';

class TambahProdukPage extends ConsumerStatefulWidget {
  const TambahProdukPage({super.key});

  @override
  ConsumerState<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends ConsumerState<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();

  String? _selectedKategoriId;

  // Warna utama — sesuaikan dengan AppColors project kamu
  static const _primary = AppColors.primaryLight;
  static const _bg = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);
  static const _border = Color(0xFF2E2E2E);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _detailCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori produk'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final hargaText = _hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final harga = int.tryParse(hargaText) ?? 0;

    final product = await ref
        .read(tambahProdukProvider.notifier)
        .tambahProduk(
          nama: _namaCtrl.text.trim(),
          detail: _detailCtrl.text.trim(),
          harga: harga,
          kategoriId: _selectedKategoriId!,
        );

    if (!mounted) return;

    if (product != null) {
      ref.read(produkListProvider.notifier).addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Produk berhasil ditambahkan!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // return true = ada data baru
    } else {
      final error = ref.read(tambahProdukProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menyimpan produk'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tambahProdukProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Foto Produk ──────────────────────────────
              FieldFotoProduk(
                image: state.selectedImage,
                onImageSelected: (file) {
                  ref.read(tambahProdukProvider.notifier).setImage(file);
                },
              ),
              const SizedBox(height: 20),

              // ── Nama Produk ──────────────────────────────
              _buildLabel('Nama Produk'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _namaCtrl,
                hint: 'Masukkan nama produk...',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Detail Produk ────────────────────────────
              _buildLabel('Detail Produk'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _detailCtrl,
                hint: 'Masukkan detail produk...',
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Detail produk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Harga ────────────────────────────────────
              _buildLabel('Harga'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hargaCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration('Contoh: 15000').copyWith(
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: const Text(
                      'Rp',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Harga wajib diisi';
                  final harga = double.tryParse(v);
                  if (harga == null || harga <= 0) return 'Harga tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Kategori ─────────────────────────────────
              FieldKategoriDropdown(
                selectedId: _selectedKategoriId,
                onChanged: (id) => setState(() => _selectedKategoriId = id),
              ),

              const SizedBox(height: 32),

              // ── Tombol Submit ────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    disabledBackgroundColor: _primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Produk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Tombol Batal ─────────────────────────────
              SizedBox(
                height: 52,
                child: TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: _border),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(hint),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}
