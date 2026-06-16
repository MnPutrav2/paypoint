import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir_offline/features/navigation/app_navigation.dart';

class KasirApp extends StatefulWidget {
  const KasirApp({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<KasirApp> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<KasirApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paypoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: AppNavigation.router,
    );
  }
}

//Ketentuan:

// 1. Buat List yang berisi 2 produk
//    Setiap produk punya:
//    - namaProduk  : String
//    - harga       : int
//    - stok        : int
//    - kategori    : String
//    - isAvailable : bool (true kalau stok > 0)
//    Pilih tipe List yang tepat!
//    List ini tidak bisa diganti ke list lain!

// 2. Buat fungsi cekStok()
//    - menerima parameter produk (Map<String, dynamic>)
//    - return true kalau stok > 0
//    - return false kalau stok = 0

// 3. Buat fungsi formatHarga()
//    - menerima parameter harga (int)
//    - return String dengan format 'Rp 15.000.000'
//    - hint: pakai string interpolation ${}

// 4. Buat variabel totalStok
//    - hitung jumlah stok dari SEMUA produk digabung
//    - tidak bisa diganti setelah dihitung
//    - hint: pakai .fold()

// 5. Buat variabel produkTersedia
//    - ambil produk yang stoknya > 0 saja
//    - tidak bisa diganti setelah diambil
//    - hint: pakai .where() dan .toList()
