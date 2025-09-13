## **Perfect Circle — Futuristic Drawing Game**

This project is an interactive canvas-based game where players attempt to draw a perfect circle around a glowing red dot. The game evaluates the drawing using geometry, applies accuracy and smoothness metrics, and adds a speed bonus. The visuals include glowing sparkles and real-time score updates to keep things interactive and eye-catching

---

### **1. Canvas Initialization**

The canvas is prepared to fit the browser window and handle high-DPI (Retina) displays.

```javascript
function fitCanvas(){
  const rect = canvas.getBoundingClientRect();
  const dpr = Math.max(1, window.devicePixelRatio || 1);
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}
window.addEventListener('resize', fitCanvas);
fitCanvas();
```

**Details:**

- `getBoundingClientRect()` → detects the visible canvas size.  
- `devicePixelRatio` → ensures smooth, crisp rendering.  
- Every resize event recalculates the canvas size.

---

### **2. Capturing User Input**

When the player draws, every point `(x, y)` along the path is captured.

```javascript
let path = [];

function moveDraw(evt){
  if (!drawing) return;
  const p = getPos(evt);   // current mouse/touch position
  path.push(p);            // store point
  spawnSparkles(p.x, p.y); // trigger visual effect
}
```

**Details:**

- The `path` array stores the full loop.
- Each entry is later used to compute distance from the center.
- `spawnSparkles()` adds glow while drawing.

---

### **3. Sparkle Effect**

Each movement spawns glowing particles.

```javascript
let particles = [];

function spawnSparkles(x, y){
  particles.push({
    x, y,
    dx: Math.cos(Math.random()*Math.PI*2),
    dy: Math.sin(Math.random()*Math.PI*2),
    size: 1 + Math.random()*2,
    alpha: 1
  });
}
```

**Details:**

- Each particle has position `(x, y)`, direction `(dx, dy)`, and size.
- `alpha` decreases over time → particles fade smoothly.
- Gives visual feedback but does not affect scoring.

---

### **4. Geometric Analysis**

To measure accuracy, the path is compared against an ideal circle.

#### **Step 1: Compute Radii**

For each point `(px, py)`, compute its distance from the center `(cx, cy)`:

```javascript
function getRadius(px, py, cx, cy){
  return Math.sqrt((px - cx)**2 + (py - cy)**2);
}
```

#### **Step 2: Average Radius**

```javascript
const meanR = radii.reduce((s, v) => s + v, 0) / radii.length;
```

This is the “expected radius” of the player’s circle.

#### **Step 3: Deviation**

```javascript
const meanAbsDev = radii.reduce((s, r) => s + Math.abs(r - meanR), 0) / radii.length;
```

This measures how much the circle wobbles.

#### **Step 4: Accuracy Score**

```javascript
function computeImprovedAccuracy(){
  const rel = meanAbsDev / Math.max(1, meanR);  
  return Math.max(0, 100 - rel * 100 * sigmaScale);
}
```

**Details:**

- Relative deviation ensures fairness regardless of circle size.  
- `sigmaScale` makes scoring stricter or looser depending on difficulty.  
- A perfect circle → `meanAbsDev = 0` → `score = 100%`.

---

### **5. Angular Coverage**

Drawing a complete circle requires covering all angles (0°–360°).

```javascript
function computeCoverage(path, cx, cy){
  const angles = path.map(p => Math.atan2(p.y - cy, p.x - cx));
  // normalize and check full coverage
}
```

**Details:**

- Ensures the loop isn’t partial (like drawing only half a circle).
- Missing angular coverage lowers the score.

---

### **6. Smoothness Check**

Jagged drawings are penalized.

```javascript
function computeSmoothness(path){
  let jaggedness = 0;
  for (let i = 2; i < path.length; i++){
    const dx1 = path[i-1].x - path[i-2].x;
    const dy1 = path[i-1].y - path[i-2].y;
    const dx2 = path[i].x - path[i-1].x;
    const dy2 = path[i].y - path[i-1].y;
    let angle = Math.abs(Math.atan2(dy2, dx2) - Math.atan2(dy1, dx1));
    if (angle > Math.PI) angle = 2 * Math.PI - angle;
    jaggedness += angle;
  }
  return jaggedness;
}
```

**Details:**

- Compares direction changes between consecutive path segments.  
- Sharp turns → higher jaggedness → lower smoothness score.

---

### **7. Time Bonus**

Speed matters — players who draw quicker are rewarded.

```javascript
finalScore = accuracy + (bonusFactor / elapsedTime);
```

**Details:**

- Faster loops = higher bonus.  
- Hardcore mode scales bonus more aggressively.

---

### **8. Difficulty Levels**

```javascript
const DIFFICULTIES = {
  easy: { sigmaScale: 40, timeBonus: 1.2 },
  medium: { sigmaScale: 25, timeBonus: 1.0 },
  hardcore: { sigmaScale: 10, timeBonus: 0.8 }
};
```

**Details:**

- **Easy**: forgiving scoring, large dot.  
- **Medium**: balanced challenge.  
- **Hardcore**: very strict, minimal tolerance.

---

### **9. UI Updates**

Scores are shown instantly with color-coded accuracy.

```javascript
function updateUIResult(acc, finalScore){
  accuracyEl.textContent = `${acc.toFixed(2)}%`;
  finalEl.textContent = `${finalScore.toFixed(2)}`;
}
```

---

### **Full Flow of the Game**

- **Canvas Setup** → responsive, retina-ready  
- **Path Tracking** → capture user’s drawing  
- **Sparkle Effect** → glowing trail for feedback  
- **Geometric Analysis** → radii, deviation, angular coverage  
- **Smoothness Check** → penalize jagged shapes  
- **Time Bonus** → reward quick, clean loops  
- **Final Score Calculation** → accuracy + time bonus  
- **UI Update** → show accuracy and score

