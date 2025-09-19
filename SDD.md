**SOFTWARE DESIGN DOCUMENT (SDD)**
**Nama Produk:** SmartKasir
**Versi:** 1.0 (MVP)
**Tanggal:** 27 Mei 2024
**Penulis:** Abdul Latif, Bima Agung F.

---

### **1. Pendahuluan**

Dokumen Software Design Document (SDD) ini menyediakan detail desain teknis untuk aplikasi SmartKasir versi 1.0 (MVP), berdasarkan persyaratan yang telah didefinisikan dalam SRS. Tujuannya adalah untuk memandu tim pengembangan dalam implementasi aplikasi, memastikan bahwa sistem dibangun dengan cara yang konsisten, efisien, terukur, dan mudah dipelihara.

**1.1. Tujuan**
*   Mendetailkan arsitektur sistem SmartKasir.
*   Menjelaskan desain komponen utama (Frontend, Backend, Database).
*   Memandu implementasi setiap modul dan fitur.
*   Memfasilitasi komunikasi antar tim pengembang (Flutter & Node.js).

**1.2. Referensi Dokumen**
*   Product Requirements Document (PRD) - SmartKasir v1.0
*   Software Requirements Specification (SRS) - SmartKasir v1.0
*   Skema Database - SmartKasir v1.0

### **2. Arsitektur Sistem**

SmartKasir akan mengadopsi arsitektur tiga lapis (Three-Tier Architecture) dengan penekanan pada **Clean Architecture** di sisi aplikasi mobile (Flutter) dan modularitas di sisi backend (Node.js).

**2.1. Gambaran Umum Arsitektur**
*   **Presentation Layer (Flutter):** Aplikasi mobile yang berinteraksi langsung dengan pengguna. Bertanggung jawab untuk UI/UX.
*   **Application Layer (Backend Node.js):** RESTful API yang menyediakan layanan untuk aplikasi mobile, mengelola logika bisnis, dan berinteraksi dengan database terpusat.
*   **Data Layer (PostgreSQL & SQLite):**
    *   **Remote Database:** PostgreSQL, sebagai sumber kebenaran (Source of Truth) data terpusat.
    *   **Local Database:** SQLite, sebagai penyimpanan data offline di perangkat mobile.

**2.2. Arsitektur Frontend (Flutter - Clean Architecture)**

Desain frontend akan mengikuti prinsip Clean Architecture untuk modularitas, testability, dan maintainability.

*   **2.2.1. Domain Layer:**
    *   **Entities:** Merepresentasikan objek bisnis inti (misal: `Product`, `Transaction`, `Category`, `Setting`). Murni objek Dart, tidak tergantung pada framework atau database.
    *   **Use Cases (Interactors):** Mengandung logika bisnis spesifik. Setiap use case menangani satu operasi bisnis (misal: `GetProductsUseCase`, `CreateTransactionUseCase`, `SyncDataUseCase`). Mereka orchestrate interaksi antara entities dan repositories.
    *   **Repositories (Abstract Interfaces):** Kontrak yang mendefinisikan operasi data yang dapat dilakukan (misal: `ProductRepository`, `TransactionRepository`). Implementasinya berada di Data Layer.

*   **2.2.2. Data Layer:**
    *   **Repositories (Implementations):** Mengimplementasikan interface dari Domain Layer. Mereka berinterinteraksi dengan Data Sources.
    *   **Data Sources (Local & Remote):**
        *   **Local Data Source:** Berinteraksi langsung dengan database SQLite (menggunakan plugin `sqflite` atau `drift`).
        *   **Remote Data Source:** Berinteraksi dengan RESTful API backend (menggunakan `dio` atau `http` package).
    *   **Models (Data Transfer Objects - DTOs):** Struktur data untuk mapping antara Entities dan format data dari Data Sources (misal: JSON dari API, Row dari SQLite).

