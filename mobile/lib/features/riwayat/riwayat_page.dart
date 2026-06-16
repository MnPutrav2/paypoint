import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/core/utils/waktu_indo.dart';
import 'package:kasir_offline/data/models/transaksi_model.dart';
import 'package:kasir_offline/data/repositories/transaksi_repository.dart';
import 'package:kasir_offline/features/riwayat/invoice_page.dart';

class TransaksiParams {
  final String keyword;
  final int pageIndex;
  final String sortBy;

  const TransaksiParams({
    required this.keyword,
    required this.pageIndex,
    required this.sortBy,
  });

  @override
  bool operator ==(Object other) =>
      other is TransaksiParams &&
      other.keyword == keyword &&
      other.pageIndex == pageIndex &&
      other.sortBy == sortBy;

  @override
  int get hashCode => Object.hash(keyword, pageIndex, sortBy);
}

// Di riwayat_page.dart, ganti provider:
final transaksiProvider =
    FutureProvider.family<TransaksiResponse, TransaksiParams>((ref, params) {
      final repo = ref.watch(transaksiRepositoryProvider);
      return repo.getTransaksi(
        keyword: params.keyword,
        pageIndex: params.pageIndex,
        pageSize: 10,
        sortBy: params.sortBy,
      );
    });

class RiwayatPage extends ConsumerStatefulWidget {
  const RiwayatPage({super.key});

  @override
  ConsumerState<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends ConsumerState<RiwayatPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _keyword = '';
  int _currentPage = 0;
  static const _pageSize = 10;
  Timer? _debounce;
  String _sortBy = 'terbaru';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(transaksiProvider); // ← tambah ini
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(int value) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return 'Rp ${formatter.format(value)}';
  }

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('EEE, d MMM yyyy HH.mm', 'id_ID').format(dt);
    } catch (_) {
      return raw;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFF16A34A);
      case 'sudah bayar':
      case 'sudah_bayar':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return const Color(0xFFDCFCE7);
      case 'sudah bayar':
      case 'sudah_bayar':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Di build:
    final transaksiAsync = ref.watch(
      transaksiProvider(
        TransaksiParams(
          keyword: _keyword,
          pageIndex: _currentPage,
          sortBy: _sortBy,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: _buildSearchBar(),
            ),
          ),
          transaksiAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(child: _buildErrorState()),
            data: (data) {
              // ✅ Hitung total pages dari data yang ada
              // Sementara: kalau dapat 15 berarti mungkin masih ada next
              // Nanti ganti dengan data.total dari BE
              if (data.items.isEmpty && _currentPage == 0) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              return SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ✅ List item
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      child: Column(
                        children: data.items
                            .map((item) => _buildCard(item))
                            .toList(),
                      ),
                    ),

                    // ✅ Pagination bar
                    if (data.items.isNotEmpty)
                      _buildPaginator(data.items.length),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ Widget paginator nomor halaman
  Widget _buildPaginator(int itemCount) {
    final isLastPage = itemCount < _pageSize;
    if (_currentPage == 0 && isLastPage) return const SizedBox.shrink();

    final firstEntry = (_currentPage * _pageSize) + 1;
    final lastEntry = isLastPage
        ? (_currentPage * _pageSize) + itemCount
        : (_currentPage + 1) * _pageSize;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pageBtn(
            icon: Icons.chevron_left_rounded,
            onTap: _currentPage > 0
                ? () {
                    setState(() => _currentPage--);
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Menampilkan $firstEntry–$lastEntry data',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLastPage)
                Text(
                  'Halaman terakhir',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),

          _pageBtn(
            icon: Icons.chevron_right_rounded,
            onTap: !isLastPage
                ? () {
                    setState(() => _currentPage++);
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Tombol prev/next
  Widget _pageBtn({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.backgroundCard : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFE2E8F0).withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundCard,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Riwayat Transaksi', style: AppTextStyles.bodyBold),
          Text('Semua transaksi kamu', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                hintText: 'Cari invoice atau nama customer...',
                hintStyle: AppTextStyles.caption,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _keyword.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _keyword = '';
                            _currentPage = 0;
                          });
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: (val) {
                // Cancel debounce sebelumnya
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _keyword = val;
                      _currentPage = 0;
                    });
                  }
                });
              },
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Tombol sort
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (val) {
              ref.invalidate(transaksiProvider);
              setState(() {
                _sortBy = val;
                _currentPage = 0;
              });
            },

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              _sortMenuItem('terbaru', Icons.arrow_downward_rounded, 'Terbaru'),
              _sortMenuItem('terlama', Icons.arrow_upward_rounded, 'Terlama'),
              _sortMenuItem('nama_az', Icons.sort_by_alpha_rounded, 'Nama A–Z'),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 20,
                    color: _sortBy != 'terbaru'
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _sortLabel(_sortBy),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: _sortBy != 'terbaru'
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: _sortBy != 'terbaru'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _sortMenuItem(String val, IconData icon, String label) {
    final isActive = _sortBy == val;
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          if (isActive)
            const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  String _sortLabel(String sortBy) {
    switch (sortBy) {
      case 'terlama':
        return 'Terlama';
      case 'nama_az':
        return 'Nama A–Z';
      default:
        return 'Terbaru';
    }
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🧾', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('Belum ada transaksi', style: AppTextStyles.bodyBold),
        const SizedBox(height: 6),
        Text(
          'Transaksi yang sudah dibuat akan muncul di sini',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('😕', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text('Gagal memuat data', style: AppTextStyles.bodyBold),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() {}),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Coba Lagi',
              style: AppTextStyles.label.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(TransaksiModel t) {
    debugPrint('📅 createdAt raw: ${t.createdAt}');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(parseAndFormat(t.createdAt), style: AppTextStyles.caption),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusBgColor(t.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _statusColor(t.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      t.status.isEmpty ? 'pending' : t.status,
                      style: AppTextStyles.caption.copyWith(
                        color: _statusColor(t.status),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.invoice, style: AppTextStyles.bodyBold),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer', style: AppTextStyles.caption),
              Text(
                t.namaCustomer.isEmpty ? '-' : t.namaCustomer,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.caption),
              Text(
                _formatRupiah(t.total),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            // Di _buildCard, ganti onTap tombol Invoice:
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => InvoicePage(transaksi: t)),
              );
              if (result == true && mounted) {
                ref.invalidate(transaksiProvider); // ← tambah ini
                setState(() {});
              }
            },
            child: Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Invoice',
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
}
