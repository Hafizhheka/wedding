# PRD — Platform Undangan Digital Pernikahan Self-Service

**Status:** Draft untuk review  
**Pemilik produk:** TBD  
**Target rilis, anggaran, dan kapasitas tim:** TBD  
**Tujuan peluncuran:** Validasi pasar dan rilis MVP pertama untuk calon pengantin. Sasaran MVP: 30 undangan berhasil dipublikasikan.

## 1. Executive Summary

**Problem Statement**  
Calon pengantin di Indonesia memerlukan cara mandiri untuk membuat undangan digital yang menarik dan mudah dibagikan, tanpa proses desain dan revisi manual yang panjang. Tamu juga memerlukan satu halaman yang memuat seluruh detail acara dan tempat menyampaikan ucapan.

**Proposed Solution**  
Bangun platform web untuk memilih template, mengisi konten, membeli paket melalui Midtrans Snap, dan menerbitkan halaman undangan pada slug publik. Admin mengelola kategori dan template. Warna dan tema visual ditetapkan melalui konfigurasi tema per template dan tidak dapat diubah pengguna.

**Success Criteria MVP**

- Sedikitnya 30 undangan berstatus published berhasil diterbitkan oleh calon pengantin selama pilot MVP.
- Pembayaran paket Free Trial, Basic, Pro, dan Premium mengikuti aturan entitlement dan limit yang dikonfigurasi.
- 100% notifikasi pembayaran sah diproses idempoten dan status order mengikuti status gateway yang tervalidasi.
- Tidak ada jalur UI/API yang memungkinkan pengguna akhir mengubah konfigurasi tema template.
- Undangan published dapat dibuka secara responsif melalui slug publik dan tamu dapat mengirim ucapan.

Konversi trial ke paket berbayar dan waktu dari pendaftaran ke publikasi dicatat sebagai metrik validasi pasar; targetnya ditetapkan setelah baseline dari 30 publikasi pertama.

## 2. User Experience & Functionality

### User Personas

- **Calon pengantin (pemilik undangan):** sedang merencanakan pernikahan dan ingin membuat, mengedit, menerbitkan undangan sendiri, serta memantau ucapan.
- **Tamu:** membaca informasi acara dari ponsel/desktop dan mengirim ucapan.
- **Admin konten:** mengelola kategori, template, aset, dan konfigurasi tema.
- **Operator support:** membantu isu akun dan pembayaran dengan akses terbatas (opsional).

### User Stories dan Acceptance Criteria

#### Autentikasi

**Story:** Sebagai calon pengguna, saya ingin mendaftar dan masuk dengan email-password agar dapat mengelola undangan saya.

- Pendaftaran meminta verifikasi email sebelum publikasi.
- Pengguna dapat meminta reset password menggunakan token sekali pakai yang kedaluwarsa.
- Respons reset tidak membocorkan apakah email terdaftar.
- Rute privat memeriksa sesi dan kepemilikan objek di server.
- Peran minimum user/admin; pengguna tidak dapat menaikkan hak aksesnya.
- Pembatasan percobaan login dan reset mengurangi brute force.

#### Katalog, template, dan admin

**Story:** Sebagai pasangan, saya ingin menelusuri kategori dan melihat pratinjau template sebelum memilihnya.

- Katalog publik hanya menampilkan template aktif.
- Template detail menunjukkan preview dan kategori.
- Admin dapat CRUD kategori dan template, mengatur status aktif, serta mengelola versi dan tema.
- Tema memiliki skema tervalidasi dan allowlist token visual; CSS/HTML bebas tidak diterima.
- Template yang dinonaktifkan tidak merusak undangan yang sudah terbit.

#### Membuat, mengedit, menerbitkan undangan

**Story:** Sebagai pasangan, saya ingin mengisi undangan berbasis template dan menerbitkannya pada tautan unik.

- Alur: pilih template → buat draft → isi konten → pratinjau → pilih slug → pemeriksaan kuota → publikasi.
- Draft dapat disimpan dan dilanjutkan; field wajib divalidasi sebelum publish.
- Slug dinormalisasi, unik, dan menolak reserved route.
- Status undangan minimal draft, published, archived.
- Jumlah undangan aktif tidak melampaui entitlement paket. Pengecekan atomik dilakukan di server saat publish.
- Publikasi memerlukan akun terverifikasi dan entitlement aktif yang cukup.
- Pengguna hanya dapat mengubah undangan miliknya; pembatasan ini diverifikasi server-side.

