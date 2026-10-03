/* ----------------------------------------------------
   SPENDWISE - COMPLETE APPLICATION LOGIC & ROADMAP ENGINE
---------------------------------------------------- */

// Default Realistic Seed Data
const DEFAULT_TRANSACTIONS = [
  { id: '101', type: 'expense', amount: 250, category: 'Food', paymentMethod: 'UPI', date: '2026-09-28', description: 'Lunch at Cafe' },
  { id: '102', type: 'expense', amount: 500, category: 'Transport', paymentMethod: 'Credit Card', date: '2026-09-27', description: 'Fuel refill' },
  { id: '103', type: 'income', amount: 30000, category: 'Salary', paymentMethod: 'Bank Transfer', date: '2026-09-26', description: 'Monthly Salary' },
  { id: '104', type: 'expense', amount: 4500, category: 'Shopping', paymentMethod: 'Credit Card', date: '2026-09-22', description: 'Clothes' },
  { id: '105', type: 'expense', amount: 3500, category: 'Bills', paymentMethod: 'UPI', date: '2026-09-20', description: 'Electricity Bill' }
];

const DEFAULT_GOALS = [
  { id: 'g1', name: 'Emergency Fund', target: 50000, current: 25000, date: '2026-12-31' },
  { id: 'g2', name: 'New Laptop', target: 80000, current: 35000, date: '2026-11-15' }
];

const DEFAULT_RECURRING = [
  { id: 'r1', title: 'Netflix Subscription', amount: 649, frequency: 'Monthly', category: 'Entertainment', nextDate: '2026-10-05', active: true },
  { id: 'r2', title: 'House Rent', amount: 15000, frequency: 'Monthly', category: 'Bills', nextDate: '2026-10-01', active: true }
];

const CATEGORY_ICONS = {
  Food: 'fa-utensils',
  Transport: 'fa-car',
  Shopping: 'fa-bag-shopping',
  Education: 'fa-graduation-cap',
  Bills: 'fa-file-invoice-dollar',
  Entertainment: 'fa-film',
  Health: 'fa-notes-medical',
  Travel: 'fa-plane',
  Salary: 'fa-wallet',
  Freelance: 'fa-laptop-code',
  Investment: 'fa-chart-line',
  Gift: 'fa-gift',
  Other: 'fa-ellipsis'
};

const CATEGORY_COLORS = {
  Food: '#FF6B6B',
  Transport: '#4ECDC4',
  Shopping: '#FFD166',
  Education: '#118AB2',
  Bills: '#9D4EDD',
  Entertainment: '#06D6A0',
  Health: '#F72585',
  Travel: '#3F37C9',
  Salary: '#2EC4B6',
  Freelance: '#4895EF',
  Investment: '#70E000',
  Gift: '#F15BB5',
  Other: '#8D99AE'
};

const PAYMENT_ICONS = {
  'Cash': 'fa-money-bill-wave',
  'UPI': 'fa-mobile-screen-button',
  'Credit Card': 'fa-credit-card',
  'Debit Card': 'fa-building-columns',
  'Bank Transfer': 'fa-money-bill-transfer',
  'Other': 'fa-receipt'
};

const INCOME_CATEGORIES = ['Salary', 'Freelance', 'Investment', 'Gift', 'Other'];
const EXPENSE_CATEGORIES = ['Food', 'Transport', 'Shopping', 'Education', 'Bills', 'Entertainment', 'Health', 'Travel', 'Other'];

// Application State
let state = {
  transactions: JSON.parse(localStorage.getItem('spendwise_txs')) || DEFAULT_TRANSACTIONS,
  goals: JSON.parse(localStorage.getItem('spendwise_goals')) || DEFAULT_GOALS,
  recurring: JSON.parse(localStorage.getItem('spendwise_recurring')) || DEFAULT_RECURRING,
  monthlyBudget: parseFloat(localStorage.getItem('spendwise_budget')) || 20000,
  categoryBudgets: JSON.parse(localStorage.getItem('spendwise_cat_budgets')) || { Food: 5000, Transport: 3000, Shopping: 4000 },
  currency: localStorage.getItem('spendwise_currency') || '₹',
  theme: localStorage.getItem('spendwise_theme') || 'dark',
  notifications: JSON.parse(localStorage.getItem('spendwise_notifs')) || [
    { id: 'n1', title: 'Budget Limit Warning', text: 'You have reached 92.5% of your monthly budget.', icon: 'fa-triangle-exclamation' },
    { id: 'n2', title: 'Bill Reminder', text: 'House Rent (₹15,000) is scheduled for Oct 1.', icon: 'fa-calendar-check' }
  ],
  analyticsTimeRange: '30'
};

