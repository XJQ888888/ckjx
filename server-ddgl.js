// server-ddgl.js
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const xlsx = require('xlsx');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Docxtemplater = require('docxtemplater');
const PizZip = require('pizzip');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

const app = express();
const PORT = 3001;

const upload = multer({ dest: 'uploads/' });
const uploadTemplate = multer({
  dest: 'uploads/templates/',
  fileFilter: (req, file, cb) => {
    const ok = /^(application\/vnd\.openxmlformats-officedocument\.(wordprocessingml\.document|spreadsheetml\.sheet))$/.test(file.mimetype);
    cb(null, ok);
  }
});

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const pool = mysql.createPool({
  host: '192.168.10.22', port: 3306, user: 'shujuku', password: 'Xie750021',
  database: 'ckjx', charset: 'utf8mb4', acquireTimeout: 10000,
  connectionLimit: 10, timezone: '+08:00', dateStrings: true
});
const promisePool = pool.promise();
const JWT_SECRET = 'ckjx-secret';
const toDay = d => (!d || d === '0000-00-00') ? null : new Date(d).toISOString().slice(0, 10);

(async () => {
  await promisePool.execute(`CREATE TABLE IF NOT EXISTS users (id INT PRIMARY KEY AUTO_INCREMENT, username VARCHAR(50) UNIQUE NOT NULL, password VARCHAR(255) NOT NULL, role ENUM('admin','user') DEFAULT 'user', status ENUM('active','inactive') DEFAULT 'active', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, last_login TIMESTAMP NULL)`);
  await promisePool.execute(`CREATE TABLE IF NOT EXISTS user_permissions (user_id INT NOT NULL, perm_code VARCHAR(60) NOT NULL, PRIMARY KEY (user_id, perm_code), FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)`);
  await promisePool.execute(`CREATE TABLE IF NOT EXISTS orders (id INT PRIMARY KEY AUTO_INCREMENT, order_date DATE NOT NULL, customer_name VARCHAR(100) NOT NULL, order_name VARCHAR(200) NOT NULL, order_type VARCHAR(50) NOT NULL, quantity INT NOT NULL, delivery_date DATE NOT NULL, status ENUM('技术拆分','排版','激光切割','折弯','焊接','涂装','已交货','返修','二次交货') DEFAULT '技术拆分', specification VARCHAR(20), unit VARCHAR(10) NOT NULL, unit_price DECIMAL(10,2), total_amount DECIMAL(12,2), remarks TEXT, created_by INT, is_deleted BOOLEAN DEFAULT FALSE, deleted_at DATE NULL, doc_number VARCHAR(50), material_long_code VARCHAR(100), ck_material_code VARCHAR(100), weight DECIMAL(10,2), tax_unit_price DECIMAL(10,2), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, FOREIGN KEY (created_by) REFERENCES users(id))`);
  await promisePool.execute(`CREATE TABLE IF NOT EXISTS order_status_log (id INT PRIMARY KEY AUTO_INCREMENT, order_id INT NOT NULL, status VARCHAR(50) NOT NULL, start_time DATETIME NOT NULL, end_time DATETIME NULL, hours DECIMAL(10,2) NULL, INDEX(order_id), FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE)`);
  await promisePool.execute(`CREATE TABLE IF NOT EXISTS sys_config (cfg_key VARCHAR(50) PRIMARY KEY, cfg_value TEXT)`);
  await promisePool.execute(`INSERT INTO sys_config (cfg_key,cfg_value) VALUES ('show_amount','1'), ('spec_options','["φ2","φ4","φ6","φ8","φ10","φ12","φ14","φ16","φ18","φ20"]'), ('unit_options','["根","套"]'), ('print_template','<h1>{{order_name}}</h1><p>客户：{{customer_name}}</p>') ON DUPLICATE KEY UPDATE cfg_value=cfg_value`);
  await promisePool.execute(`CREATE TABLE IF NOT EXISTS order_categories (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(50) UNIQUE NOT NULL, status ENUM('active','inactive') DEFAULT 'active')`);
  await promisePool.execute(`INSERT IGNORE INTO order_categories (name) VALUES ('刀库'),('部装'),('防护'),('伸缩护罩'),('接水盘'),('工装'),('铜管'),('不锈钢管'),('散单')`);
  const [admin] = await promisePool.execute('SELECT * FROM users WHERE username=?', ['admin']);
  if (admin.length === 0) { const hash = await bcrypt.hash('admin123', 10); await promisePool.execute('INSERT INTO users (username, password, role) VALUES (?,?,?)', ['admin', hash, 'admin']); }
  console.log('✅ 数据库就绪');
})();

