# Hasil praktikum
![gambar1](screenshots/p1-tema-terang.jpeg)
![gambar2](screenshots/p1-tema-gelap-pertama.jpeg)
![gambar3](screenshots/p1-tema-gelap-kedua.jpeg)

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

# Hasil praktikum 2

# Pertanyaan Praktikum 2
1. Mengapa kolom dirty bertipe INTEGER dan bukan BOOLEAN?
    - Jawab: 
    Karena Sqflite belum mendukung tipe BOOLEAN secara native. Oleh karena itu, digunakan INTEGER untuk menyimpan nilai boolean dengan representasi 0 (false) dan 1 (true).
2. Apa fungsi parameter openDb pada constructor NoteRepository?
    - Jawab: 
    Parameter openDb berfungsi untuk memberikan fleksibilitas dalam membuat instance NoteRepository. Hal ini memungkinkan kita untuk menggunakan instance database yang sama di seluruh aplikasi tanpa perlu membuat instance baru setiap kali memanggil NoteRepository. Selain itu, parameter ini juga memudahkan dalam melakukan mocking database pada saat pengujian.
3. Mengapa query memakai where: 'id = ?' dan whereArgs, bukan interpolasi string?
    - Jawab: 
    Menggunakan where: 'id = ?' dan whereArgs merupakan praktik keamanan untuk mencegah serangan SQL injection. Dengan menggunakan placeholder, nilai parameter akan di-escape secara otomatis oleh Sqflite, sehingga nilai parameter tidak akan dieksekusi sebagai bagian dari query SQL.
4. Apa yang terjadi jika Anda menambah kolom baru di onCreate tanpa menaikkan version?
    - Jawab: 
    Jika Anda menambah kolom baru di onCreate tanpa menaikkan version, maka database akan di-create ulang dengan skema baru, namun data yang sudah ada sebelumnya akan hilang karena database di-reset. Oleh karena itu, setiap kali ada perubahan pada skema database, version harus dinaikkan untuk memastikan data yang sudah ada tetap terjaga. Jika kelak menambah kolom (misalnya pinned), naikkan `version` dan tambahkan onUpgrade. Tanpa ini, perangkat yang sudah memiliki database lama tidak akan mendapatkan kolom baru.