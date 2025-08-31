# handles quiz logic and api calls
import requests
import html
import threading
import time
from rich.console import Console
from rich.prompt import Prompt

console = Console()
CATEGORY_URL = "https://opentdb.com/api_category.php"
QUESTION_URL = "https://opentdb.com/api.php"

class QuizEngine:
    def __init__(self, profile, num_questions, difficulty, time_limit, category_id):
        self.profile = profile
        self.num_questions = num_questions
        self.difficulty = difficulty
        self.time_limit = time_limit
        self.category_id = category_id
        self.questions = []
        self.score = profile.score

    def fetch_questions(self):
        """Fetch quiz questions from OpenTDB API"""
        params = {
            "amount": self.num_questions,
            "difficulty": self.difficulty.lower(),
            "type": "multiple",
            "category": self.category_id
        }

        try:
            response = requests.get(QUESTION_URL, params=params)
            data = response.json()
            if data["response_code"] != 0:
                console.print("[red]No questions found. Try different settings.[/red]")
                return False
            self.questions = data["results"]
            return True
        except requests.RequestException as e:
            console.print(f"[red]Error fetching questions: {e}[/red]")
            return False

    def ask_question(self, question_data):
        """Display a question, enforce time limit, and return True/False based on answer"""
        question = html.unescape(question_data["question"])
        correct_answer = html.unescape(question_data["correct_answer"])
        options = [html.unescape(ans) for ans in question_data["incorrect_answers"]]
        options.append(correct_answer)
        # Shuffle options
        import random
        random.shuffle(options)

        console.print(f"\n[bold yellow]{question}[/bold yellow]")
        for i, opt in enumerate(options, 1):
            console.print(f"{i}. {opt}")

        # Store user answer in thread-safe way
        user_answer = {"value": None}

        def get_input():
            ans = Prompt.ask("\nYour answer (number)")
            if ans.isdigit() and 1 <= int(ans) <= len(options):
                user_answer["value"] = options[int(ans) - 1]

        # Start input thread
        t = threading.Thread(target=get_input)
        t.start()

        start_time = time.time()
        while t.is_alive() and time.time() - start_time < self.time_limit:
            time.sleep(0.1)

        if t.is_alive():
            console.print(f"\n[red]Time's up![/red] The correct answer was: [green]{correct_answer}[/green]")
            return False

        if user_answer["value"] == correct_answer:
            console.print("[green]Correct![/green]")
            return True
        else:
            console.print(f"[red]Oops![/red] The correct answer was: [green]{correct_answer}[/green]")
            return False

    def run(self):
        """Run the quiz"""
        if not self.fetch_questions():
            return

        for idx, q in enumerate(self.questions, 1):
            console.print(f"\n[bold cyan]Question {idx}/{self.num_questions}[/bold cyan]")
            if self.ask_question(q):
                self.score += 1

        self.profile.score = self.score
        console.print(f"\n[bold magenta]Final Score: {self.score}/{self.num_questions}[/bold magenta]")
