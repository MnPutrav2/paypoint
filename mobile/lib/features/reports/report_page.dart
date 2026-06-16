import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/core/utils/rupiah_extension.dart';
import 'package:kasir_offline/data/models/report.dart';
import 'package:kasir_offline/features/reports/card_market_basket.dart';
import 'package:kasir_offline/features/reports/grafik_items_terlaris.dart';
import 'package:kasir_offline/features/reports/grafik_linear_omzet.dart';
import 'package:kasir_offline/features/providers/report_provider.dart';
// import 'package:kasir_offline/data/dummy/dummy_products.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  //   String _periodeOmzet = 'Minggu';
  //   String _periodeItemTerlaris = 'Minggu';
  int _selectedPeriod = 0;
  final List<String> _periods = ['Minggu', 'Bulan', 'Tahun'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Builder(
          builder: (_) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage!, style: AppTextStyles.caption),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(reportProvider.notifier).fetchReport(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            final data = state.data;
            if (data == null) return const SizedBox();

            return RefreshIndicator(
              onRefresh: () => ref.read(reportProvider.notifier).fetchReport(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(data),
                    const SizedBox(height: 24),
                    _buildChartOverview(data),
                    const SizedBox(height: 24),
                    _buildGrafik(data, state.isGrafikLoading),
                    const SizedBox(height: 24),
                    _buildTopProducts(data),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laporan', style: AppTextStyles.heading2),
            Text('KAVI - Kasir', style: AppTextStyles.caption),
          ],
        ),
        IconButton(
          onPressed: () => ref.read(reportProvider.notifier).fetchReport(),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.primary,
        ),
        // Container(
        //   padding: const EdgeInsets.all(4),
        //   decoration: BoxDecoration(
        //     color: AppColors.backgroundCard,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: const Color(0xFFE2E8F0)),
        //   ),
        //   child: Row(
        //     children: List.generate(_periods.length, (i) {
        //       final isActive = _selectedPeriod == i;
        //       return GestureDetector(
        //         onTap: () => setState(() => _selectedPeriod = i),
        //         child: AnimatedContainer(
        //           duration: const Duration(milliseconds: 200),
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 12,
        //             vertical: 6,
        //           ),
        //           decoration: BoxDecoration(
        //             color: isActive ? AppColors.primary : Colors.transparent,
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //           child: Text(
        //             _periods[i],
        //             style: AppTextStyles.label.copyWith(
        //               color: isActive ? Colors.white : AppColors.textSecondary,
        //             ),
        //           ),
        //         ),
        //       );
        //     }),
        //   ),
        // ),
      ],
    );
  }

  // ===== SUMMARY CARDS =====
  Widget _buildSummaryCards(ReportModel data) {
    final cards = [
      {
        'label': 'Saldo',
        'value': data.saldo.toRupiah(),
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.primary,
        'isUp': true,
      },
      {
        'label': 'Total Omzet',
        'value': data.totalOmzet.toRupiah(),
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF16A34A),
        'isUp': true,
      },
      {
        'label': 'Total Profit',
        'value': data.totalProfit.toRupiah(),
        'icon': Icons.monetization_on_outlined,
        'color': const Color(0xFF7C3AED),
        'isUp': data.totalProfit >= 0,
      },
      {
        'label': 'Profit Hari Ini',
        'value': data.profitHariIni.toRupiah(),
        'icon': Icons.today_outlined,
        'color': const Color(0xFFEA580C),
        'isUp': data.profitHariIni >= 0,
      },
      {
        'label': 'Item Terjual',
        'value': '${data.itemTerjual}',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF0891B2),
        'isUp': true,
      },
      {
        'label': 'Belum Selesai',
        'value': '${data.transaksiBelumSelesai}',
        'icon': Icons.pending_actions_outlined,
        'color': const Color(0xFFDC2626),
        'isUp': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) {
        final card = cards[i];
        final color = card['color'] as Color;
        final isUp = card['isUp'] as bool;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: color,
                      size: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isUp
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: isUp
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card['value'] as String, style: AppTextStyles.heading2),
                  Text(card['label'] as String, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== CHART dari DummyTransactions.weekly ✅ =====
  Widget _buildChartOverview(ReportModel data) {
    final grafikOmzet = data.grafikOmzet;
    final maxVal = grafikOmzet.isEmpty
        ? 1
        : grafikOmzet
              .map((e) => e.value)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, double.maxFinite)
              .toInt();

    // final isMonth = _periods[_selectedPeriod] == 'Bulan';
    // final isYear = _periods[_selectedPeriod] == 'Tahun';

    // final itemWidth = isMonth
    //     ? 20.0
    //     : isYear
    //     ? 28.0
    //     : 40.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overview Omzet', style: AppTextStyles.heading3),
              Row(
                children: List.generate(_periods.length, (i) {
                  final isActive = _selectedPeriod == i;
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _selectedPeriod = i);
                      await ref
                          .read(reportProvider.notifier)
                          .fetchGrafik(
                            target: 'grafik_omzet',
                            mode: _periods[i].toLowerCase(),
                          );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.background
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFFE2E8F0)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _periods[i],
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // CHART
          grafikOmzet.isEmpty
              ? const SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              : SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // SUMBU Y
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [1.0, 0.75, 0.50, 0.25, 0.0].map((ratio) {
                          final val = (maxVal * ratio).toInt();
                          return Text(
                            val >= 1000
                                ? '${(val / 1000).toStringAsFixed(0)}k'
                                : '$val',
                            style: AppTextStyles.caption.copyWith(fontSize: 10),
                          );
                        }).toList(),
                      ),

                      const SizedBox(width: 8),

                      // BARS
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: grafikOmzet.map((item) {
                              final val = item.value;
                              final isMax = val == maxVal;
                              final heightRatio = maxVal > 0
                                  ? val / maxVal
                                  : 0.0;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,

                                    width: 40,
                                    // width: itemWidth,
                                    height: (120 * heightRatio).clamp(
                                      4.0,
                                      120.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMax
                                          ? AppColors.primaryDark
                                          : AppColors.primary.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGrafik(ReportModel data, bool isLoading) {
    try {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // ← tambah ini
        children: [
          // ── Chart 1: Item Terlaris ──────────────────────────────────
          GrafikItemTerlaris(
            data: data.grafikItemTerlaris
                .map(
                  (e) => ItemTerlarisData(
                    label: e.label,
                    value: e.value.toDouble(),
                  ),
                )
                .toList(),
            onPeriodeChanged: (periode) async {
              await ref
                  .read(reportProvider.notifier)
                  .fetchGrafik(target: 'grafik_item_terlaris', mode: periode);
            },
          ),

          const SizedBox(height: 16),

          // ── Chart 2: Prediksi Omzet ─────────────────────────────────
          GrafikLinearOmzet(
            data: OmzetPrediksiData(
              dataHistoris: data.prediksiOmzet.dataHistoris
                  .map(
                    (e) =>
                        HistorisItem(bulan: e.bulan, omzet: e.omzet.toDouble()),
                  )
                  .toList(),
              bulanPrediksi: data.prediksiOmzet.bulanPrediksi,
              nilaiPrediksi: data.prediksiOmzet.nilaiPrediksi.toDouble(),
              batasAtas: data.prediksiOmzet.batasAtas.toDouble(),
              batasBawah: data.prediksiOmzet.batasBawah.toDouble(),
            ),
          ),

          const SizedBox(height: 16),

          CardMarketBasket(data: data.marketBasket),
          const SizedBox(height: 24),
        ],
      );
    } catch (e, stack) {
      print('=== GRAFIK ERROR ===');
      print('ERROR: $e');
      print('STACK: $stack');
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
      );
    }
  }

  // ===== TOP PRODUCTS dari DummyProducts ✅ =====
  Widget _buildTopProducts(ReportModel data) {
    if (data.grafikItemTerlaris.isEmpty) return const SizedBox();

    final sorted = [...data.grafikItemTerlaris]
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produk Terlaris', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        ...top5.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final rankColors = [
            const Color(0xFFFEF9C3),
            const Color(0xFFF1F5F9),
            const Color(0xFFFFF7ED),
          ];
          final rankTextColors = [
            const Color(0xFFCA8A04),
            AppColors.textSecondary,
            const Color(0xFFEA580C),
          ];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: i < 3 ? rankColors[i] : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.label.copyWith(
                        color: i < 3
                            ? rankTextColors[i]
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.label, style: AppTextStyles.bodyBold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.value} terjual',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
