import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir_offline/core/index.dart';
import 'package:kasir_offline/core/utils/jwt_helper.dart';
import 'package:kasir_offline/data/repositories/auth_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // bool _notifEnabled = true;
  // bool _darkMode = false;

  // ===== DATA KASIR =====
  Map<String, String> _kasirInfo = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final payload = await JwtHelper.getPayload();
    if (!mounted || payload == null) return;

    setState(() {
      _kasirInfo = {
        'nama': payload['name']?.toString() ?? '-',
        'username': payload['username']?.toString() ?? '-',
        'email': payload['email']?.toString() ?? '-',
        'no_hp': payload['no_hp']?.toString() ?? '-',
        'id': payload['id']?.toString() ?? '-',
        'role': payload['role']?.toString() ?? '-',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),

              child: Column(
                children: [
                  // _buildKasirInfo(),
                  // const SizedBox(height: 14),
                  // _buildPinSection(),
                  // const SizedBox(height: 14),
                  // _buildMenuToko(),
                  // const SizedBox(height: 14),
                  // _buildMenuAplikasi(),
                  const SizedBox(height: 14),
                  _buildLogout(),
                  const SizedBox(height: 16),
                  Text(
                    'KAVI Kasir v1.0.0',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== HERO =====
  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // BACKGROUND CIRCLES
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  // TOP ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profil',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditProfileDialog(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Center(
                            child: Text('✏️', style: TextStyle(fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // AVATAR + INFO
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('👤', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '✓',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _kasirInfo['nama'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '🏪 ${_kasirInfo['role']}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  //   // STATS ROW
                  //   Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.white.withOpacity(0.1),
                  //       borderRadius: BorderRadius.circular(16),
                  //       border: Border.all(color: Colors.white.withOpacity(0.15)),
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         _buildStat('128', 'Transaksi'),
                  //         _buildStatDivider(),
                  //         _buildStat('Rp 12,4Jt', 'Total Omzet'),
                  //         _buildStatDivider(),
                  //         _buildStat('30 hr', 'Bergabung'),
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String val, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              val,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.15),
    );
  }

  // ===== KASIR INFO =====
  Widget _buildKasirInfo() {
    return Transform.translate(
      // ← ganti Container margin negatif
      offset: const Offset(0, -20), // ← efek sama dengan margin top: -20
      child: Container(
        // hapus margin di sini
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        ),
        child: Column(
          // ... isi tetap sama
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }

  // ===== PIN SECTION =====

  // ===== MENU TOKO =====
  // Widget _buildMenuToko() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'PENGATURAN TOKO',
  //         style: AppTextStyles.caption.copyWith(
  //           fontSize: 11,
  //           fontWeight: FontWeight.w700,
  //           letterSpacing: 0.5,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         decoration: BoxDecoration(
  //           color: AppColors.backgroundCard,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.05),
  //               blurRadius: 10,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           children: [
  //             _buildMenuItem(
  //               icon: '🏪',
  //               iconBg: AppColors.primary.withOpacity(0.1),
  //               title: 'Informasi Toko',
  //               desc: 'Nama, alamat, logo toko',
  //               onTap: () {},
  //             ),
  //             _buildDividerLine(),
  //             _buildMenuItem(
  //               icon: '🧾',
  //               iconBg: const Color(0xFFFEF3C7),
  //               title: 'Format Struk',
  //               desc: 'Atur tampilan struk pembayaran',
  //               onTap: () {},
  //             ),
  //             _buildDividerLine(),
  //             _buildMenuItem(
  //               icon: '💰',
  //               iconBg: const Color(0xFFDCFCE7),
  //               title: 'Metode Pembayaran',
  //               desc: 'Cash, QRIS, Transfer',
  //               onTap: () {},
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // // ===== MENU APLIKASI =====
  // Widget _buildMenuAplikasi() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'APLIKASI',
  //         style: AppTextStyles.caption.copyWith(
  //           fontSize: 11,
  //           fontWeight: FontWeight.w700,
  //           letterSpacing: 0.5,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         decoration: BoxDecoration(
  //           color: AppColors.backgroundCard,
  //           borderRadius: BorderRadius.circular(16),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.05),
  //               blurRadius: 10,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           children: [
  //             _buildMenuItemToggle(
  //               icon: '🔔',
  //               iconBg: const Color(0xFFF3E8FF),
  //               title: 'Notifikasi',
  //               desc: 'Pengingat stok menipis',
  //               value: _notifEnabled,
  //               onChanged: (val) => setState(() => _notifEnabled = val),
  //             ),
  //             _buildDividerLine(),
  //             _buildMenuItemToggle(
  //               icon: '🌙',
  //               iconBg: const Color(0xFFF1F5F9),
  //               title: 'Mode Gelap',
  //               desc: 'Tampilan tema gelap',
  //               value: _darkMode,
  //               onChanged: (val) => setState(() => _darkMode = val),
  //             ),
  //             _buildDividerLine(),
  //             _buildMenuItem(
  //               icon: '📊',
  //               iconBg: AppColors.primary.withOpacity(0.1),
  //               title: 'Ekspor Laporan',
  //               desc: 'Download PDF atau Excel',
  //               onTap: () {},
  //             ),
  //             _buildDividerLine(),
  //             _buildMenuItem(
  //               icon: '❓',
  //               iconBg: const Color(0xFFF1F5F9),
  //               title: 'Bantuan',
  //               desc: 'Panduan penggunaan aplikasi',
  //               onTap: () {},
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildMenuItem({
  //   required String icon,
  //   required Color iconBg,
  //   required String title,
  //   required String desc,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
  //       color: Colors.transparent,
  //       child: Row(
  //         children: [
  //           Container(
  //             width: 36,
  //             height: 36,
  //             decoration: BoxDecoration(
  //               color: iconBg,
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Center(
  //               child: Text(icon, style: const TextStyle(fontSize: 16)),
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(title, style: AppTextStyles.label),
  //                 Text(desc, style: AppTextStyles.caption),
  //               ],
  //             ),
  //           ),
  //           Icon(
  //             Icons.chevron_right_rounded,
  //             color: AppColors.textSecondary,
  //             size: 18,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildMenuItemToggle({
  //   required String icon,
  //   required Color iconBg,
  //   required String title,
  //   required String desc,
  //   required bool value,
  //   required ValueChanged<bool> onChanged,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 36,
  //           height: 36,
  //           decoration: BoxDecoration(
  //             color: iconBg,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: Center(
  //             child: Text(icon, style: const TextStyle(fontSize: 16)),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(title, style: AppTextStyles.label),
  //               Text(desc, style: AppTextStyles.caption),
  //             ],
  //           ),
  //         ),
  //         Switch(
  //           value: value,
  //           onChanged: onChanged,
  //           activeColor: AppColors.primary,
  //           activeTrackColor: AppColors.primary.withOpacity(0.3),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDividerLine() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 16,
      endIndent: 16,
    );
  }

  // ===== LOGOUT =====
  Widget _buildLogout() {
    return GestureDetector(
      onTap: () => _showLogoutDialog(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFEE2E2)),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🚪', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar dari Akun',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== PIN DIALOG =====
  void _showEditProfileDialog() {
    final namaCtrl = TextEditingController(text: _kasirInfo['nama']);
    final usernameCtrl = TextEditingController(text: _kasirInfo['username']);
    final emailCtrl = TextEditingController(text: _kasirInfo['email']);
    final noHpCtrl = TextEditingController(text: _kasirInfo['no_hp']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profil', style: AppTextStyles.heading3),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _editField('Nama', namaCtrl, Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _editField(
                'Username',
                usernameCtrl,
                Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 12),
              _editField(
                'Email',
                emailCtrl,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _editField(
                'No HP',
                noHpCtrl,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Tombol simpan
              GestureDetector(
                onTap: () {
                  // TODO: kirim ke API saat backend siap
                  setState(() {
                    _kasirInfo = {
                      ..._kasirInfo,
                      'nama': namaCtrl.text,
                      'username': usernameCtrl.text,
                      'email': emailCtrl.text,
                      'no_hp': noHpCtrl.text,
                    };
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✅ Profil berhasil diperbarui'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Simpan Perubahan',
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

  Widget _editField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== LOGOUT DIALOG =====
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚪', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 14),
              Text('Keluar dari Akun?', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                'Kamu akan keluar dari aplikasi KAVI.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text('Batal', style: AppTextStyles.label),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleLogout(ctx), // ← ganti ini
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Keluar',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ← tambah fungsi ini
  Future<void> _handleLogout(BuildContext ctx) async {
    Navigator.of(ctx).pop(); // tutup dialog dulu

    try {
      // Hapus semua token dari storage
      final repo = AuthRepository();
      await repo.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      // Redirect ke login meski logout gagal — sama seperti Next.js
      if (mounted) context.go('/login');
    }
  }

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
