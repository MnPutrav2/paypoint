import 'package:flutter/material.dart';
// import 'package:kasir_offline/features/splash_screen.dart';
import 'package:kasir_offline/features/navigation/app_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kasir_offline/app.dart';

// void main() {
//   runApp(const ProviderScope(child: KasirApp(navigationShell: null,)));
// }

void main() async {
  // ← tambah async
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paypoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: AppNavigation.router,
    );
  }
}
