# utility functions for quiz
import json
import os
import requests

PROFILE_FILE = os.path.join(os.path.dirname(__file__), '../profiles.json')
CATEGORY_URL = "https://opentdb.com/api_category.php"


def load_profiles():
    """Load profiles from profiles.json"""
    if not os.path.exists(PROFILE_FILE):
        return []
    try:
        with open(PROFILE_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return []


def save_profiles(profiles):
    """Save profiles to profiles.json"""
    os.makedirs(os.path.dirname(PROFILE_FILE), exist_ok=True)
    with open(PROFILE_FILE, 'w', encoding='utf-8') as f:
        json.dump(profiles, f, indent=4)


def get_profile(username):
    """Find profile by username"""
    profiles = load_profiles()
    for profile in profiles:
        if profile.get("username") == username:
            return profile
    return None


def update_profile(new_profile):
    """Update or add profile to profiles.json"""
    profiles = load_profiles()
    for idx, profile in enumerate(profiles):
        if profile.get("username") == new_profile.get("username"):
            profiles[idx] = new_profile
            save_profiles(profiles)
            return
    profiles.append(new_profile)
    save_profiles(profiles)


def get_categories():
    """Fetch quiz categories from Open Trivia DB"""
    try:
        response = requests.get(CATEGORY_URL, timeout=5)
        response.raise_for_status()
        data = response.json()
        categories = data.get("trivia_categories", [])
        return {cat["id"]: cat["name"] for cat in categories}
    except requests.RequestException as e:
        print(f"Error fetching categories: {e}")
        return {}

