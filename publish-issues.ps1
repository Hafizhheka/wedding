$ErrorActionPreference = "Stop"

$Repo = "Hafizhheka/wedding"
$Label = "ready-for-agent"

gh auth status --hostname github.com
if ($LASTEXITCODE -ne 0) { throw "gh belum terautentikasi ke github.com." }

$repoName = gh repo view $Repo --json nameWithOwner --jq .nameWithOwner
if ($LASTEXITCODE -ne 0 -or $repoName -ne $Repo) {
  throw "Repositori $Repo tidak dapat diakses oleh gh."
}

$labelsJson = gh label list --repo $Repo --limit 100 --json name
if ($LASTEXITCODE -ne 0) { throw "Gagal membaca label repositori." }
$labels = @($labelsJson | ConvertFrom-Json)
if (-not ($labels | Where-Object { $_.name -eq $Label })) {
  gh label create $Label --repo $Repo --color "0E8A16" --description "Issue siap dikerjakan oleh agent"
  if ($LASTEXITCODE -ne 0) { throw "Gagal membuat label '$Label'." }
}

function New-GhIssue {
  param(
    [Parameter(Mandatory = $true)][string]$Title,
    [Parameter(Mandatory = $true)][string]$Body
  )

  $search = "in:title $Title"
  $existingJson = gh issue list --repo $Repo --state all --limit 100 --search $search --json title,url
  if ($LASTEXITCODE -ne 0) { throw "Gagal memeriksa issue yang sudah ada: $Title" }
  $existingIssues = @($existingJson | ConvertFrom-Json)
  $existing = $existingIssues | Where-Object { $_.title -eq $Title } | Select-Object -First 1
  if ($existing) {
    Write-Host "Sudah ada: $($existing.url)"
    return $existing.url
  }

  $ghArgs = @("issue", "create", "--repo", $Repo, "--title", $Title, "--body", $Body, "--label", $Label)
  $output = gh @ghArgs
  if ($LASTEXITCODE -ne 0) { throw "Gagal membuat issue: $Title" }

  $url = [regex]::Match(($output -join [Environment]::NewLine), "https://github\.com/Hafizhheka/wedding/issues/\d+").Value
  if (-not $url) { throw "Issue '$Title' mungkin dibuat, tetapi URL tidak ditemukan pada output gh." }

  Write-Host "Created: $url"
  return $url
}

$body1 = @'
## What to build

Pengguna dapat membuat akun dan mengelolanya dengan aman melalui verifikasi email, login, serta reset kata sandi.

## Acceptance criteria

- [ ] Pendaftaran email-password mengirim token verifikasi sekali pakai yang kedaluwarsa; publikasi memerlukan email terverifikasi.
- [ ] Pengguna dapat meminta reset password dengan token sekali pakai yang kedaluwarsa.
- [ ] Respons reset tidak mengungkap apakah alamat email terdaftar.
- [ ] Rute privat memeriksa sesi dan kepemilikan objek di server; pengguna tidak dapat menaikkan perannya sendiri.
- [ ] Percobaan login dan reset dibatasi untuk mengurangi brute force.
- [ ] Sesi menggunakan pengaturan cookie aman sesuai lingkungan.

## Blocked by

None (can start immediately).

## Status

ready-for-agent
'@
$issue1 = New-GhIssue -Title "Autentikasi dan keamanan akun" -Body $body1

$body2 = @"
## What to build

Pengunjung dapat menelusuri kategori dan pratinjau template aktif. Admin berwenang dapat mengelola kategori, template, status, dan aset pratinjau.

## Acceptance criteria

- [ ] Katalog publik hanya menampilkan template aktif; detail template menampilkan pratinjau dan kategori.
- [ ] Admin dapat membuat, membaca, mengubah, dan menghapus kategori serta template.
- [ ] Admin dapat mengatur status aktif dan urutan kategori/template.
- [ ] Aset pratinjau dikelola dengan validasi input dan kontrol akses admin.
- [ ] Template yang dinonaktifkan tidak merusak undangan yang sudah terbit.

## Blocked by

- [$issue1] (autentikasi, peran admin, dan kontrol akses akun)

## Status

ready-for-agent
"@
$issue2 = New-GhIssue -Title "Katalog dan administrasi kategori serta template" -Body $body2

$body3 = @"
## What to build

Admin menetapkan tema visual tervalidasi untuk setiap versi template, dan undangan menggunakan konfigurasi tersebut tanpa dapat dioverride oleh pemilik.

## Acceptance criteria