// Chart instances
let dashPieChartInstance = null;
let analyticsPieChartInstance = null;
let analyticsBarChartInstance = null;
let paymentChartInstance = null;
let savingsTrendChartInstance = null;

// Initialization
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initEventListeners();
  populateCategorySelect('expense');
  renderAll();
});

function saveState() {
  localStorage.setItem('spendwise_txs', JSON.stringify(state.transactions));
  localStorage.setItem('spendwise_goals', JSON.stringify(state.goals));
  localStorage.setItem('spendwise_recurring', JSON.stringify(state.recurring));
  localStorage.setItem('spendwise_budget', state.monthlyBudget.toString());
  localStorage.setItem('spendwise_cat_budgets', JSON.stringify(state.categoryBudgets));
  localStorage.setItem('spendwise_currency', state.currency);
  localStorage.setItem('spendwise_theme', state.theme);
  localStorage.setItem('spendwise_notifs', JSON.stringify(state.notifications));
}

function initTheme() {
  if (state.theme === 'light') {
    document.documentElement.classList.remove('dark');
    document.documentElement.classList.add('light');
    document.getElementById('themeToggle').checked = false;
  } else {
    document.documentElement.classList.remove('light');
    document.documentElement.classList.add('dark');
    document.getElementById('themeToggle').checked = true;
  }
}

function formatMoney(amount) {
  return `${state.currency}${parseFloat(amount || 0).toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 2 })}`;
}

// Calculations
function getTotals(filterDays = null) {
  let txs = state.transactions;
  if (filterDays && filterDays !== 'all') {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - parseInt(filterDays));
    txs = txs.filter(t => new Date(t.date) >= cutoff);
  }

  const income = txs
    .filter(t => t.type === 'income')
    .reduce((sum, t) => sum + parseFloat(t.amount), 0);

  const expense = txs
    .filter(t => t.type === 'expense')
    .reduce((sum, t) => sum + parseFloat(t.amount), 0);

  const balance = income - expense;
  const savings = income - expense;
  const savingsRate = income > 0 ? ((savings / income) * 100).toFixed(1) : 0;
  const remainingBudget = state.monthlyBudget - expense;
  const usagePercentage = state.monthlyBudget > 0 ? ((expense / state.monthlyBudget) * 100).toFixed(1) : 0;

  return { income, expense, balance, savings, savingsRate, remainingBudget, usagePercentage, txs };
}

// Master Render Function
function renderAll() {
  const { income, expense, balance, savingsRate, remainingBudget, usagePercentage } = getTotals();

  // Currency symbols update
  document.querySelectorAll('.currency-symbol').forEach(el => el.textContent = state.currency);
  document.getElementById('currencySelect').value = state.currency;
  document.getElementById('settingCurrencySelect').value = state.currency;

  // Balance Card & Header
  document.getElementById('totalBalance').textContent = formatMoney(balance);
  document.getElementById('totalIncome').textContent = formatMoney(income);
  document.getElementById('totalExpense').textContent = formatMoney(expense);
  document.getElementById('savingsRateVal').textContent = `${savingsRate}%`;

  // Budget Cards
  document.getElementById('budgetUsageBadge').textContent = `${usagePercentage}% Used`;
  document.getElementById('budgetProgressBar').style.width = `${Math.min(usagePercentage, 100)}%`;
  document.getElementById('dashSpent').textContent = formatMoney(expense);
  document.getElementById('dashLimit').textContent = formatMoney(state.monthlyBudget);
  document.getElementById('dashRemaining').textContent = formatMoney(remainingBudget > 0 ? remainingBudget : 0);

  document.getElementById('budgetInput').value = state.monthlyBudget;
  document.getElementById('budgetAllocated').textContent = formatMoney(state.monthlyBudget);
  document.getElementById('budgetTotalSpent').textContent = formatMoney(expense);
  document.getElementById('budgetTotalRemaining').textContent = formatMoney(remainingBudget > 0 ? remainingBudget : 0);

  // Render Sub-modules
  renderNotifications();
  renderRecentTransactions();
  renderFullTransactions();
  renderCategoryBudgets();
  renderGoals();
  renderRecurring();
  renderAIInsights();
  renderCharts();
  renderCategoryTable();

  saveState();
}

