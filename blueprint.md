# Blueprint: Aplikasi Flutter

## Ikhtisar

Tujuan dari proyek ini adalah untuk membangun aplikasi Flutter yang canggih dengan estetika desain yang premium, pengalaman pengguna yang superior, dan **performa yang dioptimalkan secara fundamental**.

## Fitur & Desain

*   **Performa Rendering Tinggi:** Dioptimalkan secara agresif menggunakan `const` untuk memastikan *rebuild* UI yang minimal.
*   **Desain "Soft UI" (Neumorphic):** Antarmuka yang bersih dan modern jika relevan.
*   **Interaksi Intuitif & Gestur:** Seperti Tap-to-Copy, Swipe-to-Delete, dll jika diperlukan.
*   **Ukuran Aplikasi yang Dioptimalkan:**
    *   Mengaktifkan `isMinifyEnabled` dan `isShrinkResources` untuk menghapus kode dan resource yang tidak terpakai.
    *   Menghasilkan build yang dioptimalkan untuk berbagai arsitektur CPU.

## CI/CD (Continuous Integration/Continuous Deployment)

*   **Otomatisasi Build dengan GitHub Actions**:
    *   Mengonfigurasi alur kerja CI/CD (`.github/workflows/build.yml`) untuk secara otomatis membuat APK terpisah (split APKs) untuk setiap arsitektur CPU setiap kali ada perubahan pada `main branch`.
    *   Alur kerja ini mencakup penyiapan lingkungan Flutter, instalasi dependensi, dan pembuatan APK dalam mode rilis menggunakan `flutter build apk --release --split-per-abi`.
    *   Semua hasil build APK diunggah sebagai satu *artifact* (`release-apks.zip`) untuk kemudahan akses dan distribusi manual.

## Langkah Saat Ini

*   **Modifikasi CI/CD:** Mengubah alur kerja GitHub Actions dari pembuatan App Bundle (AAB) menjadi pembuatan APK terpisah per arsitektur (`split-per-abi`).