- [ ] Konfigurasi tema divalidasi dengan skema dan allowlist token warna, font, dan aset.
- [ ] CSS atau HTML bebas ditolak; hanya admin berotorisasi dapat mengubah tema.
- [ ] Template memiliki versi dan skema tema yang dapat dirujuk oleh undangan.
- [ ] Undangan memakai versi/snapshot tema otoritatif agar perubahan template baru tidak mengubah undangan lama secara tak terduga.
- [ ] Endpoint edit undangan menolak atau mengabaikan tema dari input pengguna.
- [ ] Pratinjau dan renderer publik menggunakan sumber konfigurasi tema yang sama.

## Blocked by

- [$issue2] (katalog dan administrasi template)

## Status

ready-for-agent
"@
$issue3 = New-GhIssue -Title "Konfigurasi tema tervalidasi dan versioning template" -Body $body3

$body4 = @"
## What to build

Pemilik dapat membuat dan melanjutkan draft dari template, mengisi detail acara, serta melihat pratinjau undangan.

## Acceptance criteria

- [ ] Pemilik dapat membuat, menyimpan, dan melanjutkan draft dari template yang tersedia.
- [ ] Draft mendukung sedikitnya akad dan resepsi, masing-masing dengan tanggal/waktu, zona waktu eksplisit, lokasi, alamat, dan tautan peta opsional.
- [ ] Field wajib divalidasi sebelum publikasi.
- [ ] Pratinjau menampilkan data draft dengan versi template dan tema yang dipilih.
- [ ] Hanya pemilik undangan yang dapat membaca atau mengubah draft; pemeriksaan dilakukan di server.

## Blocked by

- [$issue2] (template yang tersedia)
- [$issue3] (versi template dan konfigurasi tema)

## Status

ready-for-agent
"@
$issue4 = New-GhIssue -Title "Draft undangan dan detail acara" -Body $body4

$body5 = @"
## What to build

Pemilik dapat melengkapi draft dengan foto, cerita pasangan, hadiah digital opsional, dan countdown acara.

## Acceptance criteria

- [ ] Foto diunggah ke Supabase Storage melalui signed upload URL dengan validasi tipe, isi, dan ukuran di server.
- [ ] Pemilik dapat mengurutkan foto galeri dan memberi caption opsional.
- [ ] Pemilik dapat menambah, mengubah urutan, dan menghapus bagian cerita pasangan.
- [ ] Informasi hadiah digital hanya ditampilkan jika pemilik mengaktifkannya.
- [ ] Countdown dihitung dari waktu acara dan berperilaku konsisten setelah hari-H.
- [ ] Batas jumlah/ukuran foto dan format hadiah digital dikonfigurasi sebelum rilis.

## Blocked by

- [$issue4] (draft undangan dan detail acara)

## Status

ready-for-agent
"@
$issue5 = New-GhIssue -Title "Media dan konten pendukung undangan" -Body $body5

$body6 = @"
## What to build

Pengguna dapat memilih paket yang dikonfigurasi dan memulai checkout Midtrans Snap dengan order yang dibuat dan dihargai oleh server.

## Acceptance criteria

- [ ] Backend menyediakan Free Trial, Basic, Pro, dan Premium dengan harga, mata uang, durasi, limit undangan aktif, dan status yang dikonfigurasi.
- [ ] Definisi undangan aktif dan benefit tiap paket ditetapkan sebelum checkout dirilis.
- [ ] Harga dari browser tidak dipercaya; server menentukan paket dan jumlah tagihan.
- [ ] Order internal disimpan sebelum token atau redirect Snap dikembalikan.
- [ ] Secret Midtrans hanya tersedia di server dan sandbox dipisahkan dari production.
- [ ] Status minimum order mencakup pending, paid, failed, dan expired.

## Blocked by

- [$issue1] (autentikasi dan keamanan akun)

## Status

ready-for-agent
"@
$issue6 = New-GhIssue -Title "Paket, order, dan checkout Midtrans Snap" -Body $body6

$body7 = @"
## What to build

Notifikasi pembayaran Midtrans diproses aman dan idempoten; entitlement hanya aktif setelah status order tervalidasi oleh server.

## Acceptance criteria

- [ ] Signature notifikasi diverifikasi menggunakan kredensial server.
- [ ] Nominal, mata uang, referensi order, dan identitas transaksi dicocokkan dengan order internal.
- [ ] Notifikasi duplikat tidak menggandakan entitlement atau efek samping lain.
- [ ] Hanya transisi status yang sah diterima; status order mencakup pending, paid, failed, dan expired.
- [ ] Entitlement diterbitkan hanya setelah konfirmasi pembayaran server-side yang valid.
- [ ] Kegagalan atau notifikasi tertunda dapat ditelusuri melalui log tanpa membocorkan secret.

## Blocked by

- [$issue6] (order dan checkout Midtrans Snap)

## Status

ready-for-agent
"@
$issue7 = New-GhIssue -Title "Verifikasi pembayaran dan penerbitan entitlement" -Body $body7

$body8 = @"
## What to build

Pemilik yang memenuhi syarat dapat menerbitkan undangan pada slug publik unik dengan pemeriksaan kuota aktif yang aman terhadap publikasi bersamaan.

## Acceptance criteria

- [ ] Slug dinormalisasi, unik, dan menolak reserved route.
- [ ] Publikasi mensyaratkan akun terverifikasi dan entitlement aktif dengan kuota yang cukup.
- [ ] Pemeriksaan dan penggunaan kuota berlangsung atomik di server.
- [ ] Status undangan minimal draft, published, dan archived.
- [ ] Hanya pemilik yang dapat menerbitkan atau mengubah undangannya.
- [ ] Tema dan versi template bersumber dari konfigurasi otoritatif, bukan input pengguna.
- [ ] Cache publik divalidasi ulang saat konten published berubah.

## Blocked by

- [$issue3] (versi template dan tema)
- [$issue4] (draft dan detail acara)
- [$issue5] (media dan konten pendukung)
- [$issue7] (entitlement pembayaran)

## Status

ready-for-agent
"@
$issue8 = New-GhIssue -Title "Publikasi dengan slug unik dan kuota atomik" -Body $body8

$body9 = @"
## What to build

Tamu dapat membaca undangan published melalui slug publik secara responsif dan mengirim ucapan tanpa membuat akun.

## Acceptance criteria

- [ ] Hanya undangan published disajikan melalui slug; draft dan data privat tidak dapat diakses publik.
- [ ] Tampilan responsif dari viewport 360 px hingga desktop tanpa scroll horizontal.
- [ ] Halaman menampilkan identitas pasangan, acara, lokasi, galeri, cerita, hadiah opsional, dan countdown.
- [ ] Tamu dapat mengirim nama dan pesan; panjang input divalidasi, rate limit dan sanitasi output diterapkan.
- [ ] Ucapan tampil pada Wall of Wishes dan pemilik dapat menyembunyikannya.
- [ ] Metadata berbagi tersedia dan halaman draft tidak diindeks.
- [ ] Cache halaman publik tidak mencampur data privat.

## Blocked by

- [$issue8] (publikasi dan resolusi slug)

## Status

ready-for-agent
"@
$issue9 = New-GhIssue -Title "Halaman undangan publik dan Wall of Wishes" -Body $body9

$body10 = @"
## What to build

Operator memiliki kontrol operasional minimum dan metrik untuk menjalankan pilot MVP serta mengukur sasaran 30 undangan published.

## Acceptance criteria

- [ ] Perubahan sensitif pada kategori, template, paket, dan hak akses tercatat dengan aktor, target, waktu, serta metadata relevan.
- [ ] Logging minimum tersedia untuk autentikasi, upload, checkout, webhook, publikasi, dan ucapan tanpa membocorkan secret.
- [ ] Backup PostgreSQL dan prosedur pemulihan dasar didokumentasikan.
- [ ] Kebijakan privasi, retensi/penghapusan data, serta minimisasi data tamu ditetapkan sebelum produksi.
- [ ] Jumlah undangan published dicatat untuk mengukur sasaran pilot 30 publikasi.
- [ ] Trial-to-paid dan waktu dari pendaftaran ke publikasi dicatat sebagai metrik validasi, tanpa target sebelum baseline pilot tersedia.
- [ ] Prosedur operasional minimum untuk penanganan insiden dan dukungan pilot didokumentasikan.

## Blocked by

- [$issue1] (autentikasi dan keamanan akun)
- [$issue2] (katalog dan administrasi template)
- [$issue3] (tema dan versioning)
- [$issue4] (draft dan detail acara)
- [$issue5] (media dan konten pendukung)
- [$issue6] (checkout)
- [$issue7] (verifikasi pembayaran dan entitlement)
- [$issue8] (publikasi)
- [$issue9] (halaman publik dan ucapan)

## Status

ready-for-agent
"@
$issue10 = New-GhIssue -Title "Kesiapan operasional dan pengukuran pilot MVP" -Body $body10

Write-Host ""
Write-Host "Semua 10 issue sudah tersedia:"
@($issue1, $issue2, $issue3, $issue4, $issue5, $issue6, $issue7, $issue8, $issue9, $issue10) |
  ForEach-Object { Write-Host " - $_" }
