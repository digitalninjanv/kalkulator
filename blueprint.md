# Blueprint: Aplikasi Kalkulator Modern

## Ikhtisar

Tujuan dari proyek ini adalah untuk membangun aplikasi kalkulator canggih dengan estetika desain yang premium, pengalaman pengguna yang superior, dan **performa yang dioptimalkan secara fundamental**.

## Fitur & Desain

*   **Kalkulasi Asinkron via Isolate:** Proses perhitungan dieksekusi di *background thread* untuk menjamin antarmuka pengguna (UI) tetap 100% responsif, lancar, dan bebas kendala, bahkan saat memproses ekspresi yang sangat kompleks.
*   **Performa Rendering Tinggi:** Dioptimalkan secara agresif menggunakan `const` untuk memastikan *rebuild* UI yang minimal.
*   **Desain "Soft UI" (Neumorphic):** Antarmuka yang bersih dan modern.
*   **Interaksi Intuitif & Gestur:** Tap-to-Copy, Swipe-to-Delete, dan Long-Press Reset.
*   **Riwayat via BottomSheet:** Akses riwayat perhitungan yang modern dan mudah.
*   **Pemformatan Angka Cerdas & Penanganan Error Informatif.**

## Langkah Saat Ini

*   **Implementasi Kalkulasi di Background Thread:** Merombak logika evaluasi ekspresi untuk dijalankan secara asinkron menggunakan `compute` (Isolate), memisahkan pekerjaan berat dari UI thread untuk mencapai performa dan stabilitas maksimum.
