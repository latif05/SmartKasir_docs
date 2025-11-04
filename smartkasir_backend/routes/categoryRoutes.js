const express = require('express');
const router = express.Router();
const {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory
} = require('../controllers/categoryController');

// GET /categories - Mendapatkan semua kategori
router.get('/', getCategories);

// GET /categories/:id - Mendapatkan kategori berdasarkan ID
router.get('/:id', getCategoryById);

// POST /categories - Membuat kategori baru
router.post('/', createCategory);

// PUT /categories/:id - Mengupdate kategori
router.put('/:id', updateCategory);

// DELETE /categories/:id - Menghapus kategori
router.delete('/:id', deleteCategory);

module.exports = router;

