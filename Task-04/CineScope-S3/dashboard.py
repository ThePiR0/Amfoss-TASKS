# dashboard_with_advanced_search.py
import sys
import mysql.connector
from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QLineEdit,
    QScrollArea, QGridLayout, QLabel, QFrame,
    QHBoxLayout, QDialog, QPushButton, QFormLayout
)
from PySide6.QtGui import QFont, QColor, QPalette
from PySide6.QtCore import Qt


class MovieCard(QFrame):
    def __init__(self, movie, parent=None):
        super().__init__(parent)
        self.movie = movie
        self.setFrameShape(QFrame.StyledPanel)
        self.setStyleSheet("""
            QFrame {
                background-color: #2b2b2b;
                border-radius: 12px;
                padding: 12px;
            }
            QFrame:hover {
                background-color: #383838;
                border: 1px solid #e50914;
            }
        """)

        layout = QVBoxLayout(self)

        title = QLabel(movie["title"])
        title.setFont(QFont("Montserrat", 14, QFont.Bold))
        title.setWordWrap(True)
        layout.addWidget(title)

        info = QLabel(f"{movie['release_year']} • {movie['genre']}")
        info.setFont(QFont("Open Sans", 10))
        layout.addWidget(info)

        rating = QLabel(f"⭐ {movie['rating']}")
        rating.setFont(QFont("Open Sans", 11, QFont.Bold))
        rating.setStyleSheet("color: #FFD700;")
        layout.addWidget(rating)

        director = QLabel(f"🎥 {movie['director']}")
        director.setFont(QFont("Open Sans", 9))
        layout.addWidget(director)

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            dlg = MovieDetailsDialog(self.movie, self)
            dlg.exec()


class MovieDetailsDialog(QDialog):
    def __init__(self, movie, parent=None):
        super().__init__(parent)
        self.setWindowTitle(movie["title"])
        self.resize(400, 300)

        layout = QVBoxLayout(self)

        title = QLabel(movie["title"])
        title.setFont(QFont("Montserrat", 16, QFont.Bold))
        layout.addWidget(title)

        layout.addWidget(QLabel(f"📅 Year: {movie['release_year']}"))
        layout.addWidget(QLabel(f"🎞 Genre: {movie['genre']}"))
        layout.addWidget(QLabel(f"⭐ Rating: {movie['rating']}"))
        layout.addWidget(QLabel(f"🎥 Director: {movie['director']}"))
        layout.addWidget(QLabel(f"👤 Stars: {movie['star1']}, {movie['star2']}, {movie['star3']}"))

        close_btn = QPushButton("Close")
        close_btn.clicked.connect(self.close)
        layout.addWidget(close_btn)


class Dashboard(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("CineScope 🎬")
        self.resize(1000, 700)

        # 🌑 Dark theme
        self.set_dark_theme()

        # 🔗 Database
        self.conn = mysql.connector.connect(
            host="localhost",
            user="cinescope",
            password="StrongPass123!",
            database="cinescope"
        )
        self.cursor = self.conn.cursor(dictionary=True)

        # Main Layout
        layout = QVBoxLayout(self)

        # 🔍 Advanced Search controls
        form_layout = QFormLayout()

        self.title_input = QLineEdit()
        self.title_input.setPlaceholderText("Enter movie title...")
        self.title_input.textChanged.connect(self.load_movies)
        form_layout.addRow("Title:", self.title_input)

        self.actor_input = QLineEdit()
        self.actor_input.setPlaceholderText("Enter actor name...")
        self.actor_input.textChanged.connect(self.load_movies)
        form_layout.addRow("Actor:", self.actor_input)

        self.genre_input = QLineEdit()
        self.genre_input.setPlaceholderText("Enter genre...")
        self.genre_input.textChanged.connect(self.load_movies)
        form_layout.addRow("Genre:", self.genre_input)

        self.year_input = QLineEdit()
        self.year_input.setPlaceholderText("Enter year...")
        self.year_input.textChanged.connect(self.load_movies)
        form_layout.addRow("Year:", self.year_input)

        layout.addLayout(form_layout)

        # Scrollable area
        self.scroll = QScrollArea()
        self.scroll.setWidgetResizable(True)
        layout.addWidget(self.scroll)

        # Container for movie cards
        self.container = QWidget()
        self.grid = QGridLayout(self.container)
        self.scroll.setWidget(self.container)

        # Load movies initially
        self.load_movies()

    def set_dark_theme(self):
        palette = QPalette()
        palette.setColor(QPalette.Window, QColor(20, 20, 20))
        palette.setColor(QPalette.WindowText, Qt.white)
        palette.setColor(QPalette.Base, QColor(30, 30, 30))
        palette.setColor(QPalette.AlternateBase, QColor(45, 45, 45))
        palette.setColor(QPalette.Text, Qt.white)
        palette.setColor(QPalette.Button, QColor(45, 45, 45))
        palette.setColor(QPalette.ButtonText, Qt.white)
        self.setPalette(palette)

    def load_movies(self):
        base_query = "SELECT * FROM movies"
        conditions = []

        # Collect conditions from all inputs
        if self.title_input.text().strip():
            conditions.append(f"title LIKE '%{self.title_input.text().strip()}%'")

        if self.actor_input.text().strip():
            actor = self.actor_input.text().strip()
            conditions.append(f"(star1 LIKE '%{actor}%' OR star2 LIKE '%{actor}%' OR star3 LIKE '%{actor}%')")

        if self.genre_input.text().strip():
            conditions.append(f"genre LIKE '%{self.genre_input.text().strip()}%'")

        if self.year_input.text().strip():
            if self.year_input.text().isdigit():
                conditions.append(f"release_year = {self.year_input.text().strip()}")

        if conditions:
            base_query += " WHERE " + " AND ".join(conditions)

        self.cursor.execute(base_query)
        movies = self.cursor.fetchall()

        # Clear grid
        for i in reversed(range(self.grid.count())):
            widget = self.grid.itemAt(i).widget()
            if widget:
                widget.deleteLater()

        # Add movie cards
        row, col = 0, 0
        for movie in movies:
            card = MovieCard(movie)
            self.grid.addWidget(card, row, col)
            col += 1
            if col > 2:  # 3 per row
                col = 0
                row += 1


if __name__ == "__main__":
    app = QApplication(sys.argv)
    dashboard = Dashboard()
    dashboard.show()
    sys.exit(app.exec())