*   **2.2.3. Presentation Layer:**
    *   **UI (Widgets):** Komponen antarmuka pengguna (misal: `ProductCard`, `TransactionSummary`).
    *   **State Management:** Mengelola status UI dan berinteraksi dengan Use Cases. Direkomendasikan menggunakan `Provider`, `Bloc/Cubit`, atau `Riverpod` untuk menjaga pemisahan concerns. Untuk MVP awal, `Provider` bisa menjadi pilihan yang lebih ringan.
    *   **Pages/Screens:** Merangkai Widgets dan mengelola lifecycle screen.

**2.3. Arsitektur Backend (Node.js - Express.js)**

Backend akan berupa RESTful API yang melayani aplikasi Flutter, dengan struktur modular.

*   **2.3.1. Routes:** Mendefinisikan endpoint API dan mengarahkan permintaan ke Controller yang sesuai.
*   **2.3.2. Controllers:** Menangani permintaan HTTP (request, response), melakukan validasi input, dan memanggil Service Layer. Tidak mengandung logika bisnis yang kompleks.
*   **2.3.3. Services:** Mengandung logika bisnis utama. Berinteraksi dengan Repository Layer untuk operasi database.
*   **2.3.4. Repositories:** Berinteraksi langsung dengan database PostgreSQL, melakukan operasi CRUD (Create, Read, Update, Delete) dan query kompleks. Menggunakan ORM/Query Builder seperti Sequelize atau Knex.js.
*   **2.3.5. Models:** Mendefinisikan struktur data untuk ORM/Query Builder yang memetakan ke tabel database PostgreSQL.
*   **2.3.6. Utils/Helpers:** Fungsi-fungsi bantu umum (misal: autentikasi JWT, hashing password).

### **3. Desain Komponen Detail**

**3.1. Frontend Components (Flutter)**

*   **Database Lokal (SQLite):**
    *   Penggunaan library: `sqflite` atau `drift`. Direkomendasikan `drift` untuk type-safety dan kemudahan penggunaan.
    *   Struktur tabel: Mirip dengan skema database yang sudah didefinisikan, dengan penambahan kolom `sync_status` (`pending`, `synced`, `error`) dan `last_synced_at` untuk setiap record yang perlu disinkronkan.
*   **API Client:**
    *   Library: `dio` untuk HTTP requests.
    *   Implementasi `RemoteDataSource` akan menggunakan `dio` untuk berkomunikasi dengan backend.
*   **State Management:**
    *   Untuk MVP, kita bisa memulai dengan `Provider` untuk manajemen state yang sederhana dan mudah dipahami.
    *   Setiap `Screen` atau `Widget` yang membutuhkan state akan memiliki `ChangeNotifier` (ViewModel) yang berinteraksi dengan Use Cases.
*   **Navigation:** Menggunakan `go_router` atau Flutter's Navigator 2.0 untuk navigasi yang terkelola dengan baik.
*   **Barcode Scanning:** Menggunakan plugin Flutter untuk kamera (`mobile_scanner` atau sejenisnya) untuk mendeteksi barcode.

**3.2. Backend Components (Node.js)**

*   **Web Framework:** Express.js.
*   **Database ORM/Query Builder:**
    *   `Sequelize` (untuk ORM penuh) atau `Knex.js` (untuk query builder). `Sequelize` akan lebih memudahkan dalam memetakan model ke tabel.
*   **Autentikasi:** JSON Web Tokens (JWT) untuk mengamankan API endpoint.
*   **Validasi Input:** `express-validator` atau `Joi` untuk validasi data yang masuk dari request.
*   **Error Handling:** Middleware terpusat untuk menangani error dan mengirim respons yang konsisten.
*   **Environment Variables:** Menggunakan `dotenv` untuk mengelola konfigurasi sensitif (database credentials, JWT secret).

### **4. Desain API (Backend to Frontend)**

API akan mengikuti prinsip RESTful, menggunakan JSON sebagai format data.