#### Detail acara dan media

**Story:** Sebagai pasangan, saya ingin menyertakan informasi acara, foto, dan cerita agar tamu memperoleh konteks lengkap.

- Mendukung acara terpisah, setidaknya akad dan resepsi, dengan tanggal/waktu, zona waktu, lokasi, alamat, dan tautan peta opsional.
- Mendukung galeri foto yang diunggah ke Supabase Storage, diurutkan, dan diberi caption opsional.
- Mendukung bagian cerita pasangan yang diurutkan.
- Mendukung informasi hadiah digital yang ditampilkan hanya bila pemilik mengaktifkannya.
- Countdown dihitung dari waktu acara; perilaku setelah hari-H ditentukan secara konsisten.
- Batas jumlah/ukuran foto dan format hadiah digital: TBD.

#### Subscription dan pembayaran

**Story:** Sebagai pasangan, saya ingin membeli paket agar memperoleh kuota undangan aktif sesuai kebutuhan.

- Model bisnis terdiri dari Free Trial serta paket Basic, Pro, dan Premium. Setiap tier memiliki harga, durasi, limit undangan aktif, dan status yang dikelola backend. Harga, durasi trial, limit per tier, serta perbedaan benefit Basic/Pro/Premium TBD dan wajib diputuskan sebelum checkout dirilis.
- Transaksi Snap dibuat server-side; harga dari browser tidak dipercaya.
- Order internal disimpan sebelum token/redirect checkout dikembalikan.
- Notifikasi Midtrans diverifikasi, diproses idempoten, dan hanya transisi status yang sah diterima.
- Status minimum: pending, paid, failed, expired; refund ditambahkan jika kebijakan produk mendukung.
- Entitlement diterbitkan hanya setelah konfirmasi server-side yang tervalidasi.
- Kebijakan renewal, masa tenggang, prorata, refund, trial-to-paid conversion, dan downgrade TBD.

#### Undangan publik dan Wall of Wishes

**Story:** Sebagai tamu, saya ingin membaca undangan dan mengirim ucapan tanpa membuat akun.

- Slug publik hanya menyajikan undangan berstatus published.
- Layout responsif dari viewport 360 px hingga desktop tanpa scroll horizontal.
- Menampilkan identitas pasangan, acara, lokasi, galeri, cerita, hadiah opsional, countdown, dan Wall of Wishes.
- Ucapan menerima nama dan pesan; validasi panjang, rate limit, sanitasi output, dan kontrol spam diterapkan.
- Pemilik dapat menyembunyikan ucapan. Pra-moderasi, pelaporan, dan proses takedown: TBD.
- RSVP/konfirmasi kehadiran belum termasuk sampai dikonfirmasi sebagai kebutuhan MVP.
- Draft, data akun, dan field internal tidak dapat diakses publik.

#### Invarian konfigurasi tema

**Story:** Sebagai admin, saya ingin setiap template menetapkan tampilan visualnya agar desain tetap konsisten.

- Hanya admin berotorisasi yang dapat mengubah konfigurasi tema.
- Endpoint edit undangan menolak atau mengabaikan nilai tema yang dikirim pengguna.
- Renderer mengambil tema dari versi template yang otoritatif, bukan dari input pengguna, query parameter, atau local storage.
- Tema menggunakan token warna/font/aset terpilih; tidak menerima CSS arbitrer.
- Pratinjau dan halaman publik memakai sumber konfigurasi yang sama.
- Usulan: simpan versi template dan snapshot konfigurasi ketika undangan dibuat/diterbitkan supaya tampilan undangan lama stabil. Perubahan template hanya memengaruhi undangan baru kecuali migrasi admin.

### Alur Utama

1. Daftar → verifikasi email → masuk.
2. Pilih paket → checkout Snap → webhook terverifikasi → entitlement aktif.
3. Pilih template → draft dibuat → konten dan foto diisi → pratinjau.
4. Pilih slug → pemeriksaan unik dan kuota → publish.
5. Bagikan tautan → tamu membaca dan mengirim ucapan.
6. Admin mengelola kategori/template/tema lewat panel dengan kontrol akses dan audit.

### Non-Goals