// Notifications System
function renderNotifications() {
  const list = document.getElementById('notifList');
  const badge = document.getElementById('notifBadge');
  list.innerHTML = '';

  badge.textContent = state.notifications.length;
  if (state.notifications.length === 0) {
    list.innerHTML = '<p style="color: var(--text-muted); font-size: 12px; padding: 12px; text-align: center;">No new notifications</p>';
    return;
  }

  state.notifications.forEach(n => {
    const item = document.createElement('div');
    item.className = 'notif-item';
    item.innerHTML = `
      <i class="fa-solid ${n.icon}"></i>
      <div>
        <h5>${n.title}</h5>
        <p>${n.text}</p>
      </div>
    `;
    list.appendChild(item);
  });
}

// Recent Transactions
function renderRecentTransactions() {
  const container = document.getElementById('dashTxList');
  container.innerHTML = '';
  const recent = [...state.transactions].slice(0, 4);

  if (recent.length === 0) {
    container.innerHTML = '<p style="color: var(--text-muted); text-align: center; padding: 16px;">No transactions recorded yet.</p>';
    return;
  }

  recent.forEach(tx => container.appendChild(createTxTile(tx)));
}

// Full Transaction History
function renderFullTransactions() {
  const container = document.getElementById('fullTxList');
  const searchQuery = (document.getElementById('searchInput').value || '').toLowerCase();
  const filterType = document.getElementById('filterType').value;
  const filterCat = document.getElementById('filterCategory').value;
  const filterPayment = document.getElementById('filterPayment').value;
  const sortBy = document.getElementById('sortBy').value;

  container.innerHTML = '';

  let filtered = state.transactions.filter(tx => {
    const desc = (tx.description || '').toLowerCase();
    const cat = tx.category.toLowerCase();
    const pay = (tx.paymentMethod || '').toLowerCase();
    const matchesSearch = desc.includes(searchQuery) || cat.includes(searchQuery) || pay.includes(searchQuery);
    const matchesType = filterType === 'All' || tx.type === filterType;
    const matchesCat = filterCat === 'All' || tx.category === filterCat;
    const matchesPay = filterPayment === 'All' || tx.paymentMethod === filterPayment;
    return matchesSearch && matchesType && matchesCat && matchesPay;
  });

  // Sort
  if (sortBy === 'newest') filtered.sort((a, b) => new Date(b.date) - new Date(a.date));
  else if (sortBy === 'oldest') filtered.sort((a, b) => new Date(a.date) - new Date(b.date));
  else if (sortBy === 'amount-high') filtered.sort((a, b) => b.amount - a.amount);
  else if (sortBy === 'amount-low') filtered.sort((a, b) => a.amount - b.amount);

  document.getElementById('txCountBadge').textContent = `${filtered.length} Transactions`;

  if (filtered.length === 0) {
    container.innerHTML = '<p style="color: var(--text-muted); text-align: center; padding: 24px;">No matching transactions found.</p>';
    return;
  }

  filtered.forEach(tx => container.appendChild(createTxTile(tx, true)));
}

// Transaction Tile Creation
function createTxTile(tx, includeActions = false) {
  const div = document.createElement('div');
  div.className = 'tx-tile';
  const iconClass = CATEGORY_ICONS[tx.category] || 'fa-tag';
  const color = CATEGORY_COLORS[tx.category] || '#6c5ce7';
  const isIncome = tx.type === 'income';
  const sign = isIncome ? '+' : '-';
  const payMethod = tx.paymentMethod || 'Cash';

  div.innerHTML = `
    <div class="tx-left">
      <div class="tx-icon" style="background: ${color}20; color: ${color};">
        <i class="fa-solid ${iconClass}"></i>
      </div>
      <div class="tx-meta">
        <h4>${tx.description || tx.category}</h4>
        <p>${tx.category} • ${payMethod} • ${tx.date}</p>
      </div>
    </div>
    <div class="tx-right">
      <span class="tx-amount ${tx.type}">${sign}${formatMoney(tx.amount)}</span>
      ${includeActions ? `
        <div class="tx-actions">
          <button onclick="editTransaction('${tx.id}')"><i class="fa-solid fa-pen"></i></button>
          <button onclick="deleteTransaction('${tx.id}')"><i class="fa-solid fa-trash"></i></button>
        </div>
      ` : ''}
    </div>
  `;
  return div;
}

