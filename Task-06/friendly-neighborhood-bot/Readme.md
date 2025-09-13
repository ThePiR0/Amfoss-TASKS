## **Midtown Tech Discord Bot**

**Midtown Tech Discord Bot** is a moderation and utility bot for Discord servers, designed to automate member onboarding, enforce community guidelines, and provide helpful resources on-demand.

It leverages **Python**, **discord.py** (`discord.ext.commands`), and **environment variables** for secure token handling.

---

### **Overview**

The bot provides the following core features:

- 🔹 **Automated Role Assignment**
- 🔹 **Content Moderation**
- 🔹 **Announcement Channel Control**
- 🔹 **Command-Based Resource Access**

---

### **Features Explained**

---

### **1. Automated Role Assignment**

- When a new member joins, they are automatically assigned the role `"Aspiring Hero"`.
- A custom **welcome message** is posted in the `#general` channel.

```python
@bot.event
async def on_member_join(member):
    role = discord.utils.get(member.guild.roles, name="Aspiring Hero")
    if role:
        await member.add_roles(role)
```

---

### **2. Content Moderation**

- Detects forbidden words in messages such as spam or inappropriate language.
- Deletes the offending message.
- Notifies the sender **via DM**.

```python
forbidden_words = ["villainous spam", "unauthorized link", "off-topic disruption", "menacing threats"]

@bot.event
async def on_message(message):
    if any(word in message.content.lower() for word in forbidden_words):
        await message.delete()
        await message.author.send("Your message was removed due to inappropriate content.")
```

---

### **3. Announcement Channel Management**

- Only users with specific roles (e.g., `"Faculty"`, `"Administrator"`) can post in the `#announcements` channel.
- Posts in this channel are **automatically deleted** after 40 seconds unless pinned.

```python
allowed_roles = ["Faculty", "Administrator"]
announcement_channel = "announcements"
delete_after = 40

if message.channel.name == announcement_channel:
    if not any(role.name in allowed_roles for role in message.author.roles):
        await message.delete()
```

---

### **4. Wisdom Command (`!wisdom <topic>`)**

- Users can request important server information using a simple command.

Supported topics:

- `rules` – Server guidelines  
- `resources` – Helpful learning resources  
- `contact` – Admin/mod contact information  

```python
@bot.command(name="wisdom")
async def wisdom(ctx, topic: str):
    responses = {
        "rules": "Follow community guidelines. Be respectful.",
        "resources": "Check out: https://midtowntech.edu/resources",
        "contact": "For help, DM an Administrator or contact staff@midtowntech.edu"
    }
    if topic in responses:
        await ctx.send(responses[topic])
```

---

### **Code Structure**

- `main.py` – Initializes bot, handles events and command registration.
- `.env` – Stores the bot token securely.
- `discord.ext.commands` – Used to register and manage bot commands and events.

```python
import discord
from discord.ext import commands
from dotenv import load_dotenv
import os

load_dotenv()
TOKEN = os.getenv("DISCORD_TOKEN")

intents = discord.Intents.default()
intents.message_content = True
intents.members = True
intents.guilds = True

bot = commands.Bot(command_prefix="!", intents=intents)
```

---

### **Customizing the Bot**

- 🔧 **Forbidden Words**: Edit the `forbidden_words` list.
- 🔧 **Roles/Channels**: Change `allowed_roles` or `announcement_channel` values.
- 🔧 **Auto-Delete Timer**: Modify the `delete_after` value (in seconds).
- 🔧 **Wisdom Topics**: Add or remove entries in the `responses` dictionary inside the `!wisdom` command.

---

### **Security**

Used a `.env` file to store the bot token safely:

```
DISCORD_TOKEN=your-bot-token-here
```

Made sure to **add `.env` to the `.gitignore`** so it's not pushed to GitHub.

---


