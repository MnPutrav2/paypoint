import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class HistorisItem {
  final String bulan; // e.g. "Jan 2024"
  final double omzet;
  const HistorisItem({required this.bulan, required this.omzet});
}

class OmzetPrediksiData {
  final List<HistorisItem> dataHistoris;
  final String bulanPrediksi; // e.g. "Jul 2025"
  final double nilaiPrediksi;
  final double batasAtas;
  final double batasBawah;

  const OmzetPrediksiData({
    required this.dataHistoris,
    required this.bulanPrediksi,
    required this.nilaiPrediksi,
    required this.batasAtas,
    required this.batasBawah,
  });
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

final _dummyOmzetData = OmzetPrediksiData(
  dataHistoris: const [
    HistorisItem(bulan: 'Jan 2025', omzet: 12_500_000),
    HistorisItem(bulan: 'Feb 2025', omzet: 14_200_000),
    HistorisItem(bulan: 'Mar 2025', omzet: 13_800_000),
    HistorisItem(bulan: 'Apr 2025', omzet: 15_600_000),
    HistorisItem(bulan: 'Mei 2025', omzet: 17_100_000),
    HistorisItem(bulan: 'Jun 2025', omzet: 16_400_000),
  ],
  bulanPrediksi: 'Jul 2025',
  nilaiPrediksi: 18_300_000,
  batasAtas: 20_500_000,
  batasBawah: 16_100_000,
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _rupiah(double val) {
  final f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return f.format(val);
}

String _shortRupiah(double val) {
  if (val >= 1_000_000_000) {
    return 'Rp ${(val / 1_000_000_000).toStringAsFixed(1)}M';
  } else if (val >= 1_000_000) {
    return 'Rp ${(val / 1_000_000).toStringAsFixed(1)}jt';
  } else if (val >= 1_000) {
    return 'Rp ${(val / 1_000).toStringAsFixed(0)}rb';
  }
  return _rupiah(val);
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class GrafikLinearOmzet extends StatefulWidget {
  /// Pass real [OmzetPrediksiData] from your backend/provider.
  /// Defaults to [_dummyOmzetData] for development.
  final OmzetPrediksiData data;

  GrafikLinearOmzet({super.key, OmzetPrediksiData? data})
    : data = data ?? _dummyOmzetData;

  @override
  State<GrafikLinearOmzet> createState() => _GrafikLinearOmzetState();
}

class _GrafikLinearOmzetState extends State<GrafikLinearOmzet> {
  static const _colorPrimary = Color(0xFF1F5D84);
  static const _colorActual = Color(0xFF2563EB); // blue – historis
  static const _colorPrediksi = Color(0xFFF97316); // orange – prediksi
  static const _colorBand = Color(0xFFF59E0B); // amber – confidence band

  int? _touchedSpotIndex;

  // Build a unified list: historis + satu titik prediksi
  List<_ChartPoint> get _points {
    final hist = widget.data.dataHistoris;
    return [
      for (final h in hist)
        _ChartPoint(
          label: h.bulan,
          omzet: h.omzet,
          prediksi: null,
          batasAtas: null,
          batasBawah: null,
        ),
      _ChartPoint(
        label: widget.data.bulanPrediksi,
        omzet: null,
        prediksi: widget.data.nilaiPrediksi,
        batasAtas: widget.data.batasAtas,
        batasBawah: widget.data.batasBawah,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final points = _points;
    final hist = widget.data.dataHistoris;
    final d = widget.data;

    // Collect all Y values to compute axis bounds
    final allY = [
      ...hist.map((e) => e.omzet),
      d.nilaiPrediksi,
      d.batasAtas,
      d.batasBawah,
    ];
    final minY = (allY.reduce((a, b) => a < b ? a : b) * 0.85).roundToDouble();
    final maxY = (allY.reduce((a, b) => a > b ? a : b) * 1.15).roundToDouble();

    return Container(
      height: 380,
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: const BoxDecoration(
                  color: _colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.layers, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prediksi : Laba-Rugi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Simple linear Regression Algoritm',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Legend ──────────────────────────────────────────────────────────
          Wrap(
            spacing: 16,
            children: [
              _LegendItem(color: _colorActual, label: 'Omzet Aktual'),
              _LegendItem(
                color: _colorPrediksi,
                label: 'Prediksi',
                isDashed: true,
              ),
              _LegendItem(
                color: _colorBand,
                label: 'Confidence Band',
                isFill: true,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Chart ───────────────────────────────────────────────────────────
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  touchSpotThreshold:
                      20, // <- supaya tidak semua line tersentuh sekaligus
                  touchCallback: (FlTouchEvent event, LineTouchResponse? resp) {
                    setState(() {
                      // isInterestedForInteractions = false saat pointer up/cancel
                      if (resp?.lineBarSpots == null ||
                          !event.isInterestedForInteractions) {
                        _touchedSpotIndex = null;
                      } else {
                        _touchedSpotIndex = resp!.lineBarSpots!.first.spotIndex;
                      }
                    });
                  },
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((si) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.grey.withOpacity(0.4),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 6,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: bar.color ?? Colors.grey,
                              ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => _colorPrimary.withOpacity(0.9),
                    getTooltipItems: (touchedSpots) {
                      // Wajib return list dengan length == touchedSpots.length
                      // null = sembunyikan tooltip untuk spot tersebut
                      return touchedSpots.map((spot) {
                        // Hanya tampilkan tooltip untuk line index 0 (aktual) dan 3 (prediksi)
                        // Line 1 & 2 adalah invisible band lines — skip
                        if (spot.barIndex == 1 || spot.barIndex == 2)
                          return null;

                        if (spot.barIndex == 3) {
                          // Line prediksi
                          return LineTooltipItem(
                            '${widget.data.bulanPrediksi}\n\n'
                            'Batas Atas  : ${_rupiah(widget.data.batasAtas)}\n'
                            'Prediksi    : ${_rupiah(widget.data.nilaiPrediksi)}\n'
                            'Batas Bawah : ${_rupiah(widget.data.batasBawah)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                            ),
                          );
                        }

                        // Line 0 — omzet aktual
                        final idx = spot.spotIndex;
                        if (idx < 0 || idx >= points.length) return null;
                        final point = points[idx];
                        if (point.omzet == null) return null;

                        return LineTooltipItem(
                          '${point.label}\n${_rupiah(point.omzet!)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= points.length) {
                          return const SizedBox.shrink();
                        }
                        // show shortened label e.g. "Jan" only
                        final label = points[i].label.split(' ').first;
                        final isPred = points[i].prediksi != null;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isPred
                                  ? _colorPrediksi
                                  : const Color(0xFF6B7280),
                              fontWeight: isPred
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) => Text(
                        _shortRupiah(value),
                        style: const TextStyle(
                          fontSize: 9,
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
                // ── Confidence band (filled area) ──────────────────────────
                betweenBarsData: [
                  BetweenBarsData(
                    fromIndex: 1, // batas_bawah
                    toIndex: 2, // batas_atas
                    color: _colorBand.withOpacity(0.18),
                  ),
                ],
                lineBarsData: [
                  // ── 1. Omzet Aktual ────────────────────────────────────
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < points.length; i++)
                        if (points[i].omzet != null)
                          FlSpot(i.toDouble(), points[i].omzet!),
                    ],
                    isCurved: true,
                    color: _colorActual,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: _colorActual,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _colorActual.withOpacity(0.12),
                          _colorActual.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // ── 2. Batas Bawah (invisible line for band) ───────────
                  LineChartBarData(
                    spots: [
                      // anchor at last historis point
                      FlSpot((hist.length - 1).toDouble(), d.batasBawah),
                      // extend to prediksi point
                      FlSpot(hist.length.toDouble(), d.batasBawah),
                    ],
                    isCurved: false,
                    color: Colors.transparent,
                    barWidth: 0,
                    dotData: const FlDotData(show: false),
                  ),
                  // ── 3. Batas Atas (invisible line for band) ────────────
                  LineChartBarData(
                    spots: [
                      FlSpot((hist.length - 1).toDouble(), d.batasAtas),
                      FlSpot(hist.length.toDouble(), d.batasAtas),
                    ],
                    isCurved: false,
                    color: Colors.transparent,
                    barWidth: 0,
                    dotData: const FlDotData(show: false),
                  ),
                  // ── 4. Prediksi (dashed orange line) ──────────────────
                  LineChartBarData(
                    spots: [
                      // connect from last historis
                      FlSpot((hist.length - 1).toDouble(), hist.last.omzet),
                      // to prediksi point
                      FlSpot(hist.length.toDouble(), d.nilaiPrediksi),
                    ],
                    isCurved: true,
                    color: _colorPrediksi,
                    barWidth: 3,
                    dashArray: [8, 5],
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) {
                        if (index == 1) {
                          // Only show dot on the prediksi endpoint
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: _colorPrediksi,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 0,
                          color: Colors.transparent,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        );
                      },
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Internal model ───────────────────────────────────────────────────────────

class _ChartPoint {
  final String label;
  final double? omzet;
  final double? prediksi;
  final double? batasAtas;
  final double? batasBawah;
  const _ChartPoint({
    required this.label,
    this.omzet,
    this.prediksi,
    this.batasAtas,
    this.batasBawah,
  });
}

// ─── Legend item ──────────────────────────────────────────────────────────────

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;
  final bool isFill;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isDashed = false,
    this.isFill = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFill)
          Container(
            width: 16,
            height: 10,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              border: Border.all(color: color, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          )
        else
          CustomPaint(
            size: const Size(20, 10),
            painter: _LinePainter(color: color, dashed: isDashed),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _LinePainter({required this.color, required this.dashed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (dashed) {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, size.height / 2),
          Offset((x + 5).clamp(0, size.width), size.height / 2),
          paint,
        );
        x += 9;
      }
    } else {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.color != color || old.dashed != dashed;
}
