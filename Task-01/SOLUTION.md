Task Report: The CommandLineCup

This document outlines the systematic approach I took to complete the challenges within the cloned spellbook Git repository. The process involved solving riddles, navigating through folders using terminal commands, executing Python scripts, and applying Git operations to uncover the final encoded message.

Part 1: The Derivative Spell

The first challenge involved solving a calculus-based riddle, which required differentiating an equation and substituting values. After obtaining the correct result:

I used cd to navigate through the directory paths based on the clue.

Inside the relevant directory, I used cat to read the .txt file that provided the necessary hint or spell fragment.

After this, I returned to the main directory using cd .. and navigated into the spellbook/ folder.

I ran the Python script associated with this part using:

python3 Impedimenta.py
This produced the first part of the secret code.

Part 2: The Semiconductor Spell

The second challenge required knowledge of semiconductors. Based on the riddle, the correct element was Germanium, which has an atomic number of 32.

I mapped the atomic number to the corresponding directory and spell number.

Navigated into the spellbook/ directory.

Executed the correct spell script using:

python3 Stupefy.py
This revealed the second part of the code.

Part 3: Defense Against the Dark Arts (Git Branching)

For the third challenge, I needed to explore a specific Git branch named defenseAgainstTheDarkArts.

First, I listed all remote branches using:

git branch -r
I switched to the required branch using:

git checkout defenseAgainstTheDarkArts
The spell required to combat the Boggart, Riddikulus, was located in the spellbook/ folder. I added it using:


git add spellbook/Riddikulus.py
git commit -m "Added Riddikulus spell"
Then, I returned to the main branch:


git checkout main

I copied the spell from the other branch using:


git checkout defenseAgainstTheDarkArts -- spellbook/Riddikulus.py

After committing the file, I executed it, revealing the third piece of the secret code.

Part 4: Git Logs and Hidden Spells

In the fourth part, my knowledge of the wizarding world helped — I was aware of the required spell from the movies. However, to deepen my Git skills, I examined the commit history using:


git log --oneline
This helped me uncover the relevant commit and corresponding file. I followed the same process of adding, committing, and executing the spell, which revealed the final part of the secret code.

📜 Final Step: Decoding the Secret Message
With all four parts of the code obtained and saved in a file (finalcode.txt), I:

Concatenated all four lines using:


cat Part_1.txt Part_2.txt Part_3.txt Part_4.txt > finalcode.txt
Decoded the full Base64 string using:


echo "<base64_encoded_string>" | base64 --decode

This revealed a URL, successfully completing the challenge. I have attached a screenshot of the final decoded output and the destination it led to in this folder.


