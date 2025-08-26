const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');

const easyBtn = document.getElementById('easyBtn');
const mediumBtn = document.getElementById('mediumBtn');
const hardBtn = document.getElementById('hardBtn');

const themeBtn = document.getElementById('themeBtn');
const sparkleBtn = document.getElementById('sparkleBtn');
const resetBtn = document.getElementById('resetBtn');

const accuracyEl = document.getElementById('accuracy');
const finalEl = document.getElementById('final');
const timeEl = document.getElementById('time');
const bestEl = document.getElementById('best');
const messageEl = document.getElementById('message');

const pop = document.getElementById('pop');
const popAccuracy = document.getElementById('popAccuracy');
const popFinal = document.getElementById('popFinal');

// 🎵 Sounds
const drawSound = document.getElementById('drawSound');
const highScoreSound = document.getElementById('highScoreSound');
const errorSound = document.getElementById('errorSound');

// Unlock audio policy once user clicks anywhere
document.addEventListener('click', () => {
  [drawSound, highScoreSound, errorSound].forEach(s => {
    if (s) s.muted = false;
  });
}, { once: true });

let path = [];
let drawing = false;
let particles = [];
let sparkleOn = true;
let startMs = 0, endMs = 0;

const DIFFICULTY = {
  easy:   { dotR: 18, sigmaScale: 3.5, timeScale: 80 },
  medium: { dotR: 10, sigmaScale: 5.0, timeScale: 50 },
  hard:   { dotR: 5,  sigmaScale: 7.5, timeScale: 36 }
};
let currentDifficulty = 'medium';

// ==========================
// Canvas + Drawing Functions
// ==========================

function fitCanvas(){
  const rect = canvas.getBoundingClientRect();
  const dpr = Math.max(1, window.devicePixelRatio || 1);
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}
window.addEventListener('resize', fitCanvas);
setTimeout(fitCanvas, 60);

function getCenter(){ return { x: canvas.clientWidth / 2, y: canvas.clientHeight / 2 }; }
function dist(x1,y1,x2,y2){ return Math.hypot(x1-x2, y1-y2); }

function drawCenter(){
  const c = getCenter();
  ctx.save();
  const t = performance.now() * 0.003;
  const glow = 10 + Math.sin(t) * 6;
  ctx.shadowColor = '#ff3b3b';
  ctx.shadowBlur = 18 + glow;
  ctx.fillStyle = '#ff3b3b';
  ctx.beginPath();
  ctx.arc(c.x, c.y, DIFFICULTY[currentDifficulty].dotR, 0, Math.PI*2);
  ctx.fill();
  ctx.restore();
}

function drawPath(){
  if (path.length < 2) return;
  ctx.save();
  ctx.lineWidth = 2.6;
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.strokeStyle = 'rgba(0,240,255,0.95)';
  ctx.beginPath();
  ctx.moveTo(path[0].x, path[0].y);
  for (let i=1;i<path.length;i++) ctx.lineTo(path[i].x, path[i].y);
  ctx.stroke();
  ctx.restore();
}

// ==========================
// Sparkle Trail
// ==========================

function spawnSparkles(x, y){
  if (!sparkleOn) return;
  const isLight = document.body.classList.contains('light');
  const baseHue = isLight ? 210 : 140;
  const count = 4;
  for (let i=0;i<count;i++){
    const ang = Math.random() * Math.PI * 2;
    const speed = 0.6 + Math.random() * 1.6;
    particles.push({
      x, y,
      dx: Math.cos(ang) * speed,
      dy: Math.sin(ang) * speed * 0.9,
      size: 0.9 + Math.random() * 2.6,
      alpha: 1,
      hue: baseHue + Math.random() * 30 - 15
    });
  }
}

function updateSparkles(){
  if (!particles.length) return;
  ctx.save();
  ctx.globalCompositeOperation = 'lighter';
  for (let i = particles.length - 1; i >= 0; i--){
    const p = particles[i];
    p.x += p.dx;
    p.y += p.dy;
    p.size *= 0.97;
    p.alpha -= 0.022;
    p.hue += 0.6;

    if (p.alpha <= 0.03 || p.size <= 0.25){
      particles.splice(i, 1);
      continue;
    }

    ctx.fillStyle = `hsla(${p.hue},100%,60%,${Math.max(0,p.alpha)})`;
    ctx.beginPath();
    ctx.arc(p.x, p.y, Math.max(0.2, p.size), 0, Math.PI*2);
    ctx.fill();
  }
  ctx.restore();
}

