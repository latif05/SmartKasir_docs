### **Skema Database SmartKasir**

**Tujuan:** Mendefinisikan struktur tabel, kolom, tipe data, kunci utama, dan kunci asing untuk menyimpan data aplikasi SmartKasir baik secara lokal maupun remote.

**Basis Data:**
*   **Lokal:** SQLite (untuk fungsionalitas offline di perangkat mobile)
*   **Remote:** PostgreSQL (untuk penyimpanan terpusat dan sinkronisasi)

---

### **Entitas Utama & Tabel**

Kita akan mendefinisikan tabel-tabel berikut:

1.  `categories` (Kategori Produk)
2.  `products` (Produk)
3.  `transactions` (Transaksi Penjualan)
4.  `transaction_items` (Item dalam Transaksi)
5.  `settings` (Pengaturan Aplikasi)
6.  `sync_logs` (Log Sinkronisasi - hanya untuk remote/backend jika diperlukan tracking detail)

---

#### **1. Tabel `categories`**

*   **Tujuan:** Menyimpan daftar kategori untuk mengorganisir produk.
*   **Relasi:** One-to-Many dengan `products` (satu kategori memiliki banyak produk).

| Kolom             | Tipe Data (PostgreSQL) | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :---------------- | :--------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`              | `UUID`                 | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik kategori (UUID untuk sinkronisasi) |
| `name`            | `VARCHAR(255)`         | `TEXT`             | NOT NULL                     | Nama kategori (misal: "Minuman", "Makanan", "Fashion") |
| `description`     | `TEXT`                 | `TEXT`             | NULL                         | Deskripsi kategori                     |
| `created_at`      | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`      | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |
| `is_deleted`      | `BOOLEAN`              | `INTEGER`          | NOT NULL, DEFAULT FALSE      | Status penghapusan (soft delete)       |

**Indeks:** `name`

---

#### **2. Tabel `products`**

*   **Tujuan:** Menyimpan informasi detail setiap produk yang dijual.
*   **Relasi:** Many-to-One dengan `categories` (banyak produk milik satu kategori).
*   **Relasi:** One-to-Many dengan `transaction_items` (satu produk bisa ada di banyak item transaksi).

| Kolom                 | Tipe Data (PostgreSQL) | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :-------------------- | :--------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`                  | `UUID`                 | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik produk (UUID untuk sinkronisasi) |
| `category_id`         | `UUID`                 | `TEXT`             | NOT NULL, FOREIGN KEY (categories.id) | Kunci asing ke tabel `categories`      |
| `name`                | `VARCHAR(255)`         | `TEXT`             | NOT NULL                     | Nama produk                            |
| `barcode`             | `VARCHAR(255)`         | `TEXT`             | UNIQUE (NULLable)            | Kode barcode produk (opsional, unik jika ada) |
| `purchase_price`      | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Harga beli produk                      |
| `selling_price`       | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Harga jual produk                      |
| `stock`               | `INTEGER`              | `INTEGER`          | NOT NULL, DEFAULT 0          | Jumlah stok saat ini                   |
| `unit`                | `VARCHAR(50)`          | `TEXT`             | NULL                         | Satuan produk (misal: 'pcs', 'kg', 'liter') |
| `image_url`           | `TEXT`                 | `TEXT`             | NULL                         | URL gambar produk (opsional)           |
| `created_at`          | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`          | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |
| `is_deleted`          | `BOOLEAN`              | `INTEGER`          | NOT NULL, DEFAULT FALSE      | Status penghapusan (soft delete)       |
| `last_synced_at`      | `TIMESTAMP`            | `TEXT`             | NULL                         | Waktu terakhir produk disinkronkan (untuk lokal) |
| `sync_status`         | `VARCHAR(50)`          | `TEXT`             | NULL                         | 'pending', 'synced', 'error' (untuk lokal) |

**Indeks:** `category_id`, `name`, `barcode`

---

#### **3. Tabel `transactions`**

*   **Tujuan:** Menyimpan informasi umum dari setiap transaksi penjualan.
*   **Relasi:** One-to-Many dengan `transaction_items` (satu transaksi memiliki banyak item).

