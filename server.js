const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// In-Memory Database for Demo / Render Web Service
const users = [
  { id: 1, name: 'Akshay', email: 'akshay@example.com', password: 'password123' }
];

const transactions = [
  {
    id: 1,
    userId: 1,
    type: 'income',
    amount: 30000.0,
    category: 'Salary',
    paymentMethod: 'Bank Transfer',
    date: new Date(2026, 8, 26).toISOString(),
    description: 'Monthly Salary'
  },
  {
    id: 2,
    userId: 1,
    type: 'expense',
    amount: 500.0,
    category: 'Transport',
    paymentMethod: 'UPI',
    date: new Date(2026, 8, 27).toISOString(),
    description: 'Fuel refill'
  },
  {
    id: 3,
    userId: 1,
    type: 'expense',
    amount: 250.0,
    category: 'Food',
    paymentMethod: 'Cash',
    date: new Date(2026, 8, 28).toISOString(),
    description: 'Lunch'
  }
];

const budgets = [
  { id: 1, userId: 1, month: '2026-09', amount: 20000.0 }
];

// --- HEALTH CHECK ---
app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'SpendWise Backend API is running on Render!' });
});

// --- AUTH ENDPOINTS ---
app.post('/api/auth/register', (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const cleanEmail = email.trim().toLowerCase();
  const existing = users.find(u => u.email.toLowerCase() === cleanEmail);
  if (existing) {
    return res.status(400).json({ error: 'User with this email already exists' });
  }

  const newUser = { id: users.length + 1, name: name.trim(), email: cleanEmail, password: password.trim() };
  users.push(newUser);

  const { password: _, ...userWithoutPassword } = newUser;
  res.status(201).json({ user: userWithoutPassword, message: 'User registered successfully' });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' });
  }

  const cleanEmail = email.trim().toLowerCase();
  const user = users.find(u => u.email.toLowerCase() === cleanEmail);
  if (!user || user.password !== password.trim()) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }

  const { password: _, ...userWithoutPassword } = user;
  res.json({ user: userWithoutPassword, message: 'Login successful' });
});

// --- TRANSACTIONS ENDPOINTS ---
app.get('/api/transactions', (req, res) => {
  const userId = parseInt(req.query.userId);
  if (!userId) {
    return res.status(400).json({ error: 'userId parameter is required' });
  }

  const userTxs = transactions.filter(t => t.userId === userId);
  res.json(userTxs);
});

app.post('/api/transactions', (req, res) => {
  const { userId, type, amount, category, paymentMethod, date, description } = req.body;
  if (!userId || !type || !amount || !category) {
    return res.status(400).json({ error: 'Missing required transaction fields' });
  }

  const newTx = {
    id: Date.now(),
    userId: parseInt(userId),
    type,
    amount: parseFloat(amount),
    category,
    paymentMethod: paymentMethod || 'Cash',
    date: date || new Date().toISOString(),
    description: description || ''
  };

  transactions.unshift(newTx);
  res.status(201).json(newTx);
});

app.delete('/api/transactions/:id', (req, res) => {
  const txId = parseInt(req.params.id);
  const index = transactions.findIndex(t => t.id === txId);
  if (index === -1) {
    return res.status(404).json({ error: 'Transaction not found' });
  }

  transactions.splice(index, 1);
  res.json({ message: 'Transaction deleted' });
});

// --- BUDGET ENDPOINTS ---
app.get('/api/budget', (req, res) => {
  const { userId, month } = req.query;
  if (!userId || !month) {
    return res.status(400).json({ error: 'userId and month parameters are required' });
  }

  const budget = budgets.find(b => b.userId === parseInt(userId) && b.month === month);
  res.json(budget || { month, amount: 20000.0, userId: parseInt(userId) });
});

app.post('/api/budget', (req, res) => {
  const { userId, month, amount } = req.body;
  if (!userId || !month || !amount) {
    return res.status(400).json({ error: 'Missing required budget fields' });
  }

  const uId = parseInt(userId);
  const existingIndex = budgets.findIndex(b => b.userId === uId && b.month === month);
  const updatedBudget = { id: Date.now(), userId: uId, month, amount: parseFloat(amount) };

  if (existingIndex !== -1) {
    budgets[existingIndex] = updatedBudget;
  } else {
    budgets.push(updatedBudget);
  }

  res.json(updatedBudget);
});

app.listen(PORT, () => {
  console.log(`SpendWise Backend API running on port ${PORT}`);
});