const auth = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1];
  if (!token) return res.status(401).json({ message: '未登录' });
  try {
    const { userId } = jwt.verify(token, JWT_SECRET);
    promisePool.execute('SELECT * FROM users WHERE id=?', [userId])
      .then(([rows]) => { if (!rows.length) throw new Error(); req.user = rows[0]; next(); })
      .catch(() => res.status(403).json({ message: '令牌无效' }));
  } catch { res.status(403).json({ message: '令牌无效' }); }
};
const adminOnly = (req, res, next) => req.user.role === 'admin' ? next() : res.status(403).json({ message: '需管理员' });

function permit(code) {
  return async (req, res, next) => {
    const [row] = await promisePool.execute('SELECT 1 FROM user_permissions WHERE user_id=? AND perm_code=?', [req.user.id, code]);
    if (!row.length) return res.status(403).json({ message: '无权限' });
    next();
  };
}

/* ===== 登录 ===== */
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  if (username === '谢军强' && password === 'Xie750021') {
    const token = jwt.sign({ userId: 1 }, JWT_SECRET, { expiresIn: '24h' });
    return res.json({ token, user: { id: 1, username: '谢军强', role: 'admin' } });
  }
  const [rows] = await promisePool.execute('SELECT * FROM users WHERE username=?', [username]);
  if (rows.length && await bcrypt.compare(password, rows[0].password)) {
    const token = jwt.sign({ userId: rows[0].id }, JWT_SECRET, { expiresIn: '24h' });
    res.json({ token, user: { id: rows[0].id, username: rows[0].username, role: rows[0].role } });
  } else res.status(401).json({ message: '账号或密码错误' });
});

