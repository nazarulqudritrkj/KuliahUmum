# 🎓 SIM-KU — Sistem Informasi Mahasiswa Kuliah Umum

Platform website modern dan responsif untuk mengelola siklus pelaksanaan kuliah umum bagi mahasiswa dan administrator kampus, mulai dari registrasi akun, reservasi tiket QR, presensi digital, kuesioner evaluasi, hingga penerbitan E-Sertifikat resmi terverifikasi secara otomatis.

---

## 🌐 Live Demo & Deployment
- **GitHub Pages:** [https://nazarulqudritrkj.github.io/KuliahUmum/](https://nazarulqudritrkj.github.io/KuliahUmum/)
- **Backend & Cloud Database:** [Supabase PostgreSQL](https://supabase.com/)

---

## 🎨 Karakteristik Desain & Estetika Visual
- **Palet Warna:** Ungu Terang (*Electric Violet* `#7C3AED`) & Kuning Matahari (*Sun Yellow* `#FBBF24`).
- **Sidebar & Shell:** Midnight Purple (`#1E1B4B`) dengan tata letak profesional disukai psikologi mahasiswa.
- **Tipografi:** Google Fonts *Plus Jakarta Sans*.
- **Responsif:** Adaptif untuk Layar Ponsel (Mobile), Tablet, Desktop, dan Windows.

---

## ✨ Fitur Utama
1. **🔐 Autentikasi Multi-Role:** Akses terpisah untuk Mahasiswa & Administrator.
2. **📝 Registrasi Akademik:** Validasi NIM, Fakultas, Program Studi, dan Angkatan.
3. **📊 Dashboard Mahasiswa:** Ringkasan keikutsertaan, kuliah umum terdekat, dan kuota live.
4. **⚙️ Panel Admin:** Monitoring pendaftar, manajemen kuota, dan publikasi kuliah umum baru.
5. **📚 Katalog Kuliah Umum:** Pencarian instan dan filter kategori & status keterisian.
6. **🎫 Tiket QR Digital:** Kode tiket unik dan QR Code otomatis untuk setiap pendaftar.
7. **📷 Pemindai Presensi (Scanner):** Validasi kehadiran check-in instan dan pencatatan waktu realtime.
8. **⭐ Evaluasi Kuesioner:** Rating materi, narasumber, dan fasilitas untuk membuka akses sertifikat.
9. **🏆 E-Sertifikat Resmi:** Desain kartu sertifikat elegan dengan kode verifikasi publik & unduh PDF.

---

## 🛠️ Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (Channel Stable)
- **Backend / DB:** [Supabase](https://supabase.com/) (PostgreSQL, Auth, RLS)
- **State Management:** ChangeNotifier (`AppStateService`)
- **Hosting:** GitHub Pages via GitHub Actions CI/CD

---

## 🚀 Menjalankan Secara Lokal

```bash
# Clone repository
git clone https://github.com/nazarulqudritrkj/KuliahUmum.git
cd KuliahUmum

# Install dependencies
flutter pub get

# Jalankan di Chrome
flutter run -d chrome

# Jalankan di Windows Desktop
flutter run -d windows
```

---

## 🔑 Akun Demo Cepat
- **Mahasiswa:** NIM: `220401050` | Sandi: `password123`
- **Administrator:** ID: `ADM-9901` | Sandi: `password123`