*   **Base URL:** `https://api.smartkasir.com/v1` (contoh)
*   **Autentikasi:** Semua endpoint yang membutuhkan otorisasi akan memerlukan JWT di header `Authorization`.

**4.1. Authentication API**
*   `POST /auth/login`
    *   Request: `{ "username": "...", "password": "..." }`
    *   Response: `{ "token": "...", "user": { "id": "...", "username": "...", "role": "..." } }`

**4.2. Category API**
*   `GET /categories`
    *   Response: `[ { "id": "...", "name": "...", "description": "...", "updated_at": "..." }, ... ]`
*   `POST /categories`
    *   Request: `{ "name": "...", "description": "..." }`
    *   Response: `{ "id": "...", "name": "...", "description": "...", "created_at": "...", "updated_at": "..." }`
*   `PUT /categories/:id`
    *   Request: `{ "name": "...", "description": "..." }`
    *   Response: `{ "id": "...", "name": "...", "description": "...", "created_at": "...", "updated_at": "..." }`
*   `DELETE /categories/:id`
    *   Response: `{ "message": "Category deleted successfully" }`

**4.3. Product API**
*   `GET /products`
    *   Query Params: `?category_id=...&search=...&limit=...&offset=...`
    *   Response: `[ { "id": "...", "name": "...", "barcode": "...", "selling_price": "...", "stock": "...", "category_id": "...", "updated_at": "...", "is_deleted": false }, ... ]`
*   `GET /products/:id`
    *   Response: `{ "id": "...", "name": "...", "barcode": "...", "purchase_price": "...", "selling_price": "...", "stock": "...", "category_id": "...", "unit": "...", "image_url": "...", "created_at": "...", "updated_at": "...", "is_deleted": false }`
*   `POST /products`
    *   Request: `{ "name": "...", "category_id": "...", "purchase_price": "...", "selling_price": "...", "stock": "...", "barcode": "...", "unit": "...", "image_url": "..." }`
    *   Response: `Product object`
*   `PUT /products/:id`
    *   Request: `{ "name": "...", ... }`
    *   Response: `Product object`
*   `DELETE /products/:id`
    *   Response: `{ "message": "Product deleted successfully" }`

**4.4. Transaction API**
*   `POST /transactions/sync` (Endpoint khusus untuk sinkronisasi dari klien)
    *   Request: `[ { "id": "...", "transaction_code": "...", "total_amount": "...", "items": [ { "id": "...", "product_id": "...", "quantity": "...", "price_at_sale": "...", "subtotal": "..." } ], "updated_at": "...", "is_deleted": false (jika transaksi dibatalkan) }, ... ]`
    *   Response: `{ "success": true, "synced_transactions_ids": ["...", "..."], "updated_server_data": [ ... ] }` (Mengirim kembali data yang mungkin lebih baru di server)
*   `GET /transactions`
    *   Query Params: `?start_date=...&end_date=...&limit=...&offset=...`
    *   Response: `[ { "id": "...", "transaction_code": "...", "transaction_date": "...", "final_amount": "...", "payment_method": "...", "updated_at": "...", "items": [...] }, ... ]`
*   `GET /transactions/:id`
    *   Response: `{ "id": "...", "transaction_code": "...", "transaction_date": "...", "total_amount": "...", "discount_amount": "...", "final_amount": "...", "amount_paid": "...", "change_amount": "...", "payment_method": "...", "status": "...", "created_at": "...", "updated_at": "...", "items": [ { "id": "...", "product_id": "...", "product_name": "...", "quantity": "...", "price_at_sale": "...", "subtotal": "..." }, ... ] }`

**4.5. Settings API**
*   `GET /settings`
    *   Response: `[ { "key": "store_name", "value": "Toko Barokah" }, { "key": "store_address", "value": "Jl. Raya No. 1" } ]`
