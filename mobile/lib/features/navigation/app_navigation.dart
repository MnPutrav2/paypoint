import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';
// import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/features/auth/login_page.dart';
import 'package:kasir_offline/features/auth/signup_page.dart';
import 'package:kasir_offline/features/cart/cart_page.dart';
import 'package:kasir_offline/features/cashier/cashier_page.dart';
import 'package:kasir_offline/features/cashier/stock_page.dart';
import 'package:kasir_offline/features/navigation/app_shell.dart';
import 'package:kasir_offline/features/payment/payment_detail_page.dart';
import 'package:kasir_offline/features/payment/payment_page.dart';
import 'package:kasir_offline/features/products/product_detail_page.dart';
import 'package:kasir_offline/features/profile/profile_page.dart';
import 'package:kasir_offline/features/reports/report_page.dart';
import 'package:kasir_offline/features/riwayat/riwayat_page.dart';
import 'package:kasir_offline/features/splash_screen.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/data/models/katalog_model.dart';

class AppNavigation {
  AppNavigation._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // ===== HALAMAN TANPA BOTTOM NAV =====
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final item = state.extra as KatalogItem;
          return ProductDetailPage(item: item);
        },
      ),

      GoRoute(
        path: '/payment-detail',
        builder: (context, state) {
          final order = state.extra as Map<String, dynamic>;
          return PaymentDetailPage(order: order);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CartPage(
            items: extra['items'] as Map<String, KatalogItem>,
            qty: extra['qty'] as Map<String, int>,
          );
        },
      ),

      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const PaymentPage(
              namaPembeli: 'Pembeli',
              items: [],
              totalHarga: 0,
              metode: 'tunai',
            );
          }
          return PaymentPage(
            namaPembeli: extra['namaPembeli'] as String,
            items: List<Map<String, dynamic>>.from(extra['items'] as List),
            totalHarga: extra['totalHarga'] as int,
            metode: extra['metode'] as String,
          );
        },
      ),

      // ===== HALAMAN DENGAN BOTTOM NAV =====
      // ShellRoute = semua halaman di dalam pakai 1 Scaffold
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child); // ← wrapper dengan bottom nav
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const CashierPage(),
          ),
          GoRoute(
            path: '/stock_page',
            builder: (context, state) => const StockPage(),
          ),
          GoRoute(
            path: '/report',
            builder: (context, state) => const ReportPage(),
          ),
          GoRoute(
            path: '/riwayat',
            builder: (context, state) => const RiwayatPage(),
          ),

          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // Di luar ShellRoute
        ],
      ),
    ],
  );
}
