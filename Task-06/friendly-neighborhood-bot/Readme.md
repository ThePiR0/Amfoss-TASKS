Midtown Tech Discord Bot

This project is a moderation and utility bot for Discord servers, designed to automate member onboarding, enforce community guidelines, and provide helpful resources on-demand. It leverages Python, discord.py (via discord.ext.commands), and environment variables for secure token handling.

Overview

The bot provides the following features:

Automated Role Assignment

When a new member joins, they are automatically assigned the role "Aspiring Hero".

Welcomes new members in a designated channel (general) with a custom message.

Content Moderation

Detects forbidden words in messages (e.g., spam or inappropriate language) and deletes them.

Notifies the sender via direct message about the deletion.

Announcement Channel Management

Only users with specific roles (e.g., Faculty, Administrator) can post in the announcements channel.

Posts in this channel are automatically deleted after a set period (e.g., 40 seconds), unless pinned.

Command-Based Resource Access

Users can request important server information using a !wisdom <topic> command.

Supported topics:

rules – server guidelines

resources – learning resources links

contact – contact information for admins and moderators
Code Structure and Explanation
1. Bot Initialization
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


Intents allow the bot to access member and message events.

Prefix ! defines how users will trigger commands.

2. Role Assignment on Join
@bot.event
async def on_member_join(member):
    role = discord.utils.get(member.guild.roles, name="Aspiring Hero")
    if role:
        await member.add_roles(role)


Automatically assigns a default role to new members.

Sends a welcome message in the general channel.

3. Message Moderation
forbidden_words = ["villainous spam", "unauthorized link", "off-topic disruption", "menacing threats"]

@bot.event
async def on_message(message):
    if any(word in message.content.lower() for word in forbidden_words):
        await message.delete()
        await message.author.send("Your message was removed due to inappropriate content.")


Monitors messages for prohibited words and deletes them.

Notifies users privately to maintain transparency.

4. Announcement Channel Enforcement
allowed_roles = ["Faculty", "Administrator"]
announcement_channel = "announcements"
delete_after = 40

if message.channel.name == announcement_channel:
    if not any(role.name in allowed_roles for role in message.author.roles):
        await message.delete()


Only specified roles can post announcements.

Messages auto-delete after a set time unless pinned.

5. Wisdom Command
@bot.command(name="wisdom")
async def wisdom(ctx, topic: str):
    responses = {"rules": "...", "resources": "...", "contact": "..."}
    if topic in responses:
        await ctx.send(responses[topic])


Users can fetch server rules, learning resources, and contact info using !wisdom <topic>.

Customizing the Bot

Forbidden Words: Modify the forbidden_words list.

Roles and Channels: Update allowed_roles or announcement_channel as per your server.

Auto-Delete Time: Change delete_after to adjust how long announcement messages stay.

Command Responses: Add new topics in the responses dictionary in the !wisdom command.
