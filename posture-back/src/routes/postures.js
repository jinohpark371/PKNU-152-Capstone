import express from 'express';
import { pool } from '../db.js';
const router = express.Router();

router.post('/', async (req, res) => {
  const { user_id, session_id, posture, start_ts, end_ts } = req.body || {};
  if(!posture || !start_ts || !end_ts){
    return res.status(400).json({error:'posture, start_ts, end_ts are required'});
  }
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    let sid = session_id;
    if(!sid && user_id){
      const r = await client.query(
        'SELECT session_id FROM sessions WHERE user_id=$1 AND end_ts IS NULL ORDER BY start_ts DESC LIMIT 1',
        [user_id]
      );
      sid = r.rows[0]?.session_id;
    }
    if(!sid){ throw new Error('No open session found. Provide session_id or send login event first.'); }

    await client.query(
      `INSERT INTO posture_logs (session_id, posture, start_ts, end_ts)
       VALUES ($1,$2,$3,$4)`,
      [sid, posture, start_ts, end_ts]
    );
    await client.query('COMMIT');
    res.json({status:'ok', session_id: sid});
  } catch (e){
    await pool.query('ROLLBACK');
    res.status(400).json({error:e.message});
  } finally {
    client.release();
  }
});

export default router;
