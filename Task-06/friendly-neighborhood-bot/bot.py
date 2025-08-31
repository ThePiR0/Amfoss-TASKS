import discord
from discord.ext import commands
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()
TOKEN = os.getenv("DISCORD_TOKEN")

intents = discord.Intents.default()
intents.message_content = True
intents.members = True
intents.guilds = True

bot = commands.Bot(command_prefix="!", intents=intents)

allowed_roles = ["Faculty", "Administrator"]
announcement_channel = "announcements"
delete_after = 40
forbidden_words = [
    "villainous spam",
    "unauthorized link",
    "off-topic disruption",
    "menacing threats"
]

@bot.event
async def on_ready():
    print(f"{bot.user} is online and ready to assign roles!")

@bot.event
async def on_member_join(member):
    guild = member.guild
    role_name = "Aspiring Hero"
    role = discord.utils.get(guild.roles, name=role_name)
    if role:
        try:
            await member.add_roles(role)
            print(f"Assigned {role.name} to {member.name}")
        except discord.Forbidden:
            print("Missing permissions to assign roles")

    channel = discord.utils.get(guild.text_channels, name="general")
    if channel:
        try:
            await channel.send(
                f"Hi {member.mention}! Welcome to Midtown Tech. Head over to the orientation channel!"
            )
        except discord.Forbidden:
            print("Missing permissions to send messages")

@bot.event
async def on_message(message):
    if message.author.bot:
        return

    msg_content = message.content.lower()

    if any(word in msg_content for word in forbidden_words):
        try:
            await message.delete()
            await message.author.send(
                f"Hey {message.author.name}, your message in **#{message.channel.name}** was removed due to inappropriate content."
            )
            print("Message with forbidden content deleted.")
        except discord.Forbidden:
            print("No permission to delete or DM")
        return

    if message.channel.name == announcement_channel:
        if not any(role.name in allowed_roles for role in message.author.roles):
            try:
                await message.delete()
                await message.author.send("You don't have permission to post in the announcements channel.")
            except:
                pass
            return

        await asyncio.sleep(delete_after)
        try:
            fresh_message = await message.channel.fetch_message(message.id)
            if not fresh_message.pinned:
                await fresh_message.delete()
        except:
            pass

    await bot.process_commands(message)

@bot.command(name="wisdom")
async def wisdom(ctx, topic: str):
    topic = topic.lower()
    responses = {
        "rules": (
            "**Midtown Tech Rules**\n"
            "1. Be respectful.\n"
            "2. No spamming or self-promo.\n"
            "3. Stay on-topic.\n"
            "4. Listen to the mods.\n"
            "5. Don’t be a villain."  
        ),
        "resources": (
            "**Learning Resources**\n"
            "- [Python Docs](https://docs.python.org/3/)\n"
            "- [W3Schools](https://www.w3schools.com/)\n"
            "- [MDN Web Docs](https://developer.mozilla.org/)\n"
            "- Your course GitHub or LMS link here..."
        ),
        "contact": (
            "**Need Help? Contact Info**\n"
            "- DM any `@Faculty` or `@Administrator` role.\n"
            "- Or email: `admin@midtowntech.edu`\n"
            "- Emergency? Ping a mod in #support."
        )
    }

    if topic in responses:
        await ctx.send(responses[topic])
    else:
        await ctx.send(
            f"Unknown topic: `{topic}`.\nTry one of these: `rules`, `resources`, or `contact`."
        )

bot.run(TOKEN)