*   `POST /settings`
    *   Request: `[ { "key": "store_name", "value": "Toko Jaya" }, { "key": "store_address", "value": "Jl. Baru No. 2" } ]`
    *   Response: `{ "message": "Settings updated" }`

### **5. Desain Database (Detail dari Dokumen Skema Database)**

Lihat dokumen "Skema Database SmartKasir" untuk detail lengkap mengenai tabel, kolom, tipe data, kunci utama, dan kunci asing.

**5.1. Perbedaan Implementasi Lokal vs Remote**
*   **UUID:** Disimpan sebagai `TEXT` di SQLite, `UUID` di PostgreSQL.
*   **Timestamp:** Disimpan sebagai `TEXT` di SQLite (ISO8601), `TIMESTAMP` di PostgreSQL.
*   **Boolean:** Disimpan sebagai `INTEGER` (0/1) di SQLite, `BOOLEAN` di PostgreSQL.
*   **Kolom Sinkronisasi (Hanya Lokal):**
    *   `products.last_synced_at`, `products.sync_status`
    *   `transactions.is_synced` (cukup boolean karena transaksi hanya dibuat lokal lalu di-push)
    *   `categories.last_synced_at`, `categories.sync_status` (jika kategori bisa dibuat/diedit offline)
    *   `settings.last_synced_at`, `settings.sync_status` (jika setting bisa diedit offline)

**5.2. Strategi Sinkronisasi**
*   **Data Model:** Setiap entitas yang disinkronkan akan memiliki ID unik (UUID) dan `updated_at` timestamp.
*   **Push dari Klien:**
    1.  Klien mengidentifikasi data lokal yang belum disinkronkan (`sync_status = 'pending'`, `is_synced = FALSE`).
    2.  Klien mengirimkan data ini ke endpoint `/sync` backend.
    3.  Backend menerima data:
        *   Jika `id` baru di server, buat record baru.
        *   Jika `id` sudah ada di server, bandingkan `updated_at`. Jika `updated_at` klien lebih baru, update record server. Jika server lebih baru (konflik), backend bisa mengembalikan data server yang lebih baru untuk klien update (atau klien menangani konflik dengan mengutamakan lokal). Untuk MVP, kita akan utamakan `updated_at` terbaru.
    4.  Backend mengembalikan daftar `id` data yang berhasil disinkronkan dan data yang mungkin diperbarui di server.
    5.  Klien memperbarui `sync_status` menjadi 'synced' dan `last_synced_at` untuk data yang berhasil disinkronkan, serta mengupdate data lokal jika ada yang dikirim kembali dari server.
*   **Pull ke Klien:**
    1.  Klien meminta semua data (produk, kategori, setting) dari server yang `updated_at`-nya lebih baru dari `last_synced_at` klien secara global.
    2.  Server mengembalikan data tersebut.
    3.  Klien mengupdate/menambahkan data di SQLite lokal, mengatur `last_synced_at` dan `sync_status = 'synced'`.
*   **Interval Sinkronisasi:** Sinkronisasi otomatis akan dicoba setiap 5-10 menit jika ada koneksi internet dan/atau ketika aplikasi diluncurkan.

### **6. Desain UI/UX (High-Level)**

*   **Palet Warna:** Primer: #2196F3 (Biru), Sekunder: #FFC107 (Amber). Aksen: #4CAF50 (Hijau), #F44336 (Merah). Background: #F5F5F5 (Light Grey).
*   **Tipografi:** Font default perangkat (Roboto/Noto Sans).
*   **Ikonografi:** Material Icons yang jelas dan intuitif.
*   **Layout Umum:**
    *   **Bottom Navigation Bar:** Terdiri dari 4 ikon: Transaksi, Stok, Laporan, Pengaturan.
    *   **App Bar:** Judul layar, ikon notifikasi (stok minimum), ikon pencarian.
    *   **Tombol Aksi Mengambang (FAB):** Digunakan untuk tindakan utama (misal: "Tambah Produk", "Buat Transaksi").

