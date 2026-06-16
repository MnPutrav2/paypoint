import 'package:intl/intl.dart';

// "Rabu, 5 Juni 2025 13.25 WIB"
String waktuEnak(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("EEEE, d MMMM yyyy HH.mm", "id_ID").format(dt) + " WIB";
}

// "Rabu, 5 Juni 2025"
String hariTanggalIndo(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("EEEE, d MMMM yyyy", "id_ID").format(dt);
}

// "5 Juni 2025"
String tanggalIndo(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("d MMMM yyyy", "id_ID").format(dt);
}

// "Rabu"
String hariIndo(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("EEEE", "id_ID").format(dt);
}

// "13.25 WIB"
String jamIndo(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("HH.mm", "id_ID").format(dt) + " WIB";
}

// "Juni 2025"
String bulanTahunIndo(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("MMMM yyyy", "id_ID").format(dt);
}

// "2025-06-05 13:25:00" — untuk SQL/BE
String tanggalJamSQL(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("yyyy-MM-dd HH:mm:ss").format(dt);
}

// "2025-06-05" — untuk input date
String formatDateToInput(DateTime? tanggal) {
  final dt = tanggal ?? DateTime.now();
  return DateFormat("yyyy-MM-dd").format(dt);
}

// "00:13:25" — untuk durasi dalam detik
String formatWaktu(int detik) {
  final jam = detik ~/ 3600;
  final menit = (detik % 3600) ~/ 60;
  final sisa = detik % 60;
  return "${jam.toString().padLeft(2, '0')}:"
      "${menit.toString().padLeft(2, '0')}:"
      "${sisa.toString().padLeft(2, '0')}";
}

// Parse String dari BE lalu format — untuk data dari database
String parseAndFormat(String raw) {
  try {
    final normalized = raw.replaceAll(' ', 'T');
    final dt = DateTime.parse(normalized).toLocal();
    return waktuEnak(dt);
  } catch (_) {
    return raw;
  }
}
