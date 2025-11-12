import express from 'express';
import dotenv from 'dotenv';
import eventsRouter from './routes/events.js';
import posturesRouter from './routes/postures.js';
import statsRouter from './routes/stats.js';
dotenv.config();
const app = express();
app.use(express.json({limit:'2mb'}));

app.get('/health', (_,res)=>res.json({ok:true, ts:new Date().toISOString()}));

app.use('/api/events', eventsRouter);
app.use('/api/postures', posturesRouter);
app.use('/api/stats', statsRouter);

const PORT = process.env.PORT || 8080;
app.listen(PORT, ()=>{
  console.log(`Posture MVP server running on http://localhost:${PORT}`);
});