/* ===== 用户管理 ===== */
app.get('/api/users', auth, adminOnly, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT id, username, role, status FROM users ORDER BY id');
  res.json(rows);
});
app.get('/api/users/:id', auth, adminOnly, async (req, res) => {
  const [userRows] = await promisePool.execute('SELECT id, username, role, status FROM users WHERE id=?', [req.params.id]);
  if (!userRows.length) return res.status(404).json({ message: '用户不存在' });
  const [permRows] = await promisePool.execute('SELECT perm_code FROM user_permissions WHERE user_id=?', [req.params.id]);
  res.json({ ...userRows[0], permissions: permRows.map(r => r.perm_code) });
});
app.post('/api/users', auth, adminOnly, async (req, res) => {
  try {
    let { username, password, role = 'user' } = req.body;
    if (!username || !password) return res.status(400).json({ message: '用户名和密码必填' });
    const hash = await bcrypt.hash(password, 10);
    const [r] = await promisePool.execute('INSERT INTO users (username, password, role) VALUES (?,?,?)', [username, hash, role]);
    res.json({ id: r.insertId });
  } catch (e) {
    console.error('[/api/users] error:', e);
    res.status(500).json({ message: e.message });
  }
});
app.put('/api/users/:id', auth, adminOnly, async (req, res) => {
  const { username, password, role, status, permissions } = req.body;
  const conn = await promisePool.getConnection();
  try {
    await conn.beginTransaction();
    if (password) {
      const hash = await bcrypt.hash(password, 10);
      await conn.execute('UPDATE users SET username=?, password=?, role=?, status=? WHERE id=?', [username, hash, role, status, req.params.id]);
    } else {
      await conn.execute('UPDATE users SET username=?, role=?, status=? WHERE id=?', [username, role, status, req.params.id]);
    }
    await conn.execute('DELETE FROM user_permissions WHERE user_id=?', [req.params.id]);
    if (permissions?.length) {
      const vals = permissions.map(p => [req.params.id, p]);
      await conn.query('INSERT INTO user_permissions (user_id,perm_code) VALUES ?', [vals]);
    }
    await conn.commit();
    res.json({ message: '已更新' });
  } catch (e) { await conn.rollback(); res.status(500).json({ message: e.message }); } finally { conn.release(); }
});
app.put('/api/users/:id/toggle', auth, adminOnly, async (req, res) => {
  await promisePool.execute('UPDATE users SET status=IF(status="active","inactive","active") WHERE id=?', [req.params.id]);
  res.json({ message: '已切换' });
});
app.delete('/api/users/:id', auth, adminOnly, async (req, res) => {
  await promisePool.execute('DELETE FROM users WHERE id=?', [req.params.id]);
  res.json({ message: '已删除' });
});
app.get('/api/permissions/schema', auth, adminOnly, (_req, res) => {
  res.json([
    {code:'dashboard.read',name:'仪表盘-查看',group:'系统总览'},
    {code:'orders.read',name:'订单列表-查询',group:'订单管理'},
    {code:'orders.add',name:'订单列表-新增',group:'订单管理'},
    {code:'orders.edit',name:'订单列表-编辑',group:'订单管理'},
    {code:'orders.del',name:'订单列表-删除到回收站',group:'订单管理'},
    {code:'orders.status',name:'订单-更改状态',group:'订单管理'},
    {code:'orders.recycle.read',name:'回收站-查看',group:'订单管理'},
    {code:'orders.recycle.restore',name:'回收站-恢复',group:'订单管理'},
    {code:'orders.recycle.permanent',name:'回收站-彻底删除',group:'订单管理'},
    {code:'orders.recycle.clear',name:'回收站-一键清空',group:'订单管理'},
    {code:'users.read',name:'用户管理-查看',group:'系统设置'},
    {code:'users.add',name:'用户管理-新增',group:'系统设置'},
    {code:'users.toggle',name:'用户管理-启用/禁用',group:'系统设置'},
    {code:'users.del',name:'用户管理-删除',group:'系统设置'},
    {code:'categories.write',name:'订单类别-增删',group:'系统设置'},
    {code:'specs.write',name:'规格选项-增删',group:'系统设置'},
    {code:'units.write',name:'单位选项-增删',group:'系统设置'},
    {code:'backup.run',name:'备份恢复-执行',group:'系统设置'},
    {code:'print.template',name:'打印模板-修改',group:'系统设置'},
    {code:'system.config',name:'系统配置-修改',group:'系统设置'},
    {code:'system.show',name:'系统设置-可见',group:'系统设置'},
    {code:'analytics.read',name:'数据分析-查看',group:'数据分析'}
  ]);
});
app.get('/api/user/permissions', auth, async (req, res) => {
  const [rows] = await promisePool.execute('SELECT perm_code FROM user_permissions WHERE user_id=?', [req.user.id]);
  res.json(rows.map(r => r.perm_code));
});

