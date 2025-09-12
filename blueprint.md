# Blueprint: Aplikasi Kalkulator Flutter

## Ikhtisar

Tujuan proyek ini adalah untuk membuat aplikasi kalkulator yang fungsional penuh dan menarik secara visual menggunakan Flutter. Aplikasi ini akan meniru desain yang modern, bersih, dan intuitif yang disediakan dalam gambar, termasuk mode tema terang dan gelap, serta tata letak yang responsif yang beradaptasi dengan berbagai ukuran layar.

## Fitur & Desain yang Diimplementasikan

### Versi 1.0: UI dan Fungsionalitas Kalkulator Awal

*   **Struktur Aplikasi Inti:**
    *   Menggunakan `Scaffold` untuk struktur layar utama.
    *   Mengimplementasikan `AppBar` kustom untuk menampung judul dan tombol aksi.
    *   Struktur bodi dipisahkan menjadi dua bagian utama: area tampilan dan keypad numerik.

*   **Manajemen Tema (Terang/Gelap):**
    *   Mengintegrasikan `provider` dan `ChangeNotifier` (`ThemeProvider`) untuk memungkinkan peralihan tema secara dinamis.
    *   Mendefinisikan `ThemeData` terpisah untuk mode terang dan gelap.
    *   **Palet Warna:** Menggunakan `ColorScheme.fromSeed` dengan warna dasar hijau-kebiruan (teal) untuk menghasilkan skema warna yang harmonis.
        *   **Mode Terang:** Latar belakang putih, teks hitam, aksen hijau-kebiruan.
        *   **Mode Gelap:** Latar belakang abu-abu gelap, teks putih, aksen hijau-kebiruan dan putih.
    *   Menambahkan ikon di `AppBar` untuk beralih antara tema terang, gelap, dan sistem.

*   **Area Tampilan:**
    *   Menampilkan ekspresi perhitungan dan hasil secara terpisah.
    *   Menggunakan paket `auto_size_text` untuk memastikan teks pas dengan rapi di dalam area tampilan tanpa meluap, menyesuaikan ukuran font secara dinamis.
    *   Tipografi yang jelas dan mudah dibaca menggunakan paket `google_fonts`.

*   **Keypad Tombol:**
    *   Tata letak berbasis `GridView` atau `Column/Row` untuk memastikan perataan dan penspasian yang konsisten.
    *   Gaya tombol yang berbeda untuk membedakan secara visual antara angka, operator, dan fungsi lainnya.
        *   **Tombol Operator** (÷, ×, −, +, =): Bentuk lingkaran dengan warna aksen.
        *   **Tombol Fungsi** (AC, ⌫, %): Warna lebih terang/gelap dari latar belakang untuk penekanan.
        *   **Tombol Angka:** Gaya standar dengan warna netral.
    *   Tata letak yang responsif yang menyesuaikan ukuran tombol dan penspasian berdasarkan lebar dan tinggi layar.

*   **Logika & Manajemen Status:**
    *   Menggunakan `ChangeNotifier` (`CalculatorProvider`) untuk mengelola status kalkulator (ekspresi input, hasil).
    *   Mengintegrasikan paket `math_expressions` untuk mengevaluasi ekspresi matematika dengan aman dan efisien.
    *   Logika diimplementasikan untuk menangani:
        *   Penambahan digit dan operator.
        *   Menghapus semua (`AC`).
        *   Menghapus satu karakter (`⌫`).
        *   Perhitungan persentase.
        *   Evaluasi ekspresi saat tombol `=` ditekan.
        *   Penanganan dasar untuk kesalahan input.

## Rencana Implementasi Saat Ini

1.  **Struktur Proyek:**
    *   Buat file `lib/main.dart` untuk menampung UI inti dan logika.
    *   Gunakan `ChangeNotifierProvider` di `main()` untuk menyediakan `ThemeProvider` dan `CalculatorProvider` ke pohon widget.

2.  **Membangun UI:**
    *   Implementasikan `CalculatorScreen` sebagai `StatelessWidget`.
    *   Bangun `AppBar` dengan tombol `IconButton` untuk menu dan peralihan tema.
    *   Buat widget `_buildDisplay` untuk menampilkan ekspresi dan hasil.
    *   Buat widget `_buildButtonPad` untuk menyusun tombol-tombol kalkulator.
    *   Desain widget `CalculatorButton` kustom untuk mengurangi duplikasi kode dan memudahkan penataan gaya.

3.  **Mengimplementasikan Logika:**
    *   Kembangkan `CalculatorProvider` dengan metode untuk `buttonPressed`.
    *   Hubungkan `onPressed` dari setiap `CalculatorButton` untuk memanggil metode yang sesuai di `CalculatorProvider`.

4.  **Menyempurnakan & Menguji:**
    *   Pastikan tata letak responsif di berbagai perangkat.
    *   Verifikasi bahwa logika perhitungan akurat.
    *   Pastikan peralihan tema berjalan lancar dan semua elemen UI diperbarui dengan benar.
    *   Jalankan `dart format .` untuk menjaga kebersihan kode.
