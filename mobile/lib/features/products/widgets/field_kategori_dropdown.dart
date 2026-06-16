import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_offline/features/providers/kategori_provider.dart';
import 'package:kasir_offline/core/index.dart';
// import '../../../features/providers/product_provider.dart';

class FieldKategoriDropdown extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const FieldKategoriDropdown({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kategoriAsync = ref.watch(kategoriListProvider('produk'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        kategoriAsync.when(
          loading: () => Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ),
          error: (err, _) => GestureDetector(
            onTap: () => ref.refresh(kategoriListProvider('produk')),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade800),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.red.shade400, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Gagal memuat. Ketuk untuk retry',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          data: (list) => DropdownButtonFormField<String>(
            value: selectedId,
            onChanged: onChanged,
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: errorText != null
                      ? Colors.red.shade400
                      : Colors.white12,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryLight),
              ),
              hintText: 'Pilih kategori',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            ),
            items: list
                .map(
                  (k) => DropdownMenuItem<String>(
                    value: k.id,
                    child: Text(k.nama),
                  ),
                )
                .toList(),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(color: Colors.red.shade400, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