- Aplikasi native iOS/Android.
- Editor bebas/drag-and-drop atau perubahan tema oleh pengguna.
- RSVP lanjutan, seating chart, check-in QR.
- WhatsApp/SMS/email blast.
- Domain kustom, white-label, dan marketplace vendor.
- Subscription berulang otomatis sebelum kebutuhan bisnis dikonfirmasi.
- Moderasi ucapan berbasis AI.

## 3. AI System Requirements

Tidak ada fitur AI yang dibutuhkan untuk MVP.

## 4. Technical Specifications

### Architecture Overview

- **Web:** Next.js App Router untuk katalog, dashboard, panel admin, route handler, dan renderer undangan publik.
- **Auth:** NextAuth/Auth.js dengan penyimpanan sesi melalui PostgreSQL. Alur email-password perlu implementasi hash password (Argon2id atau bcrypt), token verifikasi/reset, pengiriman email, dan rate limit. Provider email TBD.
- **Database dan ORM:** PostgreSQL sebagai database relasional dengan Prisma ORM sebagai akses data aplikasi. Prisma Client digunakan dari server Next.js; skema didefinisikan dalam schema.prisma dan perubahan struktur database dikelola dengan Prisma Migrate. Data mencakup pengguna, template, kategori, undangan, acara, metadata media, ucapan, paket, order, entitlement, dan audit log.
- **Storage:** Supabase Storage untuk aset template/foto. Gunakan signed upload URL dan validasi tipe/ukuran di server; kebijakan bucket dan retensi TBD.
- **Pembayaran:** Midtrans Snap. Secret hanya server-side; pisahkan sandbox dan production. Webhook diverifikasi dan idempoten.
- **Admin:** RBAC server-side serta audit log untuk perubahan template, kategori, paket, dan hak akses.
- **Public rendering:** resolve slug → cek status → muat undangan dan versi template/tema → render. Cache harus divalidasi ulang saat konten publik berubah dan tidak boleh mencampur data privat.

### Data Model Inti (konseptual)

- User: email, passwordHash, emailVerifiedAt, role.
- VerificationToken: user/email, tokenHash, purpose, expiresAt, usedAt.
- Category: slug, name, status, sortOrder.
- Template: categoryId, status, version, themeConfig JSON, schemaVersion, previewAsset.
- Plan: price, currency, activeInviteLimit, duration, status.
- Order: userId, planId, amount, currency, status, gatewayRef, idempotencyKey.
- Entitlement: userId, planId, startsAt, endsAt, activeInviteLimit, sourceOrderId.
- Invitation: ownerId, templateId/version, themeSnapshot, slug, status, publishedAt.
- Event: invitationId, type, startsAt, timezone, venue/address/mapUrl.
- Photo/StorySection/GiftOption: invitationId dan metadata konten.
- Wish: invitationId, guestName, message, moderationStatus, createdAt.
- AuditLog: actorId, action, target, timestamp, metadata.

Model konseptual diterjemahkan ke model Prisma dan relasi PostgreSQL. Indeks, constraint unik, transaksi, serta strategi retensi dan enkripsi field sensitif ditentukan dalam desain teknis.

### Integration Points

- NextAuth/Auth.js dan adapter PostgreSQL.
- Provider email verifikasi/reset: TBD.
- Midtrans Snap create transaction dan HTTP notification.
- Supabase Storage untuk media.
- Prisma Client dan Prisma Migrate untuk query serta migrasi PostgreSQL. Hosting, CDN, error tracking, monitoring, dan anti-spam provider: TBD.

### Security & Privacy

- Simpan hash password, bukan password/token mentah; token reset/verifikasi sekali pakai.
- Cookie sesi HttpOnly, Secure di production, SameSite; proteksi CSRF mengikuti pola framework.
- Periksa kepemilikan untuk setiap akses undangan, foto, dan data privat guna mencegah IDOR.
- RBAC admin, audit perubahan sensitif, dan pembatasan percobaan login/publish/upload/checkout/ucapan.
- Validasi input di server dan render konten sebagai teks; sanitasi bila rich text diizinkan.
- Batasi ukuran dan tipe upload, verifikasi isi file, buat path di server, dan beri masa berlaku signed URL.
- Validasi signature, nominal, mata uang, referensi order, idempotency, dan urutan status pembayaran.
- Minimalkan data tamu dan tentukan retensi/penghapusan akun. Siapkan kebijakan privasi serta telaah hukum lokal sebelum produksi.
- Validasi konfigurasi tema dengan skema allowlist; rahasia hanya tersimpan di environment/server.
- Tetapkan backup PostgreSQL, transport encryption, dan prosedur pemulihan insiden.

