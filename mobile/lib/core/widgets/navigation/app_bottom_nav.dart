import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir_offline/core/constants/index.dart';

class AppBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  final List<_NavTab> _tabs = const [
    _NavTab(
      icon: Icons.history_rounded,
      label: 'Transaksi',
      index: 0,
      route: '/riwayat',
    ),
    _NavTab(
      icon: Icons.receipt_long_rounded,
      label: 'Laporan',
      index: 1,
      route: '/report',
    ),
    _NavTab(icon: Icons.home_rounded, label: 'Home', index: 2, route: '/home'),
    _NavTab(
      icon: Icons.inventory_2_rounded,
      label: 'Stok',
      index: 3,
      route: '/stock_page',
    ),
    _NavTab(
      icon: Icons.person_rounded,
      label: 'Profil',
      index: 4,
      route: '/profile', // ← tambah ini
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.primary,
      child: SizedBox(
        height: 25,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // TABS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab(context, _tabs[0]),
                _buildTab(context, _tabs[1]),
                _buildTab(context, _tabs[2]),
                _buildTab(context, _tabs[3]),
                _buildTab(context, _tabs[4]),
              ],
            ),

            // SLIDING CIRCLE
            ..._buildActiveCircle(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActiveCircle(BuildContext context) {
    final activeTabIndex = _tabs.indexWhere(
      (t) => t.index == widget.selectedIndex,
    );

    if (activeTabIndex == -1) return [];

    final screenWidth = MediaQuery.of(context).size.width;
    final positions = _getTabPositions(screenWidth);

    return [
      AnimatedPositioned(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        left: positions[activeTabIndex] - 32,
        top: -14,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _tabs[activeTabIndex].icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _tabs[activeTabIndex].label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<double> _getTabPositions(double screenWidth) {
    final sectionWidth = screenWidth / 5;

    return [
      sectionWidth * 0.5,
      sectionWidth * 1.5,
      sectionWidth * 2.5,
      sectionWidth * 3.3,
      sectionWidth * 4.2,
    ];
  }

  Widget _buildTab(BuildContext context, _NavTab tab) {
    final bool isActive = widget.selectedIndex == tab.index;

    return GestureDetector(
      onTap: () {
        widget.onTap(tab.index);
        if (tab.route != null) context.go(tab.route!);
      },
      child: SizedBox(
        width: 64,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              color: isActive ? Colors.transparent : Colors.white60,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                color: isActive ? Colors.transparent : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// helper class untuk data tab
class _NavTab {
  final IconData icon;
  final String label;
  final int index;
  final String? route;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.index,
    required this.route,
  });
}

class AppFabHome extends StatelessWidget {
  final VoidCallback onTap;

  const AppFabHome({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