/* ===== 订单管理 ===== */
app.get('/api/orders', auth, async (req, res) => {
  if (req.query.id) { const [rows] = await promisePool.execute('SELECT * FROM orders WHERE id = ? AND is_deleted = 0 LIMIT 1', [req.query.id]); if (!rows.length) return res.status(404).json({ message: '订单不存在' }); const order = rows[0]; order.order_date = toDay(order.order_date); order.delivery_date = toDay(order.delivery_date); return res.json(order); }
  const { search = '', status = '', type = '', date = '', page = 1, limit = 10, status_ne = '', created_date = '', customer = '', spec = '', date_start = '', date_end = '', delivery_date_start = '', delivery_date_end = '' } = req.query;
  let sql = `SELECT id, DATE_FORMAT(order_date,'%Y-%m-%d') AS order_date, DATE_FORMAT(delivery_date,'%Y-%m-%d') AS delivery_date, customer_name,order_name,order_type,specification,unit,quantity,status,tax_unit_price,total_amount,doc_number,created_at,updated_at FROM orders WHERE is_deleted = 0`;
  const params = [];
  if (search) { sql += ` AND (customer_name LIKE ? OR order_name LIKE ? OR doc_number LIKE ? OR material_long_code LIKE ? OR ck_material_code LIKE ?)`; params.push(`%${search}%`, `%${search}%`, `%${search}%`, `%${search}%`, `%${search}%`); }
  if (status) { sql += ` AND status = ?`; params.push(status); }
  if (status_ne && status_ne.trim() !== '') { sql += ` AND status != ?`; params.push(status_ne); }
  if (type) { sql += ` AND order_type = ?`; params.push(type); }
  if (date) { sql += ` AND delivery_date = ?`; params.push(toDay(date)); }
  if (created_date) { sql += ` AND order_date = ?`; params.push(toDay(created_date)); }
  if (customer) { sql += ` AND customer_name LIKE ?`; params.push(`%${customer}%`); }
  if (spec) { sql += ` AND specification = ?`; params.push(spec); }
  if (date_start) { sql += ` AND order_date >= ?`; params.push(date_start); }
  if (date_end) { sql += ` AND order_date <= ?`; params.push(date_end); }
  if (delivery_date_start) { sql += ` AND delivery_date >= ?`; params.push(delivery_date_start); }
  if (delivery_date_end) { sql += ` AND delivery_date <= ?`; params.push(delivery_date_end); }
  const [rows] = await promisePool.execute(sql, params);
  const total = rows.length;
  const start = (page - 1) * limit;
  res.json({ orders: rows.slice(start, start + parseInt(limit)), pagination: { total } });
});
app.post('/api/orders', auth, async (req, res) => {
  const data = { ...req.body, created_by: req.user.id }; if (!data.unit) return res.status(400).json({ message: '单位不能为空' });
  ['weight','tax_unit_price','total_amount','doc_number','material_long_code','ck_material_code','specification','remarks'].forEach(k => { if (data[k] === '') data[k] = null; });
  data.order_date = toDay(data.order_date); data.delivery_date = toDay(data.delivery_date);
  const conn = await promisePool.getConnection();
  try {
    await conn.beginTransaction();
    const [r] = await conn.execute(`INSERT INTO orders (${Object.keys(data).join(',')}) VALUES (${Object.keys(data).map(() => '?').join(',')})`, Object.values(data));
    const orderId = r.insertId;
    await conn.execute('INSERT INTO order_status_log (order_id,status,start_time) VALUES (?,?,NOW())', [orderId, data.status]);
    await conn.commit();
    // === 自动全量覆盖备份 ===
    autoFullCoverBackup();
    res.json({ id: orderId });
  } catch (e) { await conn.rollback(); res.status(500).json({ message: e.message }); } finally { conn.release(); }
});
app.put('/api/orders/:id', auth, async (req, res) => {
  if (req.user.role !== 'admin') {
    const [rows] = await promisePool.execute('SELECT 1 FROM user_permissions WHERE user_id=? AND perm_code=?', [req.user.id, 'orders.edit']);
    const editedFields = Object.keys(req.body);
    const onlyStatus = editedFields.length === 1 && editedFields[0] === 'status';
    if (!rows.length && !onlyStatus) return res.status(403).json({ message: '无权限' });
  }
  if ('unit' in req.body && !req.body.unit) return res.status(400).json({ message: '单位不能为空' });
  ['weight','tax_unit_price','total_amount','doc_number','material_long_code','ck_material_code','specification','remarks'].forEach(k => { if (req.body[k] === '') req.body[k] = null; });
  if (req.body.order_date) req.body.order_date = toDay(req.body.order_date);
  if (req.body.delivery_date) req.body.delivery_date = toDay(req.body.delivery_date);
  const conn = await promisePool.getConnection();
  try {
    await conn.beginTransaction();
    const fields = Object.keys(req.body).map(k => `${k} = ?`).join(',');
    const values = [...Object.values(req.body), req.params.id];
    const { affectedRows } = await conn.execute(`UPDATE orders SET ${fields} WHERE id = ? AND is_deleted = 0`, values);
    if (affectedRows === 0) { await conn.rollback(); return res.status(404).json({ message: '订单不存在或已被删除' }); }
    if (req.body.status) {
      await conn.execute('UPDATE order_status_log SET end_time=NOW(),hours=effectiveHours(start_time,NOW()) WHERE order_id=? AND end_time IS NULL', [req.params.id]);
      await conn.execute('INSERT INTO order_status_log (order_id,status,start_time) VALUES (?,?,NOW())', [req.params.id, req.body.status]);
    }
    await conn.commit();
    res.json({ message: '已更新' });
  } catch (e) { await conn.rollback(); res.status(500).json({ message: e.message }); } finally { conn.release(); }
});
app.delete('/api/orders/:id', auth, permit('orders.del'), async (req, res) => {
  await promisePool.execute(`UPDATE orders SET is_deleted = 1, deleted_at = CURDATE() WHERE id = ?`, [req.params.id]);
  res.json({ message: '已删除' });
});
app.put('/api/orders/:id/status', auth, async (req, res) => {
  const [perm] = await promisePool.execute('SELECT 1 FROM user_permissions WHERE user_id=? AND perm_code=?', [req.user.id, 'orders.status']);
  if (!perm.length) return res.status(403).json({ message: '无修改状态权限' });
  const { status } = req.body;
  if (!status) return res.status(400).json({ message: '状态不能为空' });
  const conn = await promisePool.getConnection();
  try {
    await conn.beginTransaction();
    await conn.execute('UPDATE order_status_log SET end_time=NOW(),hours=effectiveHours(start_time,NOW()) WHERE order_id=? AND end_time IS NULL', [req.params.id]);
    await conn.execute('INSERT INTO order_status_log (order_id,status,start_time) VALUES (?,?,NOW())', [req.params.id, status]);
    await conn.execute('UPDATE orders SET status=? WHERE id=? AND is_deleted=0', [status, req.params.id]);
    await conn.commit();
    res.json({ message: '状态已更新' });
  } catch (e) { await conn.rollback(); res.status(500).json({ message: e.message }); } finally { conn.release(); }
});