### Non-Functional Requirements

- UI utama WCAG 2.2 AA sebagai target.
- Usulan performa: p75 LCP halaman publik <2.5 detik pada profil koneksi yang disepakati; p95 API CRUD <500 ms di luar gateway/upload.
- Usulan availability halaman publik 99.5% bulanan.
- Bahasa UI MVP: Indonesia. Waktu acara disimpan dan ditampilkan dengan zona waktu eksplisit.
- Halaman publik menyediakan metadata berbagi dan tidak mengindeks draft.
- Target kapasitas dan beban konkret ditentukan sebelum deployment.

## 5. Risks & Roadmap

### Phased Rollout

**MVP Pertama — seluruh fitur yang diminta masuk lingkup rilis**

- Auth email-password, verifikasi email, dan forgot/reset password.
- Subscription tier Free Trial, Basic, Pro, Premium; limit undangan aktif per tier; checkout Midtrans Snap dan pemrosesan notifikasi pembayaran.
- Katalog template per kategori; pembuatan, pengeditan, pratinjau, dan publikasi undangan pada slug publik.
- Admin panel CRUD template dan kategori.
- Detail acara ganda (akad dan resepsi), galeri foto melalui Supabase Storage, cerita pasangan, hadiah digital, dan countdown hari-H.
- Halaman publik responsif desktop dan mobile serta Wall of Wishes publik.
- Tema/warna khusus per template melalui themeConfig yang tidak dapat dioverride end-user.
- Logging, backup, kebijakan privasi, keamanan, dan dukungan operasional minimum.
- Kriteria selesai pilot MVP: minimal 30 undangan berhasil dipublikasikan.

**V1.1**

- Peningkatan alat moderasi ucapan dan rekonsiliasi pembayaran.
- Analitik ringan pemilik jika disetujui dari sisi privasi.
- Peningkatan SEO, optimasi media, dan migrasi versi template.

**V2.0**

- RSVP jika kebutuhan terkonfirmasi.
- Subscription recurring, domain kustom, integrasi distribusi, multi-bahasa, atau vendor berdasarkan validasi pasar.

### Technical Risks

- Credentials auth membutuhkan pekerjaan aplikasi untuk verifikasi/reset aman dan perlindungan brute force.
- Webhook tertunda/duplikat dapat salah menerbitkan entitlement tanpa state machine dan idempotency.
- Publish paralel dapat melewati limit bila pemeriksaan kuota tidak atomik.
- Perubahan tema/schema dapat merusak undangan lama tanpa versioning.
- Bandwidth dan biaya media dapat naik tanpa batas upload dan optimasi gambar.
- Spam/penyalahgunaan ucapan publik butuh rate limit, moderasi, serta proses takedown.
- Keputusan harga, masa aktif, definisi undangan aktif, refund, dan downgrade harus dibuat sebelum checkout/kuota dibangun.
- Data pribadi pasangan/tamu dan informasi hadiah digital memerlukan minimisasi, kontrol akses, dan kebijakan retensi.

### Open Questions

1. KPI MVP ditetapkan: sedikitnya 30 undangan published. Metrik trial-to-paid dan waktu publikasi dicatat untuk validasi pasar; target tambahannya TBD.
2. Kapan target rilis, berapa anggaran, dan apakah ada tim/pilot tertentu?
3. Harga, durasi Free Trial, kuota aktif, dan benefit Basic/Pro/Premium; definisi undangan aktif, refund, renewal, downgrade?
4. Apakah RSVP masuk MVP?
5. Ucapan tampil langsung atau menunggu persetujuan pemilik?
6. Apakah snapshot versi tema/template saat draft dibuat dapat diterima?
7. Provider email, hosting/CDN, monitoring, dan retensi data apa yang dipilih? Prisma ORM ditetapkan untuk PostgreSQL.
8. Batas upload/foto dan format hadiah digital seperti apa?

**Keputusan lanjutan yang masih terbuka:** target rilis/anggaran, harga dan benefit tiap paket, definisi kuota aktif, RSVP, moderasi ucapan, dan strategi versi tema. Semua fitur yang disebut pada kebutuhan awal tetap masuk lingkup MVP pertama.