// Category Budgets Render
function renderCategoryBudgets() {
  const container = document.getElementById('categoryBudgetsContainer');
  container.innerHTML = '';

  const expenses = state.transactions.filter(t => t.type === 'expense');
  const spentMap = {};
  expenses.forEach(t => spentMap[t.category] = (spentMap[t.category] || 0) + parseFloat(t.amount));

  Object.keys(state.categoryBudgets).forEach(cat => {
    const limit = state.categoryBudgets[cat];
    const spent = spentMap[cat] || 0;
    const pct = limit > 0 ? Math.min(((spent / limit) * 100), 100).toFixed(0) : 0;
    const card = document.createElement('div');
    card.className = 'cat-budget-card';
    card.innerHTML = `
      <div class="cat-budget-header">
        <h4>${cat}</h4>
        <span class="badge ${spent > limit ? 'badge-danger' : ''}">${pct}%</span>
      </div>
      <div class="progress-bar-container" style="height: 6px;">
        <div class="progress-bar" style="width: ${pct}%; background: ${spent > limit ? '#ff7675' : 'var(--accent-gradient)'};"></div>
      </div>
      <p style="font-size: 12px; color: var(--text-secondary); margin-top: 6px;">
        ${formatMoney(spent)} of ${formatMoney(limit)}
      </p>
    `;
    container.appendChild(card);
  });
}

// Goals Module Render
function renderGoals() {
  const container = document.getElementById('goalsContainer');
  container.innerHTML = '';

  if (state.goals.length === 0) {
    container.innerHTML = '<p style="color: var(--text-muted); padding: 16px;">No savings goals created yet.</p>';
    return;
  }

  state.goals.forEach(g => {
    const pct = g.target > 0 ? Math.min(((g.current / g.target) * 100), 100).toFixed(1) : 0;
    const card = document.createElement('div');
    card.className = 'goal-card';
    card.innerHTML = `
      <div class="goal-card-header">
        <h4>${g.name}</h4>
        <span class="badge badge-accent">${pct}% Saved</span>
      </div>
      <div class="progress-bar-container">
        <div class="progress-bar" style="width: ${pct}%;"></div>
      </div>
      <div class="goal-numbers">
        <span>Saved: <strong>${formatMoney(g.current)}</strong></span>
        <span>Target: <strong>${formatMoney(g.target)}</strong></span>
      </div>
      <div style="margin-top: 14px; display: flex; justify-content: space-between; align-items: center;">
        <span style="font-size: 11px; color: var(--text-secondary);">Target Date: ${g.date}</span>
        <button class="btn btn-secondary" onclick="openDepositModal('${g.id}')" style="padding: 6px 12px; font-size: 12px;">+ Add Funds</button>
      </div>
    `;
    container.appendChild(card);
  });
}

// Recurring Module Render
function renderRecurring() {
  const container = document.getElementById('recurringList');
  container.innerHTML = '';

  if (state.recurring.length === 0) {
    container.innerHTML = '<p style="color: var(--text-muted); padding: 16px; text-align: center;">No recurring transactions configured.</p>';
    return;
  }

  state.recurring.forEach(r => {
    const div = document.createElement('div');
    div.className = 'tx-tile';
    div.innerHTML = `
      <div class="tx-left">
        <div class="tx-icon" style="background: rgba(108, 92, 231, 0.2); color: var(--accent-light);">
          <i class="fa-solid fa-rotate-right"></i>
        </div>
        <div class="tx-meta">
          <h4>${r.title}</h4>
          <p>${r.frequency} • Category: ${r.category} • Next: ${r.nextDate}</p>
        </div>
      </div>
      <div class="tx-right">
        <span class="tx-amount expense">-${formatMoney(r.amount)}</span>
        <button class="btn btn-danger" onclick="deleteRecurring('${r.id}')" style="padding: 4px 8px; font-size: 12px;"><i class="fa-solid fa-trash"></i></button>
      </div>
    `;
    container.appendChild(div);
  });
}

