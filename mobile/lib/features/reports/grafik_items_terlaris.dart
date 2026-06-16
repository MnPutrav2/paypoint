import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class ItemTerlarisData {
  final String label;
  final double value;
  const ItemTerlarisData({required this.label, required this.value});
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

const _dummyData = [
  ItemTerlarisData(label: 'Indomie', value: 320),
  ItemTerlarisData(label: 'Aqua', value: 275),
  ItemTerlarisData(label: 'Teh Botol', value: 410),
  ItemTerlarisData(label: 'Rinso', value: 190),
  ItemTerlarisData(label: 'Sunlight', value: 155),
  ItemTerlarisData(label: 'Pepsodent', value: 230),
];

const _listPeriode = ['Minggu', 'Bulan', 'Tahun'];

// ─── Widget ───────────────────────────────────────────────────────────────────

class GrafikItemTerlaris extends StatefulWidget {
  /// Called when the user picks a period. Receives e.g. `"harian"`.
  /// Replace [data] with real data from your backend/Redux equivalent.
  final List<ItemTerlarisData> data;
  final void Function(String periode)? onPeriodeChanged;

  const GrafikItemTerlaris({
    super.key,
    this.data = _dummyData,
    this.onPeriodeChanged,
  });

  @override
  State<GrafikItemTerlaris> createState() => _GrafikItemTerlarisState();
}

class _GrafikItemTerlarisState extends State<GrafikItemTerlaris> {
  String _selectedPeriode = _listPeriode.first;
  int? _touchedIndex;

  static const _colorPrimary = Color(0xFF1F5D84);
  static const _colorBar = Color(0xFFCCCCCC);
  static const _colorHighlight = Color(0xFF1F5D84);
  static const _colorActiveTouch = Color(0xFF0F3244);

  @override
  Widget build(BuildContext context) {
    final items = widget.data;
    final highest = items.isEmpty
        ? 0.0
        : items.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: _colorPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.layers,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Item Terlaris',
                    style: TextStyle(
                      color: _colorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // ── Period Dropdown ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriode,
                    isDense: true,
                    style: const TextStyle(color: _colorPrimary, fontSize: 12),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: _colorPrimary,
                    ),
                    items: _listPeriode
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _selectedPeriode = val);
                      widget.onPeriodeChanged?.call(val.toLowerCase());
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Bar Chart ───────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Tidak ada data'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: highest * 1.35, // extra room for top label
                      barTouchData: BarTouchData(
                        touchCallback:
                            (FlTouchEvent event, BarTouchResponse? resp) {
                              setState(() {
                                // isInterestedForInteractions = false saat pointer up/cancel
                                if (resp?.spot == null ||
                                    !event.isInterestedForInteractions) {
                                  _touchedIndex = null;
                                } else {
                                  _touchedIndex =
                                      resp!.spot!.touchedBarGroupIndex;
                                }
                              });
                            },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) =>
                              _colorPrimary.withOpacity(0.85),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${items[groupIndex].label}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: rod.toY.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= items.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  items[idx].label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: const Color(0xFFE5E7EB),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(items.length, (i) {
                        final isHighest = items[i].value == highest;
                        final isTouched = _touchedIndex == i;
                        final Color barColor = isTouched
                            ? _colorActiveTouch
                            : isHighest
                            ? _colorHighlight
                            : _colorBar;

                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: items[i].value,
                              color: barColor,
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5),
                              ),
                            ),
                          ],
                          showingTooltipIndicators: isTouched ? [0] : [],
                        );
                      }),
                    ),
                    // ── Highest-value badge (mimics the React circle label) ──
                    swapAnimationDuration: const Duration(milliseconds: 300),
                    swapAnimationCurve: Curves.easeInOut,
                  ),
          ),
        ],
      ),
    );
  }
}
