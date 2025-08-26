# import_csv.py
import csv
import mysql.connector

DB_NAME = "cinescope_db"
TABLE_NAME = "movies"

conn = mysql.connector.connect(
    host="localhost",
    user="cinescope",
    password="StrongPass123!",
)
cursor = conn.cursor()

# create DB if not exists
cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
cursor.execute(f"USE {DB_NAME}")

# create movies table
cursor.execute(f"""
CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
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

# insert from CSV
with open("movies.csv", "r", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        cursor.execute(f"""
            INSERT INTO {TABLE_NAME} 
            (title, release_year, genre, rating, director, star1, star2, star3)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            row["Series_Title"],
            int(row["Released_Year"]) if row["Released_Year"].isdigit() else None,
            row["Genre"],
            float(row["IMDB_Rating"]) if row["IMDB_Rating"] else None,
            row["Director"],
            row["Star1"],
            row["Star2"],
            row["Star3"]
        ))

conn.commit()
cursor.close()
conn.close()
print("Movies imported successfully ✅")