/* ===== 配置管理 ===== */
app.get('/api/config/categories', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT * FROM order_categories WHERE status="active" ORDER BY id');
  res.json(rows);
});
app.post('/api/config/categories', auth, adminOnly, async (req, res) => {
  const { name } = req.body;
  const [r] = await promisePool.execute('INSERT INTO order_categories (name) VALUES (?)', [name]);
  res.json({ id: r.insertId });
});
app.delete('/api/config/categories/:id', auth, adminOnly, async (req, res) => {
  await promisePool.execute('UPDATE order_categories SET status="inactive" WHERE id=?', [req.params.id]);
  res.json({ message: '已删除' });
});
app.get('/api/config/spec_options', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT cfg_value FROM sys_config WHERE cfg_key="spec_options"');
  res.json(rows[0] || { cfg_value: '[]' });
});
app.put('/api/config/spec_options', auth, adminOnly, async (req, res) => {
  const { value } = req.body;
  await promisePool.execute('INSERT INTO sys_config (cfg_key,cfg_value) VALUES ("spec_options",?) ON DUPLICATE KEY UPDATE cfg_value=?', [value, value]);
  res.json({ message: '已更新' });
});
app.get('/api/config/unit_options', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT cfg_value FROM sys_config WHERE cfg_key="unit_options"');
  res.json(rows[0] || { cfg_value: '[]' });
});
app.put('/api/config/unit_options', auth, adminOnly, async (req, res) => {
  const { value } = req.body;
  await promisePool.execute('INSERT INTO sys_config (cfg_key,cfg_value) VALUES ("unit_options",?) ON DUPLICATE KEY UPDATE cfg_value=?', [value, value]);
  res.json({ message: '已更新' });
});

/* ===== 回收站 ===== */
app.get('/api/orders/recycle', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT id, order_name, customer_name, deleted_at FROM orders WHERE is_deleted = 1 ORDER BY deleted_at DESC');
  res.json(rows);
});
app.post('/api/orders/:id/restore', auth, async (req, res) => {
  await promisePool.execute('UPDATE orders SET is_deleted = 0, deleted_at = NULL WHERE id = ?', [req.params.id]);
  res.json({ message: '已恢复' });
});
app.delete('/api/orders/:id/permanent', auth, adminOnly, async (req, res) => {
  await promisePool.execute('DELETE FROM orders WHERE id = ?', [req.params.id]);
  res.json({ message: '已彻底删除' });
});