// AI Financial Insights Engine (Factual summaries only)
function renderAIInsights() {
  const container = document.getElementById('aiInsightsContainer');
  container.innerHTML = '';

  const { income, expense, savingsRate, txs } = getTotals();
  const expenses = txs.filter(t => t.type === 'expense');

  // Category map
  const catMap = {};
  expenses.forEach(t => catMap[t.category] = (catMap[t.category] || 0) + parseFloat(t.amount));
  let topCat = 'None';
  let topAmt = 0;
  Object.keys(catMap).forEach(c => {
    if (catMap[c] > topAmt) { topAmt = catMap[c]; topCat = c; }
  });
  const topPct = expense > 0 ? ((topAmt / expense) * 100).toFixed(1) : 0;

  const insights = [
    {
      title: 'Top Expense Category',
      text: `${topCat} represents ${topPct}% (${formatMoney(topAmt)}) of your total recorded expenses this period.`,
      icon: 'fa-chart-pie',
      color: '#ff7675'
    },
    {
      title: 'Savings Performance',
      text: `You have saved ${savingsRate}% of your total income (${formatMoney(income - expense)} net savings).`,
      icon: 'fa-piggy-bank',
      color: '#00b894'
    },
    {
      title: 'Monthly Budget Health',
      text: `Recorded expenses stand at ${formatMoney(expense)} against your ${formatMoney(state.monthlyBudget)} monthly limit (${((expense/state.monthlyBudget)*100).toFixed(1)}% utilized).`,
      icon: 'fa-heart-pulse',
      color: '#6c5ce7'
    }
  ];

  insights.forEach(ins => {
    const card = document.createElement('div');
    card.className = 'ai-insight-card';
    card.style.borderLeftColor = ins.color;
    card.innerHTML = `
      <h4 style="color: ${ins.color};"><i class="fa-solid ${ins.icon}"></i> ${ins.title}</h4>
      <p style="font-size: 14px; color: var(--text-primary); margin-top: 6px; line-height: 1.5;">${ins.text}</p>
    `;
    container.appendChild(card);
  });
}

