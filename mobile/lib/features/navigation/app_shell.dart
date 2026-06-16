import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir_offline/core/index.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _getIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/riwayat')) return 0;
    if (location.startsWith('/home')) return 2; // ← tambah ini
    if (location.startsWith('/report')) return 1;
    if (location.startsWith('/stock_page')) return 3;
    if (location.startsWith('/profile')) return 4; // ← 2 jadi 3
    // ← 2 jadi 3
    return 2; // default home
  }

  @override
  Widget build(BuildContext context) {
    final index = _getIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        selectedIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/riwayat'); // ← tambah
              break;
            case 1:
              context.go('/report');
              break;
            case 2:
              context.go('/home');
              break;
            case 3:
              context.go('/stock_page');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
      // ← HAPUS floatingActionButton
      // ← HAPUS floatingActionButtonLocation
    );
  }
}
