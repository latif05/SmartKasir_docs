const express = require('express');
const router = express.Router();
const {
  getTransactions,
  getTransactionById,
  createTransaction
} = require('../controllers/transactionController');

// GET /transactions - Mendapatkan semua transaksi
router.get('/', getTransactions);

// GET /transactions/:id - Mendapatkan transaksi berdasarkan ID
router.get('/:id', getTransactionById);

// POST /transactions - Membuat transaksi baru
router.post('/', createTransaction);

module.exports = router;