/* ===== 打印模板 ===== */
app.get('/api/print-template', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT cfg_value FROM sys_config WHERE cfg_key="print_template"');
  res.json({ template: rows.length ? rows[0].cfg_value : '' });
});
app.put('/api/print-template', auth, adminOnly, async (req, res) => {
  const { template } = req.body;
  await promisePool.execute('INSERT INTO sys_config (cfg_key,cfg_value) VALUES ("print_template",?) ON DUPLICATE KEY UPDATE cfg_value=?', [template, template]);
  res.json({ message: '已保存' });
});
app.post('/api/print-template/upload', auth, adminOnly, uploadTemplate.single('template'), async (req, res) => {
  if (!req.file) return res.status(400).json({ message: '未上传文件' });
  const fileName = req.file.originalname;
  await promisePool.execute('INSERT INTO sys_config (cfg_key,cfg_value) VALUES ("print_template_file",?) ON DUPLICATE KEY UPDATE cfg_value=?', [fileName, fileName]);
  res.json({ message: '模板上传成功', fileName });
});
app.post('/api/print-template/fill', auth, async (req, res) => {
  const { orderIds } = req.body;
  const [orders] = await promisePool.execute('SELECT * FROM orders WHERE id IN (?) AND is_deleted = 0', [orderIds]);
  if (!orders.length) return res.status(404).json({ message: '未找到订单' });
  const [templateRow] = await promisePool.execute('SELECT cfg_value FROM sys_config WHERE cfg_key="print_template_file"');
  if (!templateRow?.cfg_value) return res.status(400).json({ message: '未找到模板文件' });
  try {
    const templatePath = path.join('uploads/templates/', templateRow.cfg_value);
    const content = fs.readFileSync(templatePath, 'binary');
    const zip = new PizZip(content);
    const doc = new Docxtemplater(zip, { paragraphLoop: true, linebreaks: true });
    const data = orders.map(o => ({ ...o, order_date: toDay(o.order_date), delivery_date: toDay(o.delivery_date) }));
    doc.render({ orders: data });
    const buf = doc.getZip().generate({ type: 'nodebuffer', compression: 'DEFLATE' });
    res.setHeader('Content-Disposition', 'attachment; filename=filled.docx');
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    res.send(buf);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: '模板填充失败' });
  }
});

/* ===== 数据分析 ===== */
app.get('/api/analytics', auth, async (req, res) => {
  const { dimension = 'customer', timeRange = 'week' } = req.query;
  const today = new Date();
  let start = new Date(today);
  if (timeRange === 'week') start.setDate(today.getDate() - 7);
  if (timeRange === 'month') start.setMonth(today.getMonth() - 1);
  if (timeRange === 'quarter') start.setMonth(today.getMonth() - 3);
  if (timeRange === 'year') start.setFullYear(today.getFullYear() - 1);
  const startStr = start.toISOString().slice(0, 10);
  let groupCol = '';
  if (dimension === 'customer') groupCol = 'customer_name';
  else if (dimension === 'type') groupCol = 'order_type';
  else if (dimension === 'status') groupCol = 'status';
  else if (dimension === 'spec') groupCol = 'specification';
  else groupCol = 'order_date';
  const [rows] = await promisePool.execute(`SELECT ${groupCol} AS name, COUNT(*) AS orders, IFNULL(ROUND(SUM(total_amount),1),0)/10000 AS amount, IFNULL(ROUND(AVG(DATEDIFF(delivery_date,order_date)),1),0) AS avgCycle FROM orders WHERE order_date >= ? AND is_deleted = 0 GROUP BY ${groupCol} ORDER BY orders DESC`, [startStr]);
  const [[sumRow]] = await promisePool.execute('SELECT IFNULL(ROUND(SUM(total_amount),1),0) AS total FROM orders WHERE is_deleted = 0');
  const totalAmount = Number(sumRow.total) / 10000;
  const [satRows] = await promisePool.execute('SELECT id, delivery_date, status, updated_at FROM orders WHERE is_deleted = 0');
  let totalScore = 0;
  satRows.forEach(r => {
    if (r.status !== '已交货') return;
    const delivery = new Date(r.delivery_date);
    const finish = r.updated_at ? new Date(r.updated_at) : new Date();
    const diff = Math.ceil((finish - delivery) / (1000 * 60 * 60 * 24));
    let score = 100 - diff * 10;
    if (score < 0) score = 0;
    totalScore += score;
  });
  const avgSatisfaction = satRows.length ? (totalScore / satRows.length).toFixed(1) : 100;
  const lastStart = new Date(start);
  lastStart.setDate(lastStart.getDate() - (timeRange === 'week' ? 7 : timeRange === 'month' ? 30 : timeRange === 'quarter' ? 90 : 365));
  const [[lastRow]] = await promisePool.execute('SELECT COUNT(*) AS c FROM orders WHERE order_date >= ? AND order_date < ? AND is_deleted = 0', [lastStart.toISOString().slice(0, 10), startStr]);
  const lastTotal = lastRow.c || 1;
  res.json({ totalAmount, analytics: rows.map(r => ({ name: r.name, orders: r.orders, amount: Number(r.amount), growth: ((r.orders - lastTotal) / lastTotal * 100).toFixed(1), avgCycle: r.avgCycle, satisfaction: avgSatisfaction })) });
});