### **7. Rencana Pengujian (Detailed)**

*   **Unit Testing:**
    *   **Frontend:** Domain Layer (Entities, Use Cases), Data Layer (Repository implementations, Data Sources mock).
    *   **Backend:** Service Layer, Repository Layer.
*   **Integration Testing:**
    *   **Frontend:** Interaksi antara UI, State Management, Use Cases, dan Repository (mocking Data Sources).
    *   **Backend:** Integrasi API dengan Service dan Database.
*   **End-to-End Testing:**
    *   Menggunakan tools seperti `Flutter Driver` atau `Appium`/`Detox` untuk mensimulasikan skenario pengguna dari awal hingga akhir, termasuk proses sinkronisasi.
*   **Performance Testing:**
    *   Menguji waktu respons API menggunakan `JMeter` atau `Postman`.
    *   Menguji waktu muat aplikasi dan transisi layar pada perangkat target.
*   **Security Testing:**
    *   Vulnerability scanning pada backend API.
    *   Pengujian otorisasi dan autentikasi.

### **8. Lingkungan Pengembangan & Deployment**

*   **IDE:** Visual Studio Code (Flutter & Node.js).
*   **Version Control:** Git (GitHub/GitLab).
*   **CI/CD (Initial):** GitHub Actions/GitLab CI untuk build otomatis aplikasi Flutter dan deploy backend (opsional untuk MVP awal, bisa manual deploy dulu).
*   **Deployment Backend:** Heroku, AWS EC2/Lightsail, Google Cloud Run.
*   **Deployment Frontend:** Google Play Store.

### **9. Struktur Proyek (Direktori)**

Bagian ini mendefinisikan struktur direktori yang direkomendasikan untuk proyek SmartKasir, baik di sisi frontend (Flutter) maupun backend (Node.js). Struktur ini dirancang untuk mendukung Clean Architecture dan modularitas, memfasilitasi pengembangan, pemeliharaan, dan skalabilitas.

**9.1. Struktur Proyek Frontend (Flutter)**

Mengikuti prinsip Clean Architecture, proyek Flutter akan memiliki struktur yang jelas untuk memisahkan domain, data, dan presentation layer.

```
smart_kasir_app/
├── lib/
│   ├── main.dart
│   ├── core/                           # Shared functionalities (common utils, constants, error handling)
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/                    # Dio interceptors, error parsers
│   │   ├── utils/                      # Generic helper functions
│   ├── features/                       # Each feature is a self-contained module
│   │   ├── auth/                       # Authentication feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/        # Remote & Local Auth Data Sources
│   │   │   │   ├── models/             # Auth-specific DTOs
│   │   │   │   └── repositories/       # Auth Repository Impl
│   │   │   ├── domain/
│   │   │   │   ├── entities/           # Auth User Entity
│   │   │   │   ├── repositories/       # Abstract Auth Repository
│   │   │   │   └── usecases/           # LoginUseCase, LogoutUseCase
│   │   │   └── presentation/
│   │   │       ├── bloc/ (or provider/cubit) # State Management
│   │   │       ├── pages/              # LoginScreen, RegisterScreen (if applicable)
│   │   │       └── widgets/            # Auth-related UI components
│   │   ├── product/                    # Product Management feature
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   ├── category/                   # Category Management feature
│   │   │   ├── ... (similar structure to product)
│   │   ├── transaction/                # Transaction Management feature
│   │   │   ├── ... (similar structure to product)
│   │   ├── report/                     # Reporting feature
│   │   │   ├── ...
│   │   ├── settings/                   # Application Settings feature
│   │   │   ├── ...
│   ├── routes/                         # Centralized routing configuration (e.g., go_router)
│   └── shared/                         # Common UI widgets, themes, assets not specific to any feature
│       ├── widgets/
│       ├── themes/
│       └── assets/
├── pubspec.yaml
├── README.md
└── ... (other Flutter generated files)
```

