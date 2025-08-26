# main file to run timetickquiz-2 pro
from user_profile import UserProfile
from quiz_engine import QuizEngine
from rich.console import Console
from rich.prompt import Prompt, IntPrompt
from utils import get_categories

console = Console()

def main():
    console.print("[bold blue]Welcome to TimeTickQuiz Pro![/bold blue]\n")

    # Prompt for username
    username = Prompt.ask("Enter your username").strip()

    # Create user profile
    user = UserProfile(username)
    console.print(f"[green]Welcome {user.username}! Your current score: {user.score}[/green]\n")

    # Get quiz settings
    num_questions = IntPrompt.ask("How many questions? (1-20)", default=5)
    difficulty = Prompt.ask("Choose difficulty", choices=["easy", "medium", "hard"], default="medium")
    time_limit = IntPrompt.ask("Time limit per question (seconds)", default=10)

    # Show categories
    categories = get_categories()
    console.print("\n[bold magenta]Choose a category:[/bold magenta]")
    for cid, cname in categories.items():
        console.print(f"[cyan]{cid}[/cyan]: {cname}")

    # Let user pick one
    category_id = IntPrompt.ask(
        "Enter category ID",
        choices=[str(c) for c in categories.keys()],
    )

    # Start the quiz
    quiz = QuizEngine(user, num_questions, difficulty, time_limit, category_id)
    quiz.run()
    # Save updated profile
    user.save_profile()


if __name__ == "__main__":
    main()