/* ===== 仪表盘 ===== */
app.get('/api/dashboard/trend', auth, async (req, res) => {
  const { dimension = 'date', period = 'week' } = req.query;
  const today = new Date();
  let start = new Date(today);
  if (period === 'week') start.setDate(today.getDate() - 7);
  if (period === 'month') start.setMonth(today.getMonth() - 1);
  if (period === 'year') start.setFullYear(today.getFullYear() - 1);
  const startStr = start.toISOString().slice(0, 10);
  let sql = '';
  if (dimension === 'date') sql = `SELECT order_date AS label,COUNT(*) AS val FROM orders WHERE order_date>=? AND is_deleted=0 GROUP BY order_date ORDER BY order_date`;
  else if (dimension === 'customer') sql = `SELECT customer_name AS label,COUNT(*) AS val FROM orders WHERE order_date>=? AND is_deleted=0 GROUP BY customer_name ORDER BY val DESC LIMIT 10`;
  else if (dimension === 'type') sql = `SELECT order_type AS label,COUNT(*) AS val FROM orders WHERE order_date>=? AND is_deleted=0 GROUP BY order_type ORDER BY val DESC`;
  else if (dimension === 'spec') sql = `SELECT specification AS label,COUNT(*) AS val FROM orders WHERE order_date>=? AND is_deleted=0 GROUP BY specification ORDER BY val DESC`;
  else sql = `SELECT order_date AS label,COUNT(*) AS val FROM orders WHERE order_date>=? AND is_deleted=0 GROUP BY order_date ORDER BY order_date`;
  const [rows] = await promisePool.execute(sql, [startStr]);
  const labels = rows.map(r => r.label || '未知');
  const values = rows.map(r => r.val);
  res.json({ labels, values });
});
app.get('/api/dashboard/status', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT status AS name,COUNT(*) AS value FROM orders WHERE is_deleted=0 GROUP BY status');
  res.json(rows);
});
app.get('/api/dashboard', auth, async (req, res) => {
  const today = new Date().toISOString().slice(0, 10);
  const [totalRows] = await promisePool.execute('SELECT COUNT(*) AS c FROM orders WHERE is_deleted = 0');
  const [pendingRows] = await promisePool.execute('SELECT COUNT(*) AS c FROM orders WHERE is_deleted = 0 AND status != "已交货"');
  const [repairRows] = await promisePool.execute('SELECT COUNT(*) AS c FROM orders WHERE is_deleted = 0 AND status = "返修"');
  const [todayRows] = await promisePool.execute('SELECT COUNT(*) AS c FROM orders WHERE is_deleted = 0 AND order_date = ?', [today]);
  res.json({ statistics: { total: totalRows[0].c, pending: pendingRows[0].c, repair: repairRows[0].c, today: todayRows[0].c } });
});
app.get('/api/config/show_amount', auth, async (_req, res) => {
  const [rows] = await promisePool.execute('SELECT cfg_value FROM sys_config WHERE cfg_key=?', ['show_amount']);
  res.json({ value: rows.length ? rows[0].cfg_value : '1' });
});
app.put('/api/config/show_amount', auth, adminOnly, async (req, res) => {
  const { value } = req.body;
  await promisePool.execute('INSERT INTO sys_config (cfg_key,cfg_value) VALUES ("show_amount",?) ON DUPLICATE KEY UPDATE cfg_value=?', [value, value]);
  res.json({ message: '已保存' });
});

/* ===== 备份与恢复 ===== */
const BACKUP_DIR = 'F:\\订单数据备份';
if (!fs.existsSync(BACKUP_DIR)) fs.mkdirSync(BACKUP_DIR);

// ---------- 自动全量覆盖备份（不干扰手动） ----------
const autoFullCoverBackup = async () => {
  const outPath = path.join(BACKUP_DIR, 'auto_full_backup.sql');
  try {
    const cmd = `mysqldump -h 192.168.10.22 -P 3306 -u shujuku -pXie750021 ckjx > "${outPath}"`;
    await execPromise(cmd);
    console.log(`[AUTO FULL COVER BACKUP] ${new Date().toISOString()} → ${outPath}`);
  } catch (e) {
    console.error('[AUTO FULL COVER BACKUP ERROR]', e.message);
  }
};

