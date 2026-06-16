import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/utils/rupiah_extension.dart';
import '../providers/product_provider.dart';
import 'widgets/field_foto_produk.dart';
import 'widgets/field_kategori_dropdown.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/models/product.dart';

class EditProdukPage extends ConsumerStatefulWidget {
  final Product product; // pre-fill dari list

  const EditProdukPage({super.key, required this.product});

  @override
  ConsumerState<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends ConsumerState<EditProdukPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKeyPut = GlobalKey<FormState>();
  final _formKeyPatch = GlobalKey<FormState>();

  // ── PUT controllers (semua field) ──
  late final TextEditingController _namaCtrl;
  late final TextEditingController _detailCtrl;
  late final TextEditingController _hargaPutCtrl;
  late String? _selectedKategoriId;

  // ── PATCH controllers (sebagian) ──
  late final TextEditingController _hargaPatchCtrl;
  late final TextEditingController _stokCtrl;

  static const _bg = Color(0xFF121212);
  static const _surface = Color(0xFF1E1E1E);
  static const _border = Color(0xFF2E2E2E);
  static const _primary = AppColors.primaryLight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Pre-fill dari product object
    _namaCtrl = TextEditingController(text: widget.product.nama);
    _detailCtrl = TextEditingController(text: widget.product.detail);
    _hargaPutCtrl = TextEditingController(
      text: widget.product.harga.toStringAsFixed(0),
    );
    _selectedKategoriId = widget.product.kategori.id.toString();

    _hargaPatchCtrl = TextEditingController(
      text: widget.product.hargaJual!.toStringAsFixed(0),
    );
    _stokCtrl = TextEditingController(
      text: (widget.product.stok ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _namaCtrl.dispose();
    _detailCtrl.dispose();
    _hargaPutCtrl.dispose();
    _hargaPatchCtrl.dispose();
    _stokCtrl.dispose();
    super.dispose();
  }

  // ── Submit PUT ─────────────────────────────────────────────────────────────
  Future<void> _submitPatchProduk() async {
    if (!_formKeyPut.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      _showSnack('Pilih kategori produk', Colors.orange);
      return;
    }

    final harga =
        double.tryParse(_hargaPutCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;

    final product = await ref
        .read(editProdukProvider.notifier)
        .patchProduct(
          id: widget.product.id,
          nama: _namaCtrl.text.trim(),
          detail: _detailCtrl.text.trim(),
          harga: harga,
          kategoriId: _selectedKategoriId!,
        );

    if (!mounted) return;

    if (product != null) {
      final merged = product.copyWith(
        // Field yang mungkin tidak di-return server → fallback ke data lama
        foto: product.foto?.isNotEmpty == true
            ? product
                  .foto // server return foto baru
            : widget.product.foto, // pakai foto lama
        stok: product.stok,
        katalog: widget.product.katalog, // ← selalu dari data lama
        katalogId: widget.product.katalogId, // ← selalu dari data lama
        hargaJual: widget.product.hargaJual,
        // Field utama — kalau server return kosong, fallback ke data lama
        nama: product.nama.isNotEmpty ? product.nama : widget.product.nama,
        detail: product.detail!.isNotEmpty
            ? product.detail
            : widget.product.detail,
        harga: product.harga > 0 ? product.harga : widget.product.harga,
        kategori: product.kategori.id.isNotEmpty
            ? product.kategori
            : widget.product.kategori,
      );

      ref.read(produkListProvider.notifier).updateProductInList(merged);
      _showSnack(
        'Produk berhasil diupdate!',
        Colors.green.shade700,
        icon: Icons.check_circle,
      );
      Navigator.pop(context, true);
    } else {
      final error = ref.read(editProdukProvider).errorMessage;
      if (kDebugMode) {
        print('RESPONSE STATUS: $error');
      }
      _showSnack(error ?? 'Gagal update produk', Colors.red.shade700);
    }
  }

  // ── Submit PATCH ───────────────────────────────────────────────────────────
  Future<void> _submitPatchKatalog() async {
    if (!_formKeyPatch.currentState!.validate()) return;

    final harga = double.tryParse(
      _hargaPatchCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    try {
      final hasKatalog = widget.product.katalog!;

      if (!hasKatalog) {
        final katalog = await ref
            .read(editProdukProvider.notifier)
            .postKatalog(productId: widget.product.id, harga: harga);

        if (!mounted) return;

        ref
            .read(produkListProvider.notifier)
            .updateProductInList(
              widget.product.copyWith(
                katalog: true,
                katalogId: katalog.id,
                hargaJual: harga?.toInt(),
              ),
            );
      } else {
        final success = await ref
            .read(editProdukProvider.notifier)
            .patchKatalog(id: widget.product.katalogId!, harga: harga);

        if (!mounted) return;

        if (!success) {
          _showSnack(
            'Gagal memperbarui katalog',
            Colors.red.shade700,
            icon: Icons.error,
          );
          return;
        }

        ref
            .read(produkListProvider.notifier)
            .updateProductInList(
              widget.product.copyWith(hargaJual: harga?.toInt()),
            );
      }

      if (!mounted) return;

      _showSnack(
        'Produk berhasil diupdate!',
        Colors.green.shade700,
        icon: Icons.check_circle,
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString(), Colors.red.shade700, icon: Icons.error);
    }
  }

  void _showSnack(String msg, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(msg),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProdukProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: const Text(
          'Edit Produk',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: _primary,
          unselectedLabelColor: Colors.white38,
          indicatorColor: _primary,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Update Produk'), // PUT
            Tab(text: 'Update Harga Jual'), // PATCH
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPutForm(state), _buildPatchForm(state)],
      ),
    );
  }

  // ── TAB 1: PUT Form ────────────────────────────────────────────────────────
  Widget _buildPutForm(EditProdukState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyPut,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FieldFotoProduk(
              image: state.selectedImage,
              existingUrl: widget.product.foto, // foto lama dari server
              onImageSelected: (file) {
                ref.read(editProdukProvider.notifier).setImage(file);
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Nama Produk'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _namaCtrl,
              hint: 'Nama produk...',
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Detail Produk'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _detailCtrl,
              hint: 'Detail produk...',
              maxLines: 4,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            _buildLabel('Harga'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hargaPutCtrl,
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
                if ((double.tryParse(v) ?? 0) <= 0) return 'Harga tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 20),

            FieldKategoriDropdown(
              selectedId: _selectedKategoriId,
              onChanged: (id) => setState(() => _selectedKategoriId = id),
            ),
            const SizedBox(height: 32),

            _buildSubmitButton(
              label: 'Simpan Perubahan',
              isLoading: state.isLoading,
              onPressed: _submitPatchProduk,
            ),
            const SizedBox(height: 12),
            _buildCancelButton(state.isLoading),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── TAB 2: PATCH Form ──────────────────────────────────────────────────────
  Widget _buildPatchForm(EditProdukState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKeyPatch,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info card produk
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Update Harga Jual untuk "${widget.product.nama}"',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Harga Awal Produk'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product.harga.toRupiah(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Harga Jual'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hargaPatchCtrl,
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
                if (v != null && v.isNotEmpty) {
                  if ((double.tryParse(v) ?? 0) <= 0) {
                    return 'Harga tidak valid';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            _buildSubmitButton(
              label: 'Update',
              isLoading: state.isLoading,
              onPressed: _submitPatchKatalog,
            ),
            const SizedBox(height: 12),
            _buildCancelButton(state.isLoading),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────────────────────

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(hint),
      validator: validator,
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          disabledBackgroundColor: _primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildCancelButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: isLoading ? null : () => Navigator.pop(context),
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