| Kolom             | Tipe Data (PostgreSQL) | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :---------------- | :--------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`              | `UUID`                 | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik transaksi (UUID untuk sinkronisasi) |
| `transaction_code` | `VARCHAR(255)`         | `TEXT`             | UNIQUE                       | Kode transaksi unik yang dibuat aplikasi (misal: INV-YYYYMMDD-XXXX) |
| `transaction_date`| `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Tanggal dan waktu transaksi            |
| `total_amount`    | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Total jumlah transaksi sebelum diskon |
| `discount_amount` | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL, DEFAULT 0.00       | Jumlah diskon yang diterapkan          |
| `final_amount`    | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Total akhir yang harus dibayar setelah diskon |
| `amount_paid`     | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Jumlah uang yang dibayarkan pelanggan  |
| `change_amount`   | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Jumlah kembalian                       |
| `payment_method`  | `VARCHAR(50)`          | `TEXT`             | NOT NULL                     | Metode pembayaran (misal: 'Cash', 'Card', 'E-Wallet') |
| `status`          | `VARCHAR(50)`          | `TEXT`             | NOT NULL, DEFAULT 'completed' | Status transaksi (misal: 'completed', 'cancelled') |
| `created_at`      | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`      | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |
| `is_synced`       | `BOOLEAN`              | `INTEGER`          | NOT NULL, DEFAULT FALSE      | Status sinkronisasi ke remote (hanya untuk lokal) |

**Indeks:** `transaction_date`, `transaction_code`

---

#### **4. Tabel `transaction_items`**

*   **Tujuan:** Menyimpan detail setiap produk yang termasuk dalam suatu transaksi.
*   **Relasi:** Many-to-One dengan `transactions` (banyak item transaksi milik satu transaksi).
*   **Relasi:** Many-to-One dengan `products` (banyak item transaksi terkait dengan satu produk).

| Kolom             | Tipe Data (PostgreSQL) | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :---------------- | :--------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`              | `UUID`                 | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik item transaksi                 |
| `transaction_id`  | `UUID`                 | `TEXT`             | NOT NULL, FOREIGN KEY (transactions.id) | Kunci asing ke tabel `transactions`    |
| `product_id`      | `UUID`                 | `TEXT`             | NOT NULL, FOREIGN KEY (products.id) | Kunci asing ke tabel `products`        |
| `product_name`    | `VARCHAR(255)`         | `TEXT`             | NOT NULL                     | Nama produk saat transaksi (untuk historis) |
| `quantity`        | `INTEGER`              | `INTEGER`          | NOT NULL                     | Jumlah produk yang dibeli              |
| `price_at_sale`   | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | Harga jual produk saat transaksi (untuk historis) |
| `subtotal`        | `NUMERIC(10, 2)`       | `REAL`             | NOT NULL                     | `quantity` * `price_at_sale`           |
| `created_at`      | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`      | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |

**Indeks:** `transaction_id`, `product_id`

---

#### **5. Tabel `settings`**

*   **Tujuan:** Menyimpan pengaturan aplikasi seperti nama toko, alamat, dll.
*   **Relasi:** Tidak ada relasi langsung dengan tabel lain (self-contained).

| Kolom         | Tipe Data (PostgreSQL) | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :------------ | :--------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `key`         | `VARCHAR(255)`         | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | Kunci pengaturan (misal: 'store_name', 'store_address') |
| `value`       | `TEXT`                 | `TEXT`             | NULL                         | Nilai pengaturan                       |
| `created_at`  | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at`  | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |

---

#### **6. Tabel `users` (Opsional untuk MVP Awal, tetapi penting untuk masa depan)**

*   **Tujuan:** Menyimpan informasi pengguna yang dapat login ke aplikasi (misal: Admin, Kasir).
*   **Relasi:** Tidak ada relasi langsung di MVP awal.

| Kolom        | Tipe Data (PostgreSQL) | Tipe Data (SQLite) | Batasan                      | Deskripsi                              |
| :----------- | :--------------------- | :----------------- | :--------------------------- | :------------------------------------- |
| `id`         | `UUID`                 | `TEXT`             | PRIMARY KEY, NOT NULL, UNIQUE | ID unik pengguna                       |
| `username`   | `VARCHAR(255)`         | `TEXT`             | NOT NULL, UNIQUE             | Nama pengguna untuk login              |
| `password`   | `TEXT`                 | `TEXT`             | NOT NULL                     | Hash password pengguna                 |
| `role`       | `VARCHAR(50)`          | `TEXT`             | NOT NULL, DEFAULT 'cashier'  | Peran pengguna (misal: 'admin', 'cashier') |
| `created_at` | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan record                 |
| `updated_at` | `TIMESTAMP`            | `TEXT`             | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Waktu terakhir diupdate record         |

**Indeks:** `username`

---

#### **Perbedaan Implementasi (SQLite vs. PostgreSQL):**

*   **UUID:** SQLite tidak memiliki tipe data UUID native. Kita akan menyimpannya sebagai `TEXT` dan memastikan konsistensi format UUID.
*   **TIMESTAMP:** SQLite menyimpannya sebagai `TEXT` dalam format ISO8601 string.
*   **BOOLEAN:** SQLite menggunakan `INTEGER` (0 untuk false, 1 untuk true).
*   **DEFAULT CURRENT_TIMESTAMP:** SQLite juga mendukung ini.
*   **`is_synced`, `last_synced_at`, `sync_status`:** Kolom-kolom ini *sangat relevan* untuk database lokal (SQLite) untuk melacak status sinkronisasi item data individu. Database PostgreSQL tidak akan membutuhkan kolom ini untuk setiap record, karena dia adalah sumber kebenaran (source of truth). Namun, backend API mungkin memiliki tabel `sync_logs` sendiri untuk melacak sesi sinkronisasi yang lebih besar.

---

#### **Visualisasi Relasi (Konseptual):**

```
categories --< products --< transaction_items >-- transactions
           ^                                     ^
           |                                     |
           ----------------- Settings ------------
```
(Panah `--<` menunjukkan One-to-Many, kepala panah ke sisi "Many")

---

**Pertimbangan Penting untuk Sinkronisasi:**

*   **UUID sebagai ID Primer:** Penggunaan UUID di semua tabel adalah kunci untuk sinkronisasi data yang mulus antara lokal dan remote tanpa konflik ID.
*   **Timestamp untuk Deteksi Perubahan:** Kolom `updated_at` akan sangat penting untuk mendeteksi perubahan data yang perlu disinkronkan. Jika `updated_at` di lokal lebih baru dari di remote (atau sebaliknya), maka perlu sinkronisasi.
*   **Soft Delete:** Penggunaan `is_deleted` (soft delete) daripada penghapusan fisik akan membantu menjaga integritas data dan mempermudah sinkronisasi saat item dihapus. Item yang `is_deleted = TRUE` dapat dihapus permanen di sisi remote setelah periode waktu tertentu (data retention policy).
*   **Offline First:** Aplikasi Flutter akan menulis/membaca data ke/dari SQLite terlebih dahulu. Mekanisme sinkronisasi akan berjalan di latar belakang.