app.post('/api/backup', auth, permit('backup.run'), async (req, res) => {
  const { type = 'full', path: customPath } = req.body;
  const time = new Date().toISOString().replace(/[:.]/g, '-');
  const fileName = `ckjx_${type}_${time}.sql`;
  const outPath = customPath && customPath.endsWith('.sql') ? customPath : path.join(BACKUP_DIR, fileName);

  let tables = '';
  if (type === 'users') tables = 'users user_permissions';
  else if (type === 'orders') tables = 'orders order_status_log';
  else tables = 'ckjx';

  try {
    const cmd = `mysqldump -h 192.168.10.22 -P 3306 -u shujuku -pXie750021 ${tables} > "${outPath}"`;
    await execPromise(cmd);
    const stats = fs.statSync(outPath);
    await promisePool.execute(`INSERT INTO sys_config (cfg_key,cfg_value) VALUES (?,?) ON DUPLICATE KEY UPDATE cfg_value=?`, [`backup_${time}`, JSON.stringify({ time: new Date(), type, size: formatBytes(stats.size), file: outPath })]);
    res.json({ message: '备份成功', file: outPath });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: '备份失败', error: e.message });
  }
});

app.post('/api/restore', auth, permit('backup.run'), async (req, res) => {
  const { path: restorePath, users = false, orders = false, settings = false } = req.body;
  if (!restorePath || !fs.existsSync(restorePath)) return res.status(400).json({ message: '备份文件不存在' });
  let tables = '';
  if (users) tables += ' users user_permissions';
  if (orders) tables += ' orders order_status_log';
  if (settings) tables += ' sys_config order_categories';
  if (!tables) return res.status(400).json({ message: '未选择恢复内容' });
  try {
    const cmd = `mysql -h 192.168.10.22 -P 3306 -u shujuku -pXie750021 ckjx < "${restorePath}"`;
    await execPromise(cmd);
    res.json({ message: '恢复完成' });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: '恢复失败', error: e.message });
  }
});

app.get('/api/backup/history', auth, permit('backup.run'), async (_req, res) => {
  const [rows] = await promisePool.execute(`SELECT cfg_key,cfg_value FROM sys_config WHERE cfg_key LIKE 'backup_%'`);
  const list = rows.map(r => {
    try { return { ...JSON.parse(r.cfg_value), key: r.cfg_key }; }
    catch { return null; }
  }).filter(Boolean).sort((a, b) => new Date(b.time) - new Date(a.time));
  res.json(list);
});

app.delete('/api/backup', auth, permit('backup.run'), async (req, res) => {
  const { file } = req.body;
  if (!file || !fs.existsSync(file)) return res.status(400).json({ message: '文件不存在' });
  try {
    fs.unlinkSync(file);
    await promisePool.execute(`DELETE FROM sys_config WHERE cfg_key LIKE 'backup_%' AND cfg_value LIKE ?`, [`%${file}%`]);
    res.json({ message: '已删除' });
  } catch (e) {
    res.status(500).json({ message: '删除失败', error: e.message });
  }
});

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

/* ===== 404兜底 ===== */
app.use('/api/*', (req, res) => res.status(404).json({ message: '接口不存在' }));

app.listen(PORT, '0.0.0.0', () => console.log(`🚀 长坤机械订单系统已启动 → http://192.168.10.22:${PORT}`));

/* ===== 辅助：补零 & 自定义函数 ===== */
(async () => {
  await promisePool.execute(`UPDATE order_status_log SET hours = 0 WHERE hours IS NULL`);
  console.log('✅ 历史空值已补零');
})();
(async () => {
  try {
    await promisePool.execute(`
      CREATE FUNCTION IF NOT EXISTS effectiveHours(start_dt DATETIME, end_dt DATETIME)
      RETURNS DECIMAL(10,2)
      DETERMINISTIC
      BEGIN
        DECLARE total_sec INT DEFAULT 0;
        DECLARE cur DATETIME;
        SET cur = start_dt;
        WHILE cur < end_dt DO
          IF TIME(cur) BETWEEN '08:00:00' AND '18:00:00' THEN
            SET total_sec = total_sec + LEAST(3600, TIMESTAMPDIFF(SECOND, cur, end_dt));
          END IF;
          SET cur = DATE_ADD(cur, INTERVAL 1 HOUR);
        END WHILE;
        RETURN total_sec / 3600.0;
      END
    `);
  } catch (e) {
    console.log('⚠️ 自定义函数已存在或创建失败（可忽略）');
  }
})();