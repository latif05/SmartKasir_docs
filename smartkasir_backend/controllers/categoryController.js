// In-memory storage untuk demo (akan diganti dengan database di sprint berikutnya)
let categories = [
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

let nextId = 3;

// GET /categories - Mendapatkan semua kategori
const getCategories = (req, res) => {
  try {
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// GET /categories/:id - Mendapatkan kategori berdasarkan ID
const getCategoryById = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const category = categories.find(cat => cat.id === id);
    
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    res.json(category);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// POST /categories - Membuat kategori baru
const createCategory = (req, res) => {
  try {
    const { name, description } = req.body;
    
    // Validasi input
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Category name is required' });
    }
    
    // Cek apakah nama kategori sudah ada
    const existingCategory = categories.find(cat => 
      cat.name.toLowerCase() === name.toLowerCase()
    );
    
    if (existingCategory) {
      return res.status(400).json({ error: 'Category name already exists' });
    }
    
    const newCategory = {
      id: nextId++,
      name: name.trim(),
      description: description ? description.trim() : null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    categories.push(newCategory);
    res.status(201).json(newCategory);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// PUT /categories/:id - Mengupdate kategori
const updateCategory = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { name, description } = req.body;
    
    const categoryIndex = categories.findIndex(cat => cat.id === id);
    
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    // Validasi input
    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Category name is required' });
    }
    
    // Cek apakah nama kategori sudah ada (kecuali untuk kategori yang sedang diupdate)
    const existingCategory = categories.find(cat => 
      cat.id !== id && cat.name.toLowerCase() === name.toLowerCase()
    );
    
    if (existingCategory) {
      return res.status(400).json({ error: 'Category name already exists' });
    }
    
    const updatedCategory = {
      ...categories[categoryIndex],
      name: name.trim(),
      description: description ? description.trim() : null,
      updated_at: new Date().toISOString()
    };
    
    categories[categoryIndex] = updatedCategory;
    res.json(updatedCategory);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

// DELETE /categories/:id - Menghapus kategori
const deleteCategory = (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const categoryIndex = categories.findIndex(cat => cat.id === id);
    
    if (categoryIndex === -1) {
      return res.status(404).json({ error: 'Category not found' });
    }
    
    categories.splice(categoryIndex, 1);
    res.status(200).json({ message: 'Category deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory
};
