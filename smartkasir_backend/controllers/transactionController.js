// In-memory storage untuk demo (akan diganti dengan database di sprint berikutnya)
let transactions = [
  {
    id: 1,
    date: '2024-01-15T09:10:00.000Z',
    total: 14000,
    discount: 0,
    final_amount: 14000,
    payment_method: 'tunai',
    status: 'completed',
    created_at: '2024-01-15T09:10:00.000Z',
    items: [
      {
        id: 1,
        transaction_id: 1,
        product_id: 1,
        qty: 2,
        sell_price: 7000,
        subtotal: 14000,
        product: {
          id: 1,
          name: 'Teh Botol',
          category_id: 1
        }
      }
    ]
  },
  {
    id: 2,
    date: '2024-01-15T09:25:00.000Z',
    total: 12000,
    discount: 0,
    final_amount: 12000,
    payment_method: 'tunai',
    status: 'completed',
    created_at: '2024-01-15T09:25:00.000Z',
    items: [
      {
        id: 2,
        transaction_id: 2,
        product_id: 2,
        qty: 1,
        sell_price: 12000,
        subtotal: 12000,
        product: {
          id: 2,
          name: 'Roti Tawar',
          category_id: 2
        }
      }
    ]
  },
  {
    id: 3,
    date: '2024-01-15T10:02:00.000Z',
    total: 21000,
    discount: 0,
    final_amount: 21000,
    payment_method: 'tunai',
    status: 'completed',
    created_at: '2024-01-15T10:02:00.000Z',
    items: [
      {
        id: 3,
        transaction_id: 3,
        product_id: 3,
        qty: 3,
        sell_price: 7000,
        subtotal: 21000,
        product: {
          id: 3,
          name: 'Kopi Sachet',
          category_id: 1
        }
      }
    ]
  }
];

let nextTransactionId = 4;
let nextTransactionItemId = 4;

// Helper untuk mendapatkan produk (dari product controller)
const getProductById = async (productId) => {
  try {
    // Simulasi untuk mendapatkan product dari product controller
    const products = [
      {
        id: 1,
        category_id: 1,
        name: 'Teh Botol',
        cost_price: 5000,
        sell_price: 7000,
        stock: 12
      },
      {
        id: 2,
        category_id: 2,
        name: 'Roti Tawar',
        cost_price: 10000,
        sell_price: 12000,
        stock: 8
      },
      {
        id: 3,
        category_id: 1,
        name: 'Kopi Sachet',
        cost_price: 5000,
        sell_price: 7000,
        stock: 20
      }
    ];
    
    return products.find(p => p.id === productId);
  } catch (error) {
    return null;
  }
};

// Helper untuk update stock produk
// Note: Untuk production, ini harus diintegrasikan dengan product controller atau database
const updateProductStock = async (productId, qty) => {
  try {
    // Import products dari productController
    const productController = require('./productController');
    // Access products array (akan diubah untuk production dengan database)
    // Untuk sekarang hanya log, karena products array tidak shared
    console.log(`Updating stock for product ${productId}, reducing ${qty}`);
    // TODO: Implementasi update stock yang sebenarnya dengan database
    return true;
  } catch (error) {
    console.error('Error updating stock:', error);
    return false;
  }
};

// GET /transactions - Mendapatkan semua transaksi
const getTransactions = (req, res) => {
  try {
    // Sort berdasarkan tanggal terbaru
    const sortedTransactions = [...transactions].sort((a, b) => 
      new Date(b.date) - new Date(a.date)
    );
    res.json(sortedTransactions);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// GET /transactions/:id - Mendapatkan transaksi berdasarkan ID
const getTransactionById = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const transaction = transactions.find(t => t.id === id);
    
    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    
    res.json(transaction);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST /transactions - Membuat transaksi baru
const createTransaction = async (req, res) => {
  try {
    const { date, total, discount, final_amount, payment_method, status, items } = req.body;
    
    // Validasi input
    if (!date) {
      return res.status(400).json({ error: 'Transaction date is required' });
    }
    
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'Transaction must have at least one item' });
    }
    
    if (total <= 0) {
      return res.status(400).json({ error: 'Total must be greater than 0' });
    }
    
    // Validasi items
    for (const item of items) {
      if (!item.product_id || !item.qty || !item.sell_price) {
        return res.status(400).json({ error: 'Each item must have product_id, qty, and sell_price' });
      }
      
      // Validasi stock produk
      const product = await getProductById(item.product_id);
      if (!product) {
        return res.status(400).json({ error: `Product with id ${item.product_id} not found` });
      }
      
      if (product.stock < item.qty) {
        return res.status(400).json({ 
          error: `Insufficient stock for ${product.name}. Available: ${product.stock}, Requested: ${item.qty}` 
        });
      }
    }
    
    // Membuat transaction items dengan ID
    const transactionItems = items.map((item, index) => ({
      id: nextTransactionItemId++,
      transaction_id: nextTransactionId,
      product_id: item.product_id,
      qty: item.qty,
      sell_price: item.sell_price,
      subtotal: item.qty * item.sell_price,
      product: null // Will be populated if needed
    }));
    
    // Update stock untuk setiap produk
    for (const item of items) {
      await updateProductStock(item.product_id, item.qty);
    }
    
    const newTransaction = {
      id: nextTransactionId++,
      date: date || new Date().toISOString(),
      total: total,
      discount: discount || 0,
      final_amount: final_amount || total,
      payment_method: payment_method || 'tunai',
      status: status || 'completed',
      created_at: new Date().toISOString(),
      items: transactionItems
    };
    
    transactions.push(newTransaction);
    res.status(201).json(newTransaction);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error', details: error.message });
  }
};

module.exports = {
  getTransactions,
  getTransactionById,
  createTransaction,
  // Internal accessor for reports (demo/in-memory only)
  __getAllTransactions: () => transactions
};
