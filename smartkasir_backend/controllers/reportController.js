const { __getAllTransactions } = require('./transactionController');
const { __getAllProducts } = require('./productController');

// Utility: parse date string (YYYY-MM-DD) from ISO
function toYmd(dateIso) {
	const d = new Date(dateIso);
	const y = d.getFullYear();
	const m = String(d.getMonth() + 1).padStart(2, '0');
	const day = String(d.getDate()).padStart(2, '0');
	return `${y}-${m}-${day}`;
}

// GET /reports/sales?start=YYYY-MM-DD&end=YYYY-MM-DD
function getSalesReport(req, res) {
	try {
		const start = req.query.start ? new Date(req.query.start) : null;
		const end = req.query.end ? new Date(req.query.end) : null;

		const txs = __getAllTransactions();
		const products = __getAllProducts();
		const productCostById = new Map(products.map(p => [p.id, p.cost_price || 0]));

		const byDate = new Map();
		for (const tx of txs) {
			const dKey = toYmd(tx.date);
			const dDate = new Date(dKey);
			if (start && dDate < start) continue;
			if (end && dDate > end) continue;

			let total = 0;
			let profit = 0;
			for (const item of tx.items || []) {
				const sell = item.sell_price * item.qty;
				total += sell;
				const cost = (productCostById.get(item.product_id) || 0) * item.qty;
				profit += sell - cost;
			}
			const agg = byDate.get(dKey) || { date: dKey, total: 0, profit: 0 };
			agg.total += total;
			agg.profit += profit;
			byDate.set(dKey, agg);
		}

		const rows = Array.from(byDate.values()).sort((a,b)=> new Date(b.date)-new Date(a.date));
		return res.json(rows);
	} catch (e) {
		return res.status(500).json({ error: 'Internal server error' });
	}
}

module.exports = { getSalesReport };
