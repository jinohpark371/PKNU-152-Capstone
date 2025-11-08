import express from 'express';
import { pool } from '../db.js';
const router = express.Router();

function kstDate(d=new Date()){
  const s = new Date(d.toLocaleString('en-US', { timeZone: 'Asia/Seoul' }));
  return new Date(Date.UTC(s.getFullYear(), s.getMonth(), s.getDate()));
}

router.get('/today', async (req, res) => {
  const user_id = req.query.user_id;
  if(!user_id) return res.status(400).json({error:'user_id required'});
  const dayStart = kstDate();
  const dayEnd = new Date(dayStart.getTime() + 24*3600*1000);

  const collectAmb = String(process.env.COLLECT_AMBIGUOUS||'true').toLowerCase() !== 'false';
  try{
    const q = `
      WITH day_bounds AS (
        SELECT $2::timestamptz AS day_start, $3::timestamptz AS day_end
      ),
      raw AS (
        SELECT p.posture, p.duration_sec
        FROM posture_logs p
        JOIN sessions s ON s.session_id = p.session_id
        JOIN day_bounds d ON p.start_ts < d.day_end AND p.end_ts > d.day_start
        WHERE s.user_id = $1
          AND p.start_ts >= d.day_start AND p.end_ts <= d.day_end
          ${collectAmb ? "" : "AND p.posture NOT LIKE 'ambiguous%'"}
      )
      SELECT COALESCE(SUM(duration_sec),0) AS total,
             COALESCE(JSON_AGG(JSON_BUILD_OBJECT('posture', posture, 'duration_sec', SUM(duration_sec))
                     ORDER BY SUM(duration_sec) DESC), '[]'::json) AS rows
      FROM (
        SELECT posture, SUM(duration_sec) AS duration_sec
        FROM raw
        GROUP BY posture
      ) t;
    `;
    const { rows } = await pool.query(q, [user_id, dayStart.toISOString(), dayEnd.toISOString()]);
    const total = Number(rows[0].total||0);
    const by_posture = rows[0].rows.map(r => ({...r, ratio: total? (r.duration_sec/total):0}));
    res.json({ user_id, date: dayStart.toISOString().slice(0,10), total_duration_sec: total, by_posture });
  }catch(e){
    res.status(400).json({error:e.message});
  }
});

export default router;
