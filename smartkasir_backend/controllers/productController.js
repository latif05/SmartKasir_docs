// Import category controller untuk mendapatkan data kategori
const { getCategories } = require('./categoryController');

// In-memory storage untuk demo (akan diganti dengan database di sprint berikutnya)
let products = [
  {
    id: 1,
    category_id: 1,
    name: 'Teh Botol',
    cost_price: 5000,
    sell_price: 7000,
    stock: 12,
    created_at: '2024-01-01T00:00:00.000Z',
    updated_at: '2024-01-01T00:00:00.000Z'
  },
  {
    id: 2,
    category_id: 2,
    name: 'Roti Tawar',
    cost_price: 10000,
    sell_price: 12000,
    stock: 8,
    created_at: '2024-01-01T00:00:00.000Z',
    updated_at: '2024-01-01T00:00:00.000Z'
  },
  {
    id: 3,
    category_id: 1,
    name: 'Kopi Sachet',
    cost_price: 5000,
    sell_price: 7000,
    stock: 20,
    created_at: '2024-01-01T00:00:00.000Z',
    updated_at: '2024-01-01T00:00:00.000Z'
  }
];

let nextProductId = 4;

// Helper function untuk mendapatkan kategori
const getCategoryById = async (categoryId) => {
  try {
    // Simulasi async untuk mendapatkan categories
    const categories = [
      {
        id: 1,
        name: 'Minuman',
        description: 'Produk minuman kemasan dan sachet',
        created_at: '2024-01-01T00:00:00.000Z',
        updated_at: '2024-01-01T00:00:00.000Z'
      },
      {
        id: 2,
        name: 'Makanan',
        description: 'Produk makanan siap saji dan roti',
        created_at: '2024-01-01T00:00:00.000Z',
        updated_at: '2024-01-01T00:00:00.000Z'
      }
    ];
    
    return categories.find(cat => cat.id === categoryId);
  } catch (error) {
    return null;
  }
};

// Helper function untuk menambahkan category info ke product
const enrichProductWithCategory = async (product) => {
  if (product.category_id) {
    const category = await getCategoryById(product.category_id);
    return { ...product, category };
  }
  return product;
};

// GET /products - Mendapatkan semua produk
const getProducts = async (req, res) => {
  try {
    // Enrich semua products dengan category info
    const enrichedProducts = await Promise.all(
      products.map(product => enrichProductWithCategory(product))
    );
    res.json(enrichedProducts);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// GET /products/:id - Mendapatkan produk berdasarkan ID
const getProductById = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const product = products.find(p => p.id === id);
    
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    const enrichedProduct = await enrichProductWithCategory(product);
    res.json(enrichedProduct);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST /products - Membuat produk baru
const createProduct = async (req, res) => {
  try {
    const { category_id, name, cost_price, sell_price, stock } = req.body;
    
    // Validasi input
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Product name is required' });
    }
    
    if (!sell_price || sell_price <= 0) {
      return res.status(400).json({ error: 'Sell price must be greater than 0' });
    }
    
    // Validasi category_id jika disediakan
    if (category_id) {
      const category = await getCategoryById(category_id);
      if (!category) {
        return res.status(400).json({ error: 'Invalid category_id' });
      }
    }
    
    // Cek apakah nama produk sudah ada
    const existingProduct = products.find(p => 
      p.name.toLowerCase() === name.toLowerCase()
    );
    
    if (existingProduct) {
      return res.status(400).json({ error: 'Product name already exists' });
    }
    
    const newProduct = {
      id: nextProductId++,
      category_id: category_id || null,
      name: name.trim(),
      cost_price: cost_price || null,
      sell_price: sell_price,
      stock: stock || 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    products.push(newProduct);
    const enrichedProduct = await enrichProductWithCategory(newProduct);
    res.status(201).json(enrichedProduct);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// PUT /products/:id - Mengupdate produk
const updateProduct = async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { category_id, name, cost_price, sell_price, stock } = req.body;
    
    const productIndex = products.findIndex(p => p.id === id);
    
    if (productIndex === -1) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    // Validasi input
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Product name is required' });
    }
    
    if (!sell_price || sell_price <= 0) {
      return res.status(400).json({ error: 'Sell price must be greater than 0' });
    }
    
    // Validasi category_id jika disediakan
    if (category_id) {
      const category = await getCategoryById(category_id);
      if (!category) {
        return res.status(400).json({ error: 'Invalid category_id' });
      }
    }
    
    // Cek apakah nama produk sudah ada (kecuali untuk produk yang sedang diupdate)
    const existingProduct = products.find(p => 
      p.id !== id && p.name.toLowerCase() === name.toLowerCase()
    );
    
    if (existingProduct) {
      return res.status(400).json({ error: 'Product name already exists' });
    }
    
    const updatedProduct = {
      ...products[productIndex],
      category_id: category_id !== undefined ? category_id : products[productIndex].category_id,
      name: name.trim(),
      cost_price: cost_price !== undefined ? cost_price : products[productIndex].cost_price,
      sell_price: sell_price,
      stock: stock !== undefined ? stock : products[productIndex].stock,
      updated_at: new Date().toISOString()
    };
    
    products[productIndex] = updatedProduct;
    const enrichedProduct = await enrichProductWithCategory(updatedProduct);
    res.json(enrichedProduct);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// DELETE /products/:id - Menghapus produk
const deleteProduct = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const productIndex = products.findIndex(p => p.id === id);
    
    if (productIndex === -1) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    products.splice(productIndex, 1);
    res.status(200).json({ message: 'Product deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  // Internal accessor for reports (demo/in-memory only)
  __getAllProducts: () => products
};
