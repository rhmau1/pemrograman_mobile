# Pertanyaan Praktikum 1

1. Mengapa SharedPreferences.getInstance() tidak boleh dipanggil di dalam method build() widget?
    - Jawab: 
    Karena SharedPreferences.getInstance() adalah operasi asynchronous yang membutuhkan waktu untuk mengakses memori perangkat. Jika dipanggil di dalam method build() widget, maka setiap kali widget di-rebuild, operasi ini akan dipanggil berulang kali. Hal ini dapat menyebabkan penurunan performa pada aplikasi karena operasi akses disk yang berlebihan.

2. Jelaskan alur data dari saat switch ditekan sampai nilai tersimpan di disk dan tema berubah.
    - Jawab:
    1. Saat switch ditekan, method toggle() pada DarkModeNotifier dipanggil.
    2. Nilai isDark dibalik (dari true menjadi false atau sebaliknya).
    3. State diupdate dengan nilai baru menggunakan AsyncData(next).
    4. Riverpod memicu rebuild pada widget yang menggunakan provider ini, sehingga UI langsung berubah tanpa menunggu penyimpanan selesai.
    5. Secara bersamaan, ref.read(prefsRepositoryProvider).setDarkMode(next) dipanggil untuk menyimpan nilai ke SharedPreferences di latar belakang.
    6. Jika operasi penyimpanan berhasil, nilai tetap tersimpan. Jika gagal, state akan dikembalikan ke nilai sebelumnya.

3. Apa kelebihan dan risiko pendekatan optimistic update pada toggle()? 
    - Jawab:
        
        Kelebihan:
        - User experience yang lebih baik karena UI langsung berubah tanpa menunggu operasi penyimpanan selesai.
        - Pengurangan delay karena UI tidak perlu menunggu respons dari disk.

        Risiko:
        - Jika operasi penyimpanan gagal, UI akan menampilkan nilai yang salah sampai state dikembalikan ke nilai sebelumnya.   