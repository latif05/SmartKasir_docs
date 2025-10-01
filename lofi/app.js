// File ini tidak diperlukan lagi untuk SPA. Semua halaman sudah dipisah menjadi file HTML terpisah.

function loadPage(hash) {
  const page = hash.replace('#', '') || 'dashboard';
  document.getElementById('app').innerHTML = pages[page] || pages.dashboard;
  if (page === 'dashboard') {
    renderDashboardData();
  }
}

window.addEventListener('hashchange', () => loadPage(location.hash));
window.addEventListener('DOMContentLoaded', () => loadPage(location.hash));

// Dummy form popups (lofi)
function showProductForm() {
  document.getElementById('app').innerHTML = `
    <h2 class='section-title'>Tambah Produk</h2>
    <form>
      <input type='text' placeholder='Nama Produk' required />
      <input type='number' placeholder='Harga Beli' required />
      <input type='number' placeholder='Harga Jual' required />
      <input type='number' placeholder='Stok Awal' required />
      <input type='text' placeholder='Barcode' />
      <select><option>Kategori</option></select>
      <button class='button' type='submit'>Simpan</button>
    </form>
    <button class='button' onclick='loadPage("#products")'>Kembali</button>
  `;
}
function showCategoryForm() {
  document.getElementById('app').innerHTML = `
    <h2 class='section-title'>Tambah Kategori</h2>
    <form>
      <input type='text' placeholder='Nama Kategori' required />
      <input type='text' placeholder='Deskripsi' />
      <button class='button' type='submit'>Simpan</button>
    </form>
    <button class='button' onclick='loadPage("#categories")'>Kembali</button>
  `;
}
function showTransactionForm() {
  document.getElementById('app').innerHTML = `
    <h2 class='section-title'>Transaksi Baru</h2>
    <form>
      <input type='text' placeholder='Nama Produk / Barcode' required />
      <input type='number' placeholder='Kuantitas' required />
      <input type='number' placeholder='Diskon (opsional)' />
      <button class='button' type='submit'>Tambah Item</button>
    </form>
    <button class='button' onclick='loadPage("#transactions")'>Kembali</button>
  `;
}

// Dummy dashboard data renderer
function renderDashboardData() {
  // Dummy data, bisa diintegrasikan dengan backend/database
  document.getElementById('sales-today').textContent = 'Rp 1.250.000';
  document.getElementById('products-count').textContent = '24';
  document.getElementById('transactions-today').textContent = '17';
  document.getElementById('recent-transactions').innerHTML = `
    <tr><td>09:10</td><td>Teh Botol x2</td><td>Rp 14.000</td></tr>
    <tr><td>09:25</td><td>Roti Tawar x1</td><td>Rp 12.000</td></tr>
    <tr><td>10:02</td><td>Kopi Sachet x3</td><td>Rp 21.000</td></tr>
    <tr><td>10:15</td><td>Indomie Goreng x5</td><td>Rp 50.000</td></tr>
  `;
}
