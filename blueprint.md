# Blueprint: Aplikasi Flutter

## Ikhtisar

Tujuan dari proyek ini adalah untuk membangun aplikasi Flutter yang canggih dengan estetika desain yang premium, pengalaman pengguna yang superior, dan **performa yang dioptimalkan secara fundamental**.

## Fitur & Desain

*   **Performa Rendering Tinggi:** Dioptimalkan secara agresif menggunakan `const` untuk memastikan *rebuild* UI yang minimal.
*   **Desain "Soft UI" (Neumorphic):** Antarmuka yang bersih dan modern jika relevan.
*   **Interaksi Intuitif & Gestur:** Seperti Tap-to-Copy, Swipe-to-Delete, dll jika diperlukan.
*   **Ukuran Aplikasi yang Dioptimalkan:**
    *   Mengaktifkan `minifyEnabled` dan `shrinkResources` untuk menghapus kode dan resource yang tidak terpakai.
    *   Membangun aplikasi sebagai Android App Bundle (AAB) untuk pengiriman yang dioptimalkan melalui Google Play.

## CI/CD (Continuous Integration/Continuous Deployment)

*   **Otomatisasi Build dengan GitHub Actions**:
    *   Mengonfigurasi alur kerja CI/CD (`.github/workflows/build.yml`) untuk secara otomatis membuat Android App Bundle (AAB) setiap kali ada perubahan pada `main branch`.
    *   Alur kerja ini mencakup penyiapan lingkungan Flutter, instalasi dependensi, dan pembuatan AAB dalam mode rilis (`--release`).
    *   Hasil build (`app-release.aab`) diunggah sebagai *artifact* untuk kemudahan akses dan deployment.

## Langkah Saat Ini

*   **Implementasi CI/CD:** Menambahkan alur kerja GitHub Actions untuk otomatisasi build AAB yang dioptimalkan.
