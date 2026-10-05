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

# Hasil praktikum 3
![](screenshots/p3-mode-pesawat.jpeg)
![](screenshots/p3-validasi-empty-judul.jpeg)
![](screenshots/p3-mode-pesawat-create-note.jpeg)
![](screenshots/p3-mode-pesawat-update-note.jpeg)

# Pertanyaan Praktikum 3
1. Mengapa setelah setiap mutasi perlu meng-invalidate notesProvider dan dirtyCountProvider? Apa yang terjadi jika hanya salah satu?
- Jawab: 
    Untuk memastikan bahwa state di-refresh setelah setiap mutasi. Jika hanya salah satu yang di-invalidate, maka salah satu provider tidak akan diperbarui, sehingga dapat menyebabkan state yang tidak konsisten.
2. Bagaimana cara Anda memicu state error secara sengaja untuk menguji tampilan _ErrorView?
- Jawab: 
    Misalnya override noteRepositoryProvider dengan repository yang melempar exception, mengubah nama tabel di query sementara, atau melempar exception manual di fetchNotes.
3. Mengapa aplikasi tetap berfungsi dalam mode pesawat walaupun tidak ada kode khusus untuk mode offline?
- Jawab: 
    Karena aplikasi tidak memiliki dependensi eksternal dan semua operasi dilakukan secara lokal di perangkat. Selain itu, aplikasi juga tidak menggunakan layanan berbasis cloud, sehingga tidak memerlukan koneksi internet untuk berfungsi.

# Hasil praktikum 4
![](screenshots/p4-setting-offline.jpeg)
![](screenshots/p4-dirty-sebelum.jpeg)
![](screenshots/p4-dirty-sesudah.jpeg)
![](screenshots/p4-post-cached-offline.jpeg)

# Pertanyaan Praktikum 4
1. Apa perbedaan cache-first dan network-first? Berikan satu contoh data yang lebih cocok memakai network-first.
- Jawab: 
    Perbedaan utamanya terletak pada urutan prioritas pengambilan data. 
    
    Cache-first: Data diambil dari cache lokal terlebih dahulu. Jika cache kosong atau sudah kadaluarsa (expired), maka data akan diambil dari network. Data yang diambil dari network akan disimpan ke cache untuk digunakan pada permintaan berikutnya.

    Network-first: Data diambil dari network terlebih dahulu. Jika network tidak tersedia (misalnya mode offline), maka data akan diambil dari cache lokal (jika ada). Data yang diambil dari network juga akan disimpan ke cache.

    Contoh data yang lebih cocok memakai network-first adalah data yang harus selalu paling up-to-date atau real-time, seperti: 
    - Harga saham atau cryptocurrency: Nilainya berubah sangat cepat, sehingga cache yang usang bisa menyesatkan. 
    - Status pesanan (order status): Pembeli ingin segera tahu apakah pesanannya sudah diterima atau dikirim, bukan berdasarkan data lama.
    - Skor pertandingan olahraga langsung: Data harus real-time agar akurat.
    - Pembayaran atau transaksi bank: Kesalahan informasi sedikit saja dapat berakibat fatal.
2. Jelaskan skenario kehilangan data yang dapat terjadi akibat markAllSynced(), lalu usulkan perbaikannya.
- Jawab: 
    Skenario kehilangan data yang bisa terjadi akibat markAllSynced() adalah:
    1. Pengguna membuat 10 note baru -> status dirty = true.
    2. Pengguna membuka screen SyncNotes -> memanggil sync() -> memanggil markAllSynced().
    3. markAllSynced() mengubah dirty = false untuk semua 10 note.
    4. Tiba-tiba listrik mati atau HP restart -> database ter-reset.
    5. Saat dibuka lagi, semua 10 note muncul sebagai baru lagi (karena dirty kembali true).
    6. Ini membuat data "palsu" karena aslinya sudah tersimpan di cloud.
    
    Usulan Perbaikan:
    markAllSynced() tidak seharusnya mengubah status dirty menjadi false secara langsung. Sebaiknya markAllSynced() hanya menandai bahwa data "sedang di-sync" atau memindahkan data ke tabel arsip. Atau, jika ingin tetap mengubah dirty menjadi false, harus dipastikan bahwa data tersebut sudah benar-benar aman di cloud. Jika tidak yakin, lebih baik tidak mengubah status dirty atau menggunakan mekanisme backup.
3. Mengapa diperlukan saklar forceOffline padahal sudah ada mode pesawat?
- Jawab:
     saklar forceOffline berguna untuk memanipulasi UI, memungkinkan developer menguji atau mendemonstrasikan bagaimana aplikasi berperilaku dalam kondisi offline tanpa benar-benar mengaktifkan mode pesawat.
4. Mengapa fetchAndCache() menulis cache di dalam transaksi?
- Jawab: 
    Untuk memastikan operasi penghapusan dan penyisipan bersifat atomik. Dengan demikian, jika terjadi kegagalan di tengah operasi (misalnya saat menyisipkan data baru), database akan kembali ke keadaan semula (cache lama tetap utuh) sehingga tidak ada cache setengah jadi yang tersisa.    