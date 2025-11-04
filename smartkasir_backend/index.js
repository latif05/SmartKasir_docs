const express = require('express');
const cors = require('cors');

const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());

// demo user store (in-memory)
const users = [
  { id: 1, username: 'admin', passwordHash: bcrypt.hashSync('admin123', 8) }
];

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-key';

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Import routes
const categoryRoutes = require('./routes/categoryRoutes');
const productRoutes = require('./routes/productRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const reportRoutes = require('./routes/reportRoutes');

// Use routes
app.use('/categories', categoryRoutes);
app.use('/products', productRoutes);
app.use('/transactions', transactionRoutes);
app.use('/reports', reportRoutes);

// Auth route (login)
app.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username);
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });
  const valid = bcrypt.compareSync(password, user.passwordHash);
  if (!valid) return res.status(401).json({ error: 'Invalid credentials' });

  const token = jwt.sign({ sub: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });
  res.json({ token });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`SmartKasir backend listening on ${port}`));
