## **TimeTickQuiz Pro**

**TimeTickQuiz Pro** is a Python-based command-line trivia game that fetches real-time questions from the [Open Trivia Database (OpenTDB)](https://opentdb.com/).  
It is designed to provide an engaging quiz experience with features like timed responses, adaptive difficulty, score persistence, and category selection.

---

### **Project Overview**

The project is divided into **four core components**:

- `main.py` – The entry point of the program. Handles user input, displays options, and initializes the quiz.  
- `quiz_engine.py` – Implements the core quiz logic: fetching questions, presenting them, applying time limits, and scoring responses.  
- `user_profile.py` – Manages user data such as scores, high scores, difficulty level, and profile persistence.  
- `utils.py` – Provides helper functions for saving/loading user profiles and fetching quiz categories.

Together, these files create a seamless quiz system where users can repeatedly play, improve their scores, and track progress over time.

---

### **How It Works**

---

### **1. Entry Point: `main.py`**

The game starts by prompting the player for their **username**.  
If a profile with that username exists, it is loaded; otherwise, a new one is created.

```python
username = Prompt.ask("Enter your username").strip()
user = UserProfile(username)
```

The player is then asked to configure the quiz:

- Number of questions (1–20)  
- Difficulty (easy, medium, hard)  
- Time limit per question (in seconds)  
- Category (fetched dynamically from OpenTDB)

Example:

```python
num_questions = IntPrompt.ask("How many questions? (1-20)", default=5)
difficulty = Prompt.ask("Choose difficulty", choices=["easy", "medium", "hard"], default="medium")
time_limit = IntPrompt.ask("Time limit per question (seconds)", default=10)
```

Once configured, `QuizEngine` is initialized, and the quiz begins.

---

### **2. Quiz Flow: `quiz_engine.py`**

The `QuizEngine` is responsible for retrieving questions and enforcing the quiz rules.

#### **Fetching Questions**

Questions are fetched from the OpenTDB API using the selected settings:

```python
params = {
    "amount": self.num_questions,
    "difficulty": self.difficulty.lower(),
    "type": "multiple",
    "category": self.category_id
}
response = requests.get(QUESTION_URL, params=params)
self.questions = response.json()["results"]
```

#### **Presenting Questions**

Each question is displayed with **shuffled multiple-choice answers**.  
Input is collected on a separate thread to enforce the **time limit**.

```python
def ask_question(self, question_data):
    question = html.unescape(question_data["question"])
    correct_answer = html.unescape(question_data["correct_answer"])
    options = [html.unescape(ans) for ans in question_data["incorrect_answers"]]
    options.append(correct_answer)
    random.shuffle(options)
```

If the user fails to answer in time, the question is **automatically marked incorrect**.

#### **Scoring**

- Each correct answer gives **+1 point**
- Final score is displayed after the quiz ends

---

### **3. User Profiles: `user_profile.py`**

Each user has a **persistent profile** stored in `profiles.json`. Profiles include:

- Username  
- Current score  
- High score  
- Adaptive difficulty level  

When players perform well, their difficulty **adapts automatically**:

```python
def adapt_difficulty(self):
    if self.score >= 50:
        self.difficulty = "hard"
    elif self.score >= 20:
        self.difficulty = "medium"
    else:
        self.difficulty = "easy"
```

Profiles are **saved after each game**, ensuring progress is preserved across sessions.

---

### **4. Utilities: `utils.py`**

The utilities module supports:

- Loading/saving profiles from `profiles.json`  
- Updating profile scores  
- Fetching the latest quiz categories from OpenTDB

Example – Fetching available categories:

```python
def get_categories():
    response = requests.get(CATEGORY_URL, timeout=5)
    data = response.json()
    return {cat["id"]: cat["name"] for cat in data.get("trivia_categories", [])}
```

This ensures users always get **up-to-date** trivia categories.

---

### **Execution Flow**

1. `main.py` starts → prompts user for input → loads profile  
2. User chooses quiz settings → question count, difficulty, timer, category  
3. `QuizEngine` fetches questions and runs the quiz  
4. Each answer is timed, checked, and scored  
5. Profile is updated → score, difficulty, high score saved

---


