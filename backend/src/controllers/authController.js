import { getPool, sql } from '../db.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

function signToken(user) {
  const payload = { sub: user.Id, role: user.Role, name: user.FullName, email: user.Email };
  const expiresIn = process.env.JWT_EXPIRES_IN || '1d';
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
}

export async function register(req, res) {
  const { FullName, Email, Password, PhoneNumber, DateOfBirth, Role } = req.body;

  if (!FullName || !Email || !Password) {
    return res.status(400).json({ error: 'FullName, Email and Password are required.' });
  }
  if (Password.length < 8 || !(/[A-Za-z]/.test(Password) && /\d/.test(Password))) {
    return res.status(400).json({ error: 'Password must be at least 8 characters and contain letters & numbers.' });
  }

  const passwordHash = await bcrypt.hash(Password, 10);
  const pool = await getPool();
  try {
    const request = pool.request();
    request.input('FullName', sql.NVarChar(200), FullName);
    request.input('Email', sql.NVarChar(200), Email);
    request.input('PasswordHash', sql.NVarChar(sql.MAX), passwordHash);
    request.input('PhoneNumber', sql.NVarChar(50), PhoneNumber || null);
    request.input('DateOfBirth', sql.Date, DateOfBirth || null);
    request.input('Role', sql.NVarChar(50), Role || 'User');

    const result = await request.execute('sp_RegisterUser');
    const userId = result.recordset && result.recordset[0] ? result.recordset[0].NewUserId : null;
    return res.status(201).json({ message: 'Registered successfully. You can now log in.', userId });
  } catch (err) {
    if (err && err.originalError && err.originalError.info && err.originalError.info.message) {
      return res.status(400).json({ error: err.originalError.info.message });
    }
    return res.status(500).json({ error: 'Registration failed.' });
  }
}

export async function login(req, res) {
  const { Email, Password } = req.body;
  if (!Email || !Password) return res.status(400).json({ error: 'Email and Password are required.' });

  const pool = await getPool();
  try {
    const request = pool.request();
    request.input('Email', sql.NVarChar(200), Email);
    const result = await request.execute('sp_LoginUser'); // returns user row including PasswordHash
    const user = result.recordset && result.recordset[0];

    if (!user) return res.status(401).json({ error: 'Invalid email or password.' });
    const ok = await bcrypt.compare(Password, user.PasswordHash);
    if (!ok) return res.status(401).json({ error: 'Invalid email or password.' });

    const token = signToken(user);
    return res.json({ token });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Login failed.' });
  }
}

export async function me(req, res) {
  const pool = await getPool();
  try {
    const request = pool.request();
    request.input('Id', sql.Int, req.user.id);
    const result = await request.execute('sp_GetUserById');
    const user = result.recordset && result.recordset[0];
    if (!user) return res.status(404).json({ error: 'User not found' });
    return res.json(user);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Failed to load profile' });
  }
}
