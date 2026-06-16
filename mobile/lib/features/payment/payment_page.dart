import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/repositories/transaksi_repository.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final String namaPembeli;
  final List<Map<String, dynamic>> items;
  final int totalHarga;
  final String metode; // ✅ tambah ini

  const PaymentPage({
    super.key,
    required this.namaPembeli,
    required this.items,
    required this.totalHarga,
    required this.metode, // ✅ tambah ini
  });

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  int _metodeBayar = 0; // pakai late, init di initState

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _nominalController = TextEditingController();
  int _nominalDiterima = 0;

  int get _kembalian => _nominalDiterima >= widget.totalHarga
      ? _nominalDiterima - widget.totalHarga
      : 0;

  bool get _cukup => _nominalDiterima >= widget.totalHarga;

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  // Nominal cepat (uang pas kelipatan)
  List<int> get _nominalCepat {
    final total = widget.totalHarga;
    final List<int> hasil = [];
    final kelipatan = [1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000];

    // ✅ Tambah uang pas dulu
    hasil.add(total);

    for (final k in kelipatan) {
      final nominal = ((total / k).ceil()) * k;
      if (!hasil.contains(nominal) && hasil.length < 4) {
        hasil.add(nominal);
      }
    }
    return hasil;
  }

  Future<void> _konfirmasiBayar() async {
    if (!_cukup) return;

    // ✅ Tampil loading dulu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(transaksiRepositoryProvider);
      await repo.createOrder(
        namaCustomer: widget.namaPembeli == 'Pembeli' ? '' : widget.namaPembeli,
        total: widget.totalHarga,
        items: widget.items,
      );

      // ✅ Tutup loading
      if (mounted) Navigator.pop(context);

      // ✅ Tampil dialog sukses
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pembayaran Berhasil!',
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kembalian: ${_formatRupiah(_kembalian)}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Terima kasih, ${widget.namaPembeli}!',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Kembali ke Beranda',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // ✅ Tutup loading kalau error
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan transaksi: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 140),
                  child: Column(
                    children: [
                      _buildInfoPembeli(),
                      const SizedBox(height: 12),
                      _buildRingkasanItems(),
                      const SizedBox(height: 12),
                      _buildInputTunai(),
                      const SizedBox(height: 12),
                      _buildInfoKembalian(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundCard,
      elevation: 0,
      pinned: true,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pembayaran', style: AppTextStyles.bodyBold),
          Text(widget.namaPembeli, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildInfoPembeli() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.namaPembeli[0].toUpperCase(),
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.namaPembeli, style: AppTextStyles.bodyBold),
                Text(
                  '${widget.items.length} produk · ${_formatRupiah(widget.totalHarga)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '⏳ Menunggu',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFFF59E0B),
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanItems() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🛍️ Pesanan', style: AppTextStyles.bodyBold),
          const SizedBox(height: 10),
          ...widget.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // ✅ Cek apakah icon URL atau emoji
                        _buildIcon(item['icon'] as String),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item['name']} x${item['qty']}',
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatRupiah(
                      (item['harga'] as int) * (item['qty'] as int),
                    ),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.bodyBold),
              Text(
                _formatRupiah(widget.totalHarga),
                style: AppTextStyles.price.copyWith(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildPilihMetode() {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: AppColors.backgroundCard,
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('💳 Metode Pembayaran', style: AppTextStyles.bodyBold),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             _buildMetodeCard(index: 0, icon: '💵', label: 'Tunai'),
  //             const SizedBox(width: 10),
  //             _buildMetodeCard(index: 1, icon: '🏦', label: 'Transfer'),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildIcon(String icon) {
    final isUrl = icon.startsWith('http');
    if (isUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          icon,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Text('🛍️'),
        ),
      );
    }
    return Text(icon, style: const TextStyle(fontSize: 20));
  }

  // Widget _buildMetodeCard({
  //   required int index,
  //   required String icon,
  //   required String label,
  // }) {
  //   final isSelected = _metodeBayar == index;
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () => setState(() => _metodeBayar = index),
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 200),
  //         padding: const EdgeInsets.symmetric(vertical: 14),
  //         decoration: BoxDecoration(
  //           color: isSelected
  //               ? AppColors.primary.withOpacity(0.08)
  //               : AppColors.background,
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(
  //             color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
  //             width: isSelected ? 2 : 1,
  //           ),
  //         ),
  //         child: Column(
  //           children: [
  //             Text(icon, style: const TextStyle(fontSize: 28)),
  //             const SizedBox(height: 6),
  //             Text(
  //               label,
  //               style: AppTextStyles.label.copyWith(
  //                 color: isSelected
  //                     ? AppColors.primary
  //                     : AppColors.textSecondary,
  //                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildInputTunai() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💵 Uang Diterima', style: AppTextStyles.bodyBold),
          const SizedBox(height: 10),
          // Input nominal
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  'Rp',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTextStyles.caption,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _nominalDiterima = int.tryParse(val) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Nominal cepat
          Text('Nominal cepat:', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _nominalCepat.map((nominal) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _nominalDiterima = nominal;
                    _nominalController.text = nominal.toString();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _nominalDiterima == nominal
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _nominalDiterima == nominal
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    _formatRupiah(nominal),
                    style: AppTextStyles.caption.copyWith(
                      color: _nominalDiterima == nominal
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: _nominalDiterima == nominal
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoKembalian() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cukup ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _cukup
              ? const Color(0xFF16A34A).withOpacity(0.3)
              : const Color(0xFFEF4444).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _cukup ? '✅ Kembalian' : '❌ Uang kurang',
                style: AppTextStyles.caption.copyWith(
                  color: _cukup
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!_cukup && _nominalDiterima > 0)
                Text(
                  'Kurang ${_formatRupiah(widget.totalHarga - _nominalDiterima)}',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          Text(
            _cukup ? _formatRupiah(_kembalian) : '-',
            style: AppTextStyles.price.copyWith(
              fontSize: 18,
              color: _cukup ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildInfoTransfer() {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: AppColors.backgroundCard,
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('🏦 Info Transfer', style: AppTextStyles.bodyBold),
  //         const SizedBox(height: 12),
  //         Container(
  //           padding: const EdgeInsets.all(14),
  //           decoration: BoxDecoration(
  //             color: AppColors.primary.withOpacity(0.05),
  //             borderRadius: BorderRadius.circular(10),
  //             border: Border.all(color: AppColors.primary.withOpacity(0.15)),
  //           ),
  //           child: Column(
  //             children: [
  //               _buildTransferRow('Bank', 'BCA'),
  //               const SizedBox(height: 8),
  //               _buildTransferRow('Atas Nama', 'Toko Kasir'),
  //               const SizedBox(height: 8),
  //               _buildTransferRow('No. Rekening', '1234-5678-9012'),
  //               const Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 10),
  //                 child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text('Total Transfer', style: AppTextStyles.bodyBold),
  //                   Text(
  //                     _formatRupiah(widget.totalHarga),
  //                     style: AppTextStyles.price.copyWith(
  //                       fontSize: 16,
  //                       color: AppColors.primary,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           '⚠️ Konfirmasi pembayaran setelah transfer selesai',
  //           style: AppTextStyles.caption.copyWith(
  //             color: const Color(0xFFF59E0B),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTransferRow(String label, String value) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(label, style: AppTextStyles.caption),
  //       Text(
  //         value,
  //         style: AppTextStyles.caption.copyWith(
  //           fontWeight: FontWeight.w700,
  //           color: AppColors.textPrimary,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBottomBar() {
    final bisa = _cukup;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bayar', style: AppTextStyles.caption),
                Text(
                  _formatRupiah(widget.totalHarga),
                  style: AppTextStyles.price.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: bisa ? _konfirmasiBayar : null,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: bisa
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        )
                      : null,
                  color: bisa ? null : AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: bisa
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _metodeBayar == 0 ? '💵' : '🏦',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _metodeBayar == 0
                          ? 'Konfirmasi Bayar Tunai'
                          : 'Konfirmasi Transfer',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
