## **CineScope – Movie Explorer**

CineScope is a desktop application built with Python, PySide6 (Qt for GUI), and MySQL.  
It is designed to help users explore and analyze movies with a clean, responsive interface backed by a structured database.

---

### **The Story of How CineScope Works**

---

### **Step 1: Building the Foundation with Data**

Every movie application needs reliable data. CineScope begins with a CSV file containing movie details such as:

- Title  
- Year  
- Genre  
- Rating  
- Director  
- Stars  

Before the user even interacts with the application, the `import_csv.py` script ensures that all this information is neatly stored in a **MySQL** database.

It first creates the database and table if they don’t exist:

```python
cursor.execute("""
CREATE TABLE IF NOT EXISTS movies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    release_year INT,
    genre VARCHAR(100),
    rating FLOAT,
    director VARCHAR(255),
    star1 VARCHAR(255),
    star2 VARCHAR(255),
    star3 VARCHAR(255)
)
""")
```

Each line of the CSV is then read and inserted into the table.  
From this moment on, the database becomes the **single source of truth** for CineScope.

---

### **Step 2: First Impressions Matter – The Cover Page**

When the user launches the application (`main.py`), they don’t see raw data immediately.  
Instead, they are greeted with a **cover page** designed to set the tone.

- The background is animated with a looping **GIF**  
- A large, bold title “**CineScope**” is displayed  
- A short tagline explains what the app is about  
- A button appears: **Start Exploring**

```python
start_btn = QPushButton("Start Exploring")
start_btn.clicked.connect(self.on_start)
```

This design choice slows things down in the best way possible.  
Instead of being thrown into a dashboard, the user is welcomed and given a moment to engage.

When the button is clicked, the **cover page closes** and the **dashboard takes over**.

---

### **Step 3: Enter the Dashboard**

The dashboard (`dashboard.py`) is where CineScope truly comes alive.

At the top, the user finds **search and filter controls**.  
Each field corresponds to an important attribute of a movie:

- Title  
- Actor  
- Genre  
- Year  

Whenever the user types into one of these fields, the application quietly constructs an **SQL query** in the background.

Example:  
If the user types `DiCaprio` into the actor field:

```sql
(star1 LIKE '%DiCaprio%' OR star2 LIKE '%DiCaprio%' OR star3 LIKE '%DiCaprio%')
```

The query is executed **immediately**, and the results update without needing a page reload.  
This makes the dashboard feel **responsive and interactive**.

---

### **Step 4: Movies as Cards, Not Just Rows**

Rather than dumping text in a table, CineScope presents each movie as a **card**.  
This **card-based layout** makes browsing more visual and less tiring.

Each card shows:

- The **title** in bold  
- **Year** and **genre** beneath it  
- **Rating** highlighted prominently  
- **Director’s** name

```python
title = QLabel(movie["title"])
rating = QLabel(f"{movie['rating']}")
director = QLabel(f"Director: {movie['director']}")
```

The user doesn’t just skim a wall of text — they see **distinct, clickable blocks**.

---

### **Step 5: Diving Deeper – The Movie Details Dialog**

If curiosity strikes, the user can **click on a card**.  
This action opens a **details dialog** that expands on the movie’s information.

Here, they see:

- The **full title**  
- **Year** of release  
- **Genre**  
- **Rating**  
- **Director**  
- All three **main actors**

```python
layout.addWidget(QLabel(f"Year: {movie['release_year']}"))
layout.addWidget(QLabel(f"Genre: {movie['genre']}"))
layout.addWidget(QLabel(f"Stars: {movie['star1']}, {movie['star2']}, {movie['star3']}"))
```

This **separation between cards and dialogs** ensures that browsing stays light,  
but **detailed information is always just a click away**.

---

### **Step 6: A Thoughtful Design**

CineScope adopts a **dark theme** inspired by modern streaming platforms.  
This not only improves readability but also makes ratings, highlights,  
and movie posters (if added later) stand out more clearly.

```python
palette.setColor(QPalette.Window, QColor(20, 20, 20))
palette.setColor(QPalette.WindowText, Qt.white)
```

The goal is to create an interface where the user feels **comfortable exploring for long periods without fatigue and keeping it interesting.**.

---

### **The Complete Flow**

- ✅ **Data is prepared** → `import_csv.py` sets up the MySQL database with movie details.  
- ✅ **The application opens** → `main.py` greets the user with an animated cover page.  
- ✅ **The dashboard loads** → Users see search filters and a grid of movie cards.  
- ✅ **The user searches** → Real-time SQL queries fetch matching results.  
- ✅ **Movies appear as cards** → Each movie gets a distinct visual space.  
- ✅ **The user clicks a card** → A dialog opens with full movie details.

---

