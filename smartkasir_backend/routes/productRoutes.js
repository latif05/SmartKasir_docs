const express = require('express');
const router = express.Router();
const {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct
} = require('../controllers/productController');

// GET /products - Mendapatkan semua produk
router.get('/', getProducts);

// GET /products/:id - Mendapatkan produk berdasarkan ID
router.get('/:id', getProductById);

// POST /products - Membuat produk baru
router.post('/', createProduct);

// PUT /products/:id - Mengupdate produk
router.put('/:id', updateProduct);

// DELETE /products/:id - Menghapus produk
router.delete('/:id', deleteProduct);

module.exports = router;
