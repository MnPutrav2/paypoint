import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/data/dummy/dummy_orders.dart';
import 'package:kasir_offline/data/dummy/dummy_products.dart';

class PaymentDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const PaymentDetailPage({super.key, required this.order});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  int _selectedMethod = 0; // 0=Cash, 1=QRIS
  final TextEditingController _cashController = TextEditingController();
  int _uangDiterima = 0;

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  int get _totalHarga => widget.order['totalHarga'] as int;
  int get _kembalian => _uangDiterima - _totalHarga;

  @override
  void dispose() {
    _cashController.dispose();
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildItems(),
                      const SizedBox(height: 14),
                      _buildMethodSelector(),
                      const SizedBox(height: 14),
                      _buildTotalBox(),
                      const SizedBox(height: 14),
                      if (_selectedMethod == 0) _buildCashSection(),
                      if (_selectedMethod == 1) _buildQrisSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_selectedMethod == 0) _buildBottomBar(),
        ],
      ),
    );
  }

  // ===== APP BAR =====
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
          Text(widget.order['id'] as String, style: AppTextStyles.bodyBold),
          Text(
            widget.order['namaPembeli'] as String,
            style: AppTextStyles.caption,
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
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
            ),
          ),
        ),
      ],
    );
  }

  // ===== ITEMS =====
  Widget _buildItems() {
    final List items = widget.order['items'] as List;

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
          Text(
            '🛍️ Produk Dipesan',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    e['icon'] as String,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name'] as String, style: AppTextStyles.label),
                        Text(
                          '${e['color']} · x${e['qty']}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatRupiah((e['priceValue'] as int) * (e['qty'] as int)),
                    style: AppTextStyles.price.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== METHOD SELECTOR =====
  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💳 Metode Pembayaran',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildMethodOption(0, '💵', 'Cash'),
            const SizedBox(width: 10),
            _buildMethodOption(1, '📱', 'QRIS'),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodOption(int index, String icon, String label) {
    final bool isActive = _selectedMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedMethod = index;
          _cashController.clear();
          _uangDiterima = 0;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.06)
                : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== TOTAL BOX =====
  Widget _buildTotalBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Pembayaran', style: AppTextStyles.caption),
          Text(
            _formatRupiah(_totalHarga),
            style: AppTextStyles.price.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  // ===== CASH SECTION =====
  Widget _buildCashSection() {
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
          Text(
            '💵 Uang Diterima',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // INPUT
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Text(
                  'Rp',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _cashController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyBold,
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTextStyles.caption,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _uangDiterima =
                            int.tryParse(val.replaceAll('.', '')) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // KEMBALIAN
          if (_uangDiterima >= _totalHarga) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '💚 Kembalian',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatRupiah(_kembalian),
                    style: AppTextStyles.price.copyWith(
                      color: const Color(0xFF16A34A),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // KURANG BAYAR
          if (_uangDiterima > 0 && _uangDiterima < _totalHarga) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '❗ Kurang',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatRupiah(_totalHarga - _uangDiterima),
                    style: AppTextStyles.price.copyWith(
                      color: const Color(0xFFEF4444),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== QRIS SECTION =====
  Widget _buildQrisSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Text('Scan QR untuk Membayar', style: AppTextStyles.bodyBold),
          const SizedBox(height: 4),
          Text(
            'Gunakan aplikasi mobile banking apapun',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),

          // QR CODE
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomPaint(painter: _QrPainter()),
          ),
          const SizedBox(height: 14),

          Text(
            _formatRupiah(_totalHarga),
            style: AppTextStyles.price.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(widget.order['id'] as String, style: AppTextStyles.caption),
          const SizedBox(height: 12),

          // BANK CHIPS
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: ['BCA', 'Mandiri', 'BNI', 'GoPay', 'OVO', 'Dana']
                .map(
                  (b) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      b,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // KONFIRMASI BUTTON
          GestureDetector(
            onTap: () => _konfirmasiQris(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Konfirmasi Pembayaran Diterima',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== BOTTOM BAR CASH =====
  Widget _buildBottomBar() {
    final bool bisa = _uangDiterima >= _totalHarga;

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
        child: GestureDetector(
          onTap: bisa ? () => _showPinDialog() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
                const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Bayar Sekarang',
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
      ),
    );
  }

  // ===== SHOW PIN DIALOG =====
  void _showPinDialog() {
    String pin = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setPin) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔐 Konfirmasi PIN', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(
                  'Masukkan PIN kasir 4 digit',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 20),

                // PIN DOTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < pin.length
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: i < pin.length
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // ERROR TEXT
                Text(
                  '',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 14),

                // NUMPAD
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                      (n) => _numBtn(n, () {
                        if (pin.length < 4) {
                          setPin(() => pin += n);
                        }
                      }),
                    ),
                    const SizedBox(),
                    _numBtn('0', () {
                      if (pin.length < 4) {
                        setPin(() => pin += '0');
                      }
                    }),
                    _numBtn('⌫', () {
                      if (pin.isNotEmpty) {
                        setPin(() => pin = pin.substring(0, pin.length - 1));
                      }
                    }, isDelete: true),
                  ],
                ),
                const SizedBox(height: 14),

                // CONFIRM BUTTON
                GestureDetector(
                  onTap: pin.length == 4
                      ? () {
                          if (pin == '1234') {
                            // PIN benar!
                            Navigator.of(ctx).pop();
                            _bayarBerhasil('Cash');
                          } else {
                            // PIN salah
                            setPin(() => pin = '');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('PIN salah! Coba lagi.'),
                                backgroundColor: const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: pin.length == 4
                          ? const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            )
                          : null,
                      color: pin.length == 4
                          ? null
                          : AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Konfirmasi Pembayaran',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== KONFIRMASI QRIS =====
  void _konfirmasiQris() {
    _bayarBerhasil('QRIS');
  }

  // ===== BAYAR BERHASIL =====

  void _bayarBerhasil(String metode) {
    DummyOrders.markAsPaid(widget.order['id'] as String, metode);

    // Kurangi stok per warna ✅
    final List items = widget.order['items'] as List;
    for (final item in items) {
      final String name = item['name'] as String;
      final String color = item['color'] as String;
      final int qty = item['qty'] as int;

      final int index = DummyProducts.products.indexWhere(
        (p) => p['name'] == name,
      );

      if (index >= 0) {
        // Kurangi stok total
        final int currentStock = DummyProducts.products[index]['stock'] as int;
        DummyProducts.products[index]['stock'] = (currentStock - qty).clamp(
          0,
          currentStock,
        );

        // Kurangi stok per warna ✅
        final Map<String, dynamic> spc =
            DummyProducts.products[index]['stockPerColor']
                as Map<String, dynamic>;
        final int currentColorStock = spc[color] as int;
        spc[color] = (currentColorStock - qty).clamp(0, currentColorStock);
      }
    }

    // Dialog sukses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                '${widget.order['id']} telah lunas.\nTotal: ${_formatRupiah(_totalHarga)}',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.pushReplacement('/payment');
                },
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Selesai ✓',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== NUM BUTTON =====
  Widget _numBtn(String label, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDelete ? const Color(0xFFFEF2F2) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDelete ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyBold.copyWith(
              color: isDelete ? const Color(0xFFEF4444) : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ===== QR PAINTER =====
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF1B4F72)
      ..style = PaintingStyle.fill;

    final double cell = size.width / 10;

    // Finder patterns
    _drawFinder(canvas, paint, 0, 0, cell);
    _drawFinder(canvas, paint, 7 * cell, 0, cell);
    _drawFinder(canvas, paint, 0, 7 * cell, cell);

    // Data modules simulasi
    final List<List<int>> data = [
      [3, 0],
      [4, 0],
      [5, 0],
      [3, 2],
      [5, 2],
      [4, 3],
      [5, 3],
      [0, 3],
      [1, 3],
      [3, 3],
      [4, 3],
      [6, 3],
      [7, 3],
      [9, 3],
      [0, 4],
      [2, 4],
      [4, 4],
      [5, 4],
      [7, 4],
      [8, 4],
      [0, 5],
      [2, 5],
      [3, 5],
      [5, 5],
      [6, 5],
      [8, 5],
      [3, 6],
      [4, 6],
      [6, 6],
      [7, 6],
      [9, 6],
      [4, 7],
      [5, 7],
      [7, 7],
      [3, 8],
      [5, 8],
      [6, 8],
      [8, 8],
      [9, 8],
      [3, 9],
      [5, 9],
      [7, 9],
      [9, 9],
    ];

    for (final d in data) {
      canvas.drawRect(
        Rect.fromLTWH(d[0] * cell, d[1] * cell, cell * 0.8, cell * 0.8),
        paint,
      );
    }
  }

  void _drawFinder(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double cell,
  ) {
    // Outer
    final outer = Paint()
      ..color = const Color(0xFF1B4F72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.8;
    canvas.drawRect(
      Rect.fromLTWH(x + cell * 0.4, y + cell * 0.4, cell * 6.2, cell * 6.2),
      outer,
    );
    // Inner
    final inner = Paint()
      ..color = const Color(0xFF1B4F72)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3),
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