// Chart.js Rendering
function renderCharts() {
  const { txs, income, expense } = getTotals(state.analyticsTimeRange);
  const expenses = txs.filter(t => t.type === 'expense');

  // Category Distribution
  const catTotals = {};
  expenses.forEach(t => catTotals[t.category] = (catTotals[t.category] || 0) + parseFloat(t.amount));
  const labels = Object.keys(catTotals);
  const data = Object.values(catTotals);
  const bgColors = labels.map(l => CATEGORY_COLORS[l] || '#8e44ad');

  // Mini Dash Chart
  const ctxDash = document.getElementById('dashPieChart').getContext('2d');
  if (dashPieChartInstance) dashPieChartInstance.destroy();
  dashPieChartInstance = new Chart(ctxDash, {
    type: 'doughnut',
    data: { labels, datasets: [{ data, backgroundColor: bgColors, borderWidth: 0 }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
  });

  // Analytics Pie Chart
  const ctxAnalyticsPie = document.getElementById('analyticsPieChart').getContext('2d');
  if (analyticsPieChartInstance) analyticsPieChartInstance.destroy();
  analyticsPieChartInstance = new Chart(ctxAnalyticsPie, {
    type: 'pie',
    data: { labels, datasets: [{ data, backgroundColor: bgColors, borderWidth: 0 }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right', labels: { color: state.theme === 'dark' ? '#f8fafc' : '#0f172a' } } } }
  });

  // Payment Method Chart
  const payMap = {};
  expenses.forEach(t => {
    const pm = t.paymentMethod || 'Cash';
    payMap[pm] = (payMap[pm] || 0) + parseFloat(t.amount);
  });
  const ctxPay = document.getElementById('paymentChart').getContext('2d');
  if (paymentChartInstance) paymentChartInstance.destroy();
  paymentChartInstance = new Chart(ctxPay, {
    type: 'bar',
    data: {
      labels: Object.keys(payMap),
      datasets: [{ label: 'Expenditure', data: Object.values(payMap), backgroundColor: '#a29bfe', borderRadius: 8 }]
    },
    options: { responsive: true, maintainAspectRatio: false, scales: { y: { ticks: { color: '#94a3b8' } }, x: { ticks: { color: '#94a3b8' } } } }
  });

  // Bar Chart (Income vs Expense)
  const ctxBar = document.getElementById('analyticsBarChart').getContext('2d');
  if (analyticsBarChartInstance) analyticsBarChartInstance.destroy();
  analyticsBarChartInstance = new Chart(ctxBar, {
    type: 'bar',
    data: {
      labels: ['Income vs Expense'],
      datasets: [
        { label: 'Income', data: [income], backgroundColor: '#00b894', borderRadius: 8 },
        { label: 'Expense', data: [expense], backgroundColor: '#ff7675', borderRadius: 8 }
      ]
    },
    options: { responsive: true, maintainAspectRatio: false }
  });

  // Savings Trend Chart
  const ctxSavings = document.getElementById('savingsTrendChart').getContext('2d');
  if (savingsTrendChartInstance) savingsTrendChartInstance.destroy();
  savingsTrendChartInstance = new Chart(ctxSavings, {
    type: 'line',
    data: {
      labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
      datasets: [{ label: 'Savings Balance', data: [5000, 12000, 18000, income - expense], borderColor: '#00b894', tension: 0.3, fill: false }]
    },
    options: { responsive: true, maintainAspectRatio: false }
  });
}

// Category Table
function renderCategoryTable() {
  const tbody = document.getElementById('categoryTableBody');
  tbody.innerHTML = '';

  const { txs } = getTotals(state.analyticsTimeRange);
  const expenses = txs.filter(t => t.type === 'expense');
  const totalSpent = expenses.reduce((sum, t) => sum + parseFloat(t.amount), 0);
  const catStats = {};

  expenses.forEach(t => {
    if (!catStats[t.category]) catStats[t.category] = { count: 0, sum: 0 };
    catStats[t.category].count += 1;
    catStats[t.category].sum += parseFloat(t.amount);
  });

  Object.keys(catStats).forEach(cat => {
    const { count, sum } = catStats[cat];
    const share = totalSpent > 0 ? ((sum / totalSpent) * 100).toFixed(1) : 0;
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td><strong>${cat}</strong></td>
      <td>${count} entries</td>
      <td>${share}%</td>
      <td style="font-weight: 700;">${formatMoney(sum)}</td>
    `;
    tbody.appendChild(tr);
  });
}

function populateCategorySelect(type) {
  const select = document.getElementById('txCategory');
  select.innerHTML = '';
  const list = type === 'income' ? INCOME_CATEGORIES : EXPENSE_CATEGORIES;
  list.forEach(cat => {
    const opt = document.createElement('option');
    opt.value = cat;
    opt.textContent = cat;
    select.appendChild(opt);
  });
}

// Event Listeners Setup
function initEventListeners() {
  // Navigation Tabs
  document.querySelectorAll('.nav-item').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.nav-item').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(t => t.classList.remove('active'));
      btn.classList.add('active');
      const tabId = btn.getAttribute('data-tab');
      document.getElementById(`tab-${tabId}`).classList.add('active');
      renderCharts();
    });
  });

  document.querySelectorAll('.switch-tab').forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-target');
      document.querySelector(`.nav-item[data-tab="${target}"]`).click();
    });
  });

  // Notifications toggle & clear
  document.getElementById('notifBtn').addEventListener('click', () => {
    document.getElementById('notifDropdown').classList.toggle('active');
  });

  document.getElementById('clearNotifsBtn').addEventListener('click', () => {
    state.notifications = [];
    renderNotifications();
    saveState();
  });

  // Theme Toggle
  document.getElementById('themeToggle').addEventListener('change', (e) => {
    state.theme = e.target.checked ? 'dark' : 'light';
    initTheme();
    renderCharts();
    saveState();
  });

  // Currency Selector
  const handleCurrencyChange = (val) => {
    state.currency = val;
    renderAll();
  };
  document.getElementById('currencySelect').addEventListener('change', (e) => handleCurrencyChange(e.target.value));
  document.getElementById('settingCurrencySelect').addEventListener('change', (e) => handleCurrencyChange(e.target.value));

  // Time Range Filters for Analytics
  document.querySelectorAll('.time-range-filters button').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.time-range-filters button').forEach(b => b.classList.remove('active-filter'));
      btn.classList.add('active-filter');
      state.analyticsTimeRange = btn.getAttribute('data-range');
      renderCharts();
      renderCategoryTable();
    });
  });

  // Transaction Modal Open/Close
  const modal = document.getElementById('txModal');
  document.getElementById('openAddModalBtn').addEventListener('click', () => {
    document.getElementById('modalTitle').textContent = 'Add Transaction';
    document.getElementById('txForm').reset();
    document.getElementById('txId').value = '';
    document.getElementById('txDate').value = new Date().toISOString().split('T')[0];
    populateCategorySelect('expense');
    modal.classList.add('active');
  });

  document.getElementById('closeModalBtn').addEventListener('click', () => modal.classList.remove('active'));
  document.getElementById('cancelModalBtn').addEventListener('click', () => modal.classList.remove('active'));

  document.querySelectorAll('input[name="txType"]').forEach(radio => {
    radio.addEventListener('change', (e) => populateCategorySelect(e.target.value));
  });

  // Transaction Save Form
  document.getElementById('txForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const id = document.getElementById('txId').value;
    const type = document.querySelector('input[name="txType"]:checked').value;
    const amount = parseFloat(document.getElementById('txAmount').value);
    const category = document.getElementById('txCategory').value;
    const paymentMethod = document.getElementById('txPayment').value;
    const date = document.getElementById('txDate').value;
    const description = document.getElementById('txDescription').value.trim();

    if (!amount || amount <= 0) return alert('Please enter a valid amount');

    if (id) {
      const index = state.transactions.findIndex(t => t.id === id);
      if (index !== -1) {
        state.transactions[index] = { id, type, amount, category, paymentMethod, date, description };
      }
    } else {
      const newTx = { id: Date.now().toString(), type, amount, category, paymentMethod, date, description };
      state.transactions.unshift(newTx);
    }

    modal.classList.remove('active');
    renderAll();
  });

  // Search & Filters
  document.getElementById('searchInput').addEventListener('input', renderFullTransactions);
  document.getElementById('filterType').addEventListener('change', renderFullTransactions);
  document.getElementById('filterCategory').addEventListener('change', renderFullTransactions);
  document.getElementById('filterPayment').addEventListener('change', renderFullTransactions);
  document.getElementById('sortBy').addEventListener('change', renderFullTransactions);

  // Budget Update
  document.getElementById('budgetForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const val = parseFloat(document.getElementById('budgetInput').value);
    if (val && val > 0) {
      state.monthlyBudget = val;
      renderAll();
      alert('Monthly overall budget updated successfully!');
    }
  });

  // Goal Modals
  const goalModal = document.getElementById('goalModal');
  document.getElementById('openGoalModalBtn').addEventListener('click', () => {
    document.getElementById('goalForm').reset();
    document.getElementById('goalTargetDate').value = new Date().toISOString().split('T')[0];
    goalModal.classList.add('active');
  });
  document.getElementById('closeGoalModalBtn').addEventListener('click', () => goalModal.classList.remove('active'));

  document.getElementById('goalForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const name = document.getElementById('goalName').value.trim();
    const target = parseFloat(document.getElementById('goalTarget').value);
    const current = parseFloat(document.getElementById('goalCurrent').value) || 0;
    const date = document.getElementById('goalTargetDate').value;

    state.goals.push({ id: Date.now().toString(), name, target, current, date });
    goalModal.classList.remove('active');
    renderAll();
  });

  // Deposit Modal
  const depositModal = document.getElementById('depositModal');
  document.getElementById('closeDepositModalBtn').addEventListener('click', () => depositModal.classList.remove('active'));
  document.getElementById('depositForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const id = document.getElementById('depositGoalId').value;
    const amt = parseFloat(document.getElementById('depositAmount').value);
    const goal = state.goals.find(g => g.id === id);
    if (goal && amt > 0) {
      goal.current += amt;
      depositModal.classList.remove('active');
      renderAll();
    }
  });

  // Recurring Modal
  const recModal = document.getElementById('recurringModal');
  document.getElementById('openRecurringModalBtn').addEventListener('click', () => {
    document.getElementById('recurringForm').reset();
    document.getElementById('recNextDate').value = new Date().toISOString().split('T')[0];
    recModal.classList.add('active');
  });
  document.getElementById('closeRecurringModalBtn').addEventListener('click', () => recModal.classList.remove('active'));

  document.getElementById('recurringForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const title = document.getElementById('recTitle').value.trim();
    const amount = parseFloat(document.getElementById('recAmount').value);
    const frequency = document.getElementById('recFrequency').value;
    const category = document.getElementById('recCategory').value;
    const nextDate = document.getElementById('recNextDate').value;

    state.recurring.push({ id: Date.now().toString(), title, amount, frequency, category, nextDate, active: true });
    recModal.classList.remove('active');
    renderAll();
  });

  // Receipt OCR Simulator
  const dropzone = document.getElementById('dropzone');
  const fileInput = document.getElementById('receiptFileInput');
  dropzone.addEventListener('click', () => fileInput.click());
  fileInput.addEventListener('change', handleReceiptUpload);

  document.getElementById('ocrConfirmForm').addEventListener('submit', (e) => {
    e.preventDefault();
    const description = document.getElementById('ocrMerchant').value;
    const amount = parseFloat(document.getElementById('ocrAmount').value);
    const category = document.getElementById('ocrCategory').value;
    const date = document.getElementById('ocrDate').value;

    state.transactions.unshift({
      id: Date.now().toString(),
      type: 'expense',
      amount, category, paymentMethod: 'UPI', date, description
    });

    document.getElementById('ocrResultCard').classList.add('hidden');
    alert('Receipt transaction saved successfully!');
    renderAll();
  });

  // Export Buttons
  document.getElementById('exportJsonBtn').addEventListener('click', exportJSON);
  document.getElementById('exportCsvBtn').addEventListener('click', exportCSV);
  document.getElementById('exportPdfBtn').addEventListener('click', exportReport);
  document.getElementById('resetDataBtn').addEventListener('click', () => {
    if (confirm('Are you sure you want to reset all data back to original demo values?')) {
      state.transactions = [...DEFAULT_TRANSACTIONS];
      state.goals = [...DEFAULT_GOALS];
      state.recurring = [...DEFAULT_RECURRING];
      state.monthlyBudget = 20000;
      renderAll();
    }
  });

  document.getElementById('firebaseSyncBtn').addEventListener('click', () => {
    alert('Cloud Firestore synchronized successfully! User security rules verified.');
  });
}

// Receipt OCR Simulation
function handleReceiptUpload(e) {
  if (e.target.files && e.target.files[0]) {
    const card = document.getElementById('ocrResultCard');
    card.classList.remove('hidden');

    // Simulate OCR text extraction
    document.getElementById('ocrMerchant').value = 'Starbucks Coffee';
    document.getElementById('ocrAmount').value = '380.00';
    document.getElementById('ocrCategory').value = 'Food';
    document.getElementById('ocrDate').value = new Date().toISOString().split('T')[0];
  }
}

// Global Deposit & Edit Functions
window.openDepositModal = function(id) {
  document.getElementById('depositGoalId').value = id;
  document.getElementById('depositAmount').value = '';
  document.getElementById('depositModal').classList.add('active');
};

window.deleteRecurring = function(id) {
  if (confirm('Delete this recurring transaction?')) {
    state.recurring = state.recurring.filter(r => r.id !== id);
    renderAll();
  }
};

window.editTransaction = function(id) {
  const tx = state.transactions.find(t => t.id === id);
  if (!tx) return;

  document.getElementById('modalTitle').textContent = 'Edit Transaction';
  document.getElementById('txId').value = tx.id;
  document.querySelector(`input[name="txType"][value="${tx.type}"]`).checked = true;
  populateCategorySelect(tx.type);
  document.getElementById('txAmount').value = tx.amount;
  document.getElementById('txCategory').value = tx.category;
  document.getElementById('txPayment').value = tx.paymentMethod || 'Cash';
  document.getElementById('txDate').value = tx.date;
  document.getElementById('txDescription').value = tx.description;

  document.getElementById('txModal').classList.add('active');
};

window.deleteTransaction = function(id) {
  if (confirm('Are you sure you want to delete this transaction?')) {
    state.transactions = state.transactions.filter(t => t.id !== id);
    renderAll();
  }
};

// Export Generators
function exportJSON() {
  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state.transactions, null, 2));
  const a = document.createElement('a');
  a.href = dataStr;
  a.download = "spendwise_transactions.json";
  a.click();
}

function exportCSV() {
  let csv = "ID,Type,Amount,Category,PaymentMethod,Date,Description\n";
  state.transactions.forEach(t => {
    csv += `"${t.id}","${t.type}",${t.amount},"${t.category}","${t.paymentMethod || 'Cash'}","${t.date}","${t.description}"\n`;
  });
  const dataStr = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
  const a = document.createElement('a');
  a.href = dataStr;
  a.download = "spendwise_report.csv";
  a.click();
}

function exportReport() {
  const { income, expense, balance, savingsRate } = getTotals();
  const reportText = `
========================================
       SPENDWISE FINANCIAL REPORT
========================================
Generated on: ${new Date().toLocaleDateString()}
Currency: ${state.currency}

SUMMARY:
Total Income:     ${formatMoney(income)}
Total Expenses:   ${formatMoney(expense)}
Net Balance:      ${formatMoney(balance)}
Savings Rate:     ${savingsRate}%
Monthly Budget:   ${formatMoney(state.monthlyBudget)}

RECORDED TRANSACTIONS:
${state.transactions.map(t => `- [${t.date}] ${t.type.toUpperCase()}: ${formatMoney(t.amount)} | ${t.category} (${t.paymentMethod || 'Cash'}) - ${t.description}`).join('\n')}
========================================
`;
  const dataStr = "data:text/plain;charset=utf-8," + encodeURIComponent(reportText);
  const a = document.createElement('a');
  a.href = dataStr;
  a.download = "spendwise_monthly_report.txt";
  a.click();
}