// ==========================
// Main Animation Loop
// ==========================

function frame(){
  ctx.clearRect(0, 0, canvas.clientWidth, canvas.clientHeight);
  drawCenter();
  drawPath();
  updateSparkles();
  requestAnimationFrame(frame);
}
requestAnimationFrame(frame);

// ==========================
// Input Handling
// ==========================

function getPos(evt){
  const r = canvas.getBoundingClientRect();
  const touch = evt.touches ? evt.touches[0] : null;
  const clientX = touch ? touch.clientX : evt.clientX;
  const clientY = touch ? touch.clientY : evt.clientY;
  return { x: clientX - r.left, y: clientY - r.top };
}

function startDraw(evt){
  evt.preventDefault();
  drawing = true;
  path = [];
  particles = [];
  startMs = performance.now();
  messageEl.textContent = '';
  pop.classList.add('hidden');

  const p = getPos(evt);
  path.push(p);

  // 🎵 Start drawing sound
  if (drawSound) {
    try { drawSound.currentTime = 0; drawSound.loop = true; drawSound.play().catch(()=>{}); } catch(e){}
  }
}

function moveDraw(evt){
  if (!drawing) return;
  evt.preventDefault();
  const p = getPos(evt);
  const last = path[path.length-1];
  if (!last || dist(last.x,last.y,p.x,p.y) > 1.4){
    path.push(p);
    spawnSparkles(p.x, p.y);
  }
}

function endDraw(evt){
  if (!drawing) return;
  drawing = false;
  endMs = performance.now();

  // 🎵 Stop drawing sound
  if (drawSound) try { drawSound.pause(); drawSound.currentTime = 0; } catch(e){}

  const c = getCenter();
  if (!pointInPoly(c.x, c.y, path)){
    messageEl.textContent = '❌ The red dot is not inside your circle!';
    updateUIResult(0, 0, 0);
    if (errorSound) try { errorSound.currentTime = 0; errorSound.play().catch(()=>{}); } catch(e){}
    return;
  }

  const acc = computeImprovedAccuracy();
  const elapsed = Math.max(1, endMs - startMs);
  const bonus = computeTimeBonus(elapsed);
  const final = Math.min(100, acc + bonus);

  const isHighScore = updateUIResult(acc, final, elapsed, bonus);
  showPopup(acc, final);

  if (isHighScore && highScoreSound) {
    try { highScoreSound.currentTime = 0; highScoreSound.play().catch(()=>{}); } catch(e){}
  }
}

canvas.addEventListener('mousedown', startDraw);
canvas.addEventListener('mousemove', moveDraw);
window.addEventListener('mouseup', endDraw);

canvas.addEventListener('touchstart', startDraw, {passive:false});
canvas.addEventListener('touchmove', moveDraw, {passive:false});
window.addEventListener('touchend', endDraw);

// ==========================
// Accuracy + Bonus Calculation
// ==========================