**Penjelasan:**
*   **`lib/core/`**: Berisi kode fundamental yang digunakan di seluruh aplikasi dan tidak terikat pada fitur tertentu.
*   **`lib/features/`**: Setiap sub-direktori di sini merepresentasikan sebuah fitur bisnis utama (misal: `product`, `transaction`). Setiap fitur memiliki struktur Clean Architecture-nya sendiri (`data`, `domain`, `presentation`).
*   **`lib/routes/`**: Mengelola definisi dan konfigurasi navigasi aplikasi.
*   **`lib/shared/`**: Komponen UI atau aset yang bisa dipakai ulang di berbagai fitur.

**9.2. Struktur Proyek Backend (Node.js - Express.js)**

Proyek backend akan mengadopsi struktur modular untuk memisahkan concerns seperti routing, controllers, services, repositories, dan models.

```
smart_kasir_backend/
├── src/
│   ├── app.js                          # Main Express app file
│   ├── config/                         # Configuration files (database, JWT secret, env variables)
│   │   ├── database.js
│   │   ├── jwt.js
│   │   └── index.js
│   ├── middlewares/                    # Custom Express middlewares (auth, error handling, logging)
│   │   ├── auth.middleware.js
│   │   └── error.middleware.js
│   ├── modules/                        # Feature-specific modules
│   │   ├── auth/
│   │   │   ├── auth.controller.js
│   │   │   ├── auth.route.js
│   │   │   └── auth.service.js
│   │   ├── category/
│   │   │   ├── category.controller.js
│   │   │   ├── category.model.js       # Sequelize/Knex model definition
│   │   │   ├── category.repository.js  # Database interactions
│   │   │   ├── category.route.js
│   │   │   └── category.service.js
│   │   ├── product/
│   │   │   ├── product.controller.js
│   │   │   ├── product.model.js
│   │   │   ├── product.repository.js
│   │   │   ├── product.route.js
│   │   │   └── product.service.js
│   │   ├── transaction/
│   │   │   ├── transaction.controller.js
│   │   │   ├── transaction.model.js
│   │   │   ├── transaction.repository.js
│   │   │   ├── transaction.route.js
│   │   │   └── transaction.service.js
│   │   ├── report/
│   │   │   ├── report.controller.js
│   │   │   ├── report.route.js
│   │   │   └── report.service.js
│   │   └── settings/
│   │       ├── settings.controller.js
│   │       ├── settings.model.js
│   │       ├── settings.repository.js
│   │       ├── settings.route.js
│   │       └── settings.service.js
│   ├── routes/                         # Main API routes aggregation
│   │   └── index.js                    # Aggregates all module routes
│   ├── utils/                          # General utilities (e.g., password hashing, validators)
│   │   └── helpers.js
│   └── server.js                       # Entry point of the application
├── tests/                              # Unit and integration tests
├── .env                                # Environment variables
├── package.json
├── README.md
└── ... (other Node.js related files)
```

**Penjelasan:**
*   **`src/app.js`**: Menginisialisasi aplikasi Express utama.
*   **`src/server.js`**: Titik masuk aplikasi, menginisialisasi server dan database.
*   **`src/config/`**: Berisi konfigurasi aplikasi, termasuk pengaturan database, JWT, dan pemuatan variabel lingkungan.
*   **`src/middlewares/`**: Middleware global untuk autentikasi, penanganan error, dan logging.
*   **`src/modules/`**: Direktori inti untuk logika bisnis. Setiap sub-direktori adalah modul fitur yang mandiri, mengandung controller, model (jika menggunakan ORM), repository, route, dan service-nya sendiri.
*   **`src/routes/`**: Mengagregasikan semua route dari modul-modul yang berbeda.
*   **`src/utils/`**: Fungsi-fungsi utilitas yang digunakan di seluruh aplikasi.
*   **`tests/`**: Berisi semua file pengujian.

