# Build Android APK + PWA untuk iOS — Kasir Offline

---

## BAGIAN 1 — Android Release APK

### Step 1: Buat Keystore (sekali saja, simpan baik-baik!)

Jalankan perintah ini di terminal, dari root project Flutter kamu:

```bash
keytool -genkey -v \
  -keystore android/app/kasir-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias kasir-key
```

Kamu akan diminta mengisi:

- **Keystore password** → buat password
- **Key password** → boleh sama dengan keystore password
- **First and Last Name** → nama kamu
- **Organization** → nama kampus / bebas
- **City, State, Country** → isi bebas (contoh: Cirebon, West Java, ID)

⚠️ **PENTING:** Simpan file `kasir-release.jks` ini dan jangan di-commit ke Git!
Tambahkan ke `.gitignore`:

```
android/app/*.jks
android/key.properties
```

---

### Step 2: Buat file key.properties

Buat file `android/key.properties` (lihat file terlampir).
Isi sesuai password yang kamu buat di Step 1.

---

### Step 3: Update android/app/build.gradle

Lihat file `build.gradle.patch` untuk bagian yang perlu ditambahkan.

# <------- Tinggal ini yang Belum

---

### Step 4: Build APK

```bash
# Pastikan dari root project Flutter
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# File APK ada di:
# build/outputs/flutter-apk/app-release.apk
```

Ukuran APK sekitar 15–30 MB. Kirim via WhatsApp / Google Drive ke teman.

---

### Step 5: Install di HP Android

Penerima perlu aktifkan **Install dari sumber tidak dikenal**:

- Settings → Security → Install Unknown Apps → aktifkan untuk aplikasi yang dipakai buka APK (Files, WhatsApp, dll)

---

## BAGIAN 2 — PWA untuk iOS (Add to Home Screen)

Flutter support PWA via `flutter build web`. iOS tidak bisa install APK,
tapi bisa "install" web app ke Home Screen seperti app native.

### Step 1: Enable web di Flutter

```bash
flutter config --enable-web
flutter create . --platforms web --org com.fikarmohammad  # tambah web support ke project existing
```

### Step 2: Build web

```bash
flutter build web --release --base-href "/"
```

Output ada di `build/web/` — folder ini yang di-deploy.

### Step 3: Deploy ke hosting gratis

**Opsi A — Firebase Hosting (recommended):**

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
# Public directory: build/web
# Single-page app: Yes
firebase deploy
```

Dapat URL: `https://nama-project.web.app`

**Opsi B — Netlify (paling mudah):**

1. Buka netlify.com → drag & drop folder `build/web`
2. Dapat URL instan, contoh: `https://kasir-offline.netlify.app`

**Opsi C — GitHub Pages:**

```bash
# Push build/web ke branch gh-pages
git subtree push --prefix build/web origin gh-pages
```

### Step 4: Cara "install" di iPhone (iOS PWA)

Bagikan URL ke pengguna iPhone, lalu:

1. Buka URL di **Safari** (wajib Safari, bukan Chrome)
2. Ketuk tombol **Share** (kotak dengan panah ke atas)
3. Pilih **"Add to Home Screen"**
4. Beri nama → **Add**

App akan muncul di Home Screen dengan icon seperti app native.

### Step 5: Update manifest & icon PWA

Lihat file `manifest.json` dan `index.html` patch yang terlampir
untuk ikon dan splash screen yang proper.

---

## Checklist Sebelum Submit Tugas

- [ ] APK berhasil di-build (`app-release.apk` ada)
- [ ] APK bisa di-install di HP Android
- [ ] Web app ter-deploy dan bisa dibuka di browser
- [ ] Di iPhone: bisa Add to Home Screen via Safari
- [ ] Icon app sudah benar (bukan icon Flutter default)
- [ ] Nama app di homescreen: "Kasir Offline"