function pointInPoly(x, y, poly){
  let inside = false;
  for (let i=0,j=poly.length-1;i<poly.length;j=i++){
    const xi = poly[i].x, yi = poly[i].y;
    const xj = poly[j].x, yj = poly[j].y;
    const intersect = ((yi>y)!==(yj>y)) && (x < (xj-xi)*(y-yi)/(yj-yi+1e-12) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

function computeImprovedAccuracy(){
  if (path.length < 8) return 0;
  const c = getCenter();

  const radii = [];
  const angles = [];
  for (let p of path){
    const dx = p.x - c.x;
    const dy = p.y - c.y;
    radii.push(Math.hypot(dx, dy));
    let a = Math.atan2(dy, dx);
    if (a < 0) a += Math.PI * 2;
    angles.push(a);
  }

  const meanR = radii.reduce((s,v)=>s+v,0) / radii.length;
  const meanAbsDev = radii.reduce((s,r)=>s + Math.abs(r - meanR), 0) / radii.length;
  const sigmaScale = DIFFICULTY[currentDifficulty].sigmaScale;
  const rel = meanAbsDev / Math.max(1, meanR);
  const radiusScore = Math.max(0, 100 - rel * 100 * sigmaScale);

  angles.sort((a,b)=>a-b);
  let maxGap = 0;
  for (let i=0;i<angles.length-1;i++){
    const gap = angles[i+1] - angles[i];
    if (gap > maxGap) maxGap = gap;
  }
  const wrapGap = (Math.PI*2) - (angles[angles.length-1] - angles[0]);
  if (wrapGap > maxGap) maxGap = wrapGap;
  const coverageScore = Math.max(0, 100 - (maxGap / (Math.PI*2)) * 360);

  let sharpPenalty = 0;
  for (let i = 2; i < path.length; i++){
    const a1 = Math.atan2(path[i-1].y - c.y, path[i-1].x - c.x);
    const a2 = Math.atan2(path[i].y - c.y, path[i].x - c.x);
    let diff = Math.abs(a2 - a1);
    if (diff > Math.PI) diff = 2 * Math.PI - diff;
    if (diff > 0.35) sharpPenalty += (diff - 0.35) * 30;
  }
  const smoothnessScore = Math.max(0, 100 - sharpPenalty);

  const total = radiusScore * 0.5 + coverageScore * 0.35 + smoothnessScore * 0.15;
  return Math.round(Math.max(0, Math.min(100, total)) * 100) / 100;
}

function computeTimeBonus(msElapsed){
  const timeScale = DIFFICULTY[currentDifficulty].timeScale;
  const bonus = Math.max(0, timeScale - (msElapsed / 100));
  return Math.round(bonus * 100) / 100;
}

function updateUIResult(acc, finalScore, ms, bonus=0){
  accuracyEl.textContent = `${acc.toFixed(2)}%`;
  accuracyEl.className = 'value ' + (acc >= 90 ? 'good' : acc >= 60 ? 'warn' : 'bad');

  finalEl.textContent = `${finalScore.toFixed(2)}`;
  timeEl.textContent = `${(ms/1000).toFixed(2)}s (+${bonus.toFixed(2)})`;

  const prev = parseFloat(sessionStorage.getItem('pc-best-final') || '0') || 0;
  let isHighScore = false;
  if (finalScore > prev) {
    sessionStorage.setItem('pc-best-final', String(finalScore));
    isHighScore = true;
  }
  bestEl.textContent = (Math.max(prev, finalScore)).toFixed(2);
  return isHighScore;
}

function showPopup(acc, finalScore){
  popAccuracy.textContent = `${acc.toFixed(2)}%`;
  popFinal.textContent = `Final: ${finalScore.toFixed(2)}`;
  pop.classList.remove('hidden');
  setTimeout(()=> pop.classList.add('hidden'), 3000);
}

// ==========================
// UI Buttons
// ==========================

function setDifficulty(name){
  currentDifficulty = name;
  easyBtn.classList.toggle('active', name === 'easy');
  mediumBtn.classList.toggle('active', name === 'medium');
  hardBtn.classList.toggle('active', name === 'hard');
  ctx.clearRect(0,0,canvas.clientWidth, canvas.clientHeight);
  spawnImmediateCenterRender();
}
easyBtn.addEventListener('click', ()=> setDifficulty('easy'));
mediumBtn.addEventListener('click', ()=> setDifficulty('medium'));
hardBtn.addEventListener('click', ()=> setDifficulty('hard'));

themeBtn.addEventListener('click', ()=>{ document.body.classList.toggle('light'); });
sparkleBtn.addEventListener('click', ()=>{ sparkleOn = !sparkleOn; sparkleBtn.textContent = sparkleOn ? '✨' : '❌'; });
resetBtn.addEventListener('click', ()=>{
  path = []; particles = []; pop.classList.add('hidden');
  accuracyEl.textContent = '--%'; accuracyEl.className = 'value';
  finalEl.textContent = '--'; timeEl.textContent = '0.00s';
  messageEl.textContent = 'Hold & draw a loop that encloses the red dot.';
  ctx.clearRect(0,0,canvas.clientWidth, canvas.clientHeight);
  if (drawSound) try { drawSound.pause(); drawSound.currentTime = 0; } catch(e){}
  spawnImmediateCenterRender();
});

function spawnImmediateCenterRender(){ drawCenter(); }
spawnImmediateCenterRender();

(function loadBest(){
  const prev = parseFloat(sessionStorage.getItem('pc-best-final') || '0') || 0;
  if (prev > 0) bestEl.textContent = prev.toFixed(2);
})();
