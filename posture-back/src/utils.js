export function toBool(value, def=false){
  if (value === undefined || value === null) return def;
  const s = String(value).toLowerCase();
  return ['1','true','yes','y','on'].includes(s);
}
export function kstDateStr(ts=new Date()){
  const kst = new Date(ts.toLocaleString('en-US', { timeZone: 'Asia/Seoul' }));
  return kst.toISOString().slice(0,10);
}
