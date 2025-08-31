from utils import get_profile, update_profile

class UserProfile:
    def __init__(self, username):
        # Load existing profile or create a new one
        profile_data = get_profile(username)
        if profile_data:
            self.username = profile_data["username"]
            self.score = profile_data.get("score", 0)
            self.high_score = profile_data.get("high_score", 0)
            self.difficulty = profile_data.get("difficulty", "easy")
        else:
            self.username = username
            self.score = 0
            self.high_score = 0
            self.difficulty = "easy"
            self.save()  # Save new profile immediately

    def increase_score(self):
        self.score += 10  # 10 points per correct answer
        if self.score > self.high_score:
            self.high_score = self.score
        self.adapt_difficulty()
        self.save()

    def adapt_difficulty(self):
        if self.score >= 50:
            self.difficulty = "hard"
        elif self.score >= 20:
            self.difficulty = "medium"
        else:
            self.difficulty = "easy"

    def to_dict(self):
        """Return a dictionary of the profile data."""
        return {
            "username": self.username,
            "score": self.score,
            "high_score": self.high_score,
            "difficulty": self.difficulty
        }

    def save(self):
        """Write current profile data to the JSON file."""
        update_profile(self.to_dict())

    def save_profile(self):
        """Alias for save() so main.py works without changes."""
        self.save()
