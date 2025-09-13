## **Solutions and Explanations for HackerRank Challenges**

This README provides the solutions and detailed explanations for the methods I used to solve five programming challenges on HackerRank.

---

### **Question: The Beautiful Number**

---

**Logic:**

1. **Sort the digits**  
   Start with the digits in ascending order so we always consider smaller digits first.  
   ```python
   digits = sorted(s)
   ```

2. **Define requirements for each position**  
   For position `i (1 → 10)`, the required digit must be ≥ `10 − i`.  
   ```python
   need = 10 - i
   ```

3. **Pick digits greedily**  
   Choose the smallest digit that satisfies the requirement, add it to the result, and remove it from the pool so it isn’t reused.  
   ```python
   for j, d in enumerate(digits):
       if int(d) >= need:
           result.append(d)
           digits.pop(j)
           break
   ```

4. **Build the final number**  
   Join the selected digits into a single string using:  
   ```python
   return "".join(result)
   ```

> In short, we greedily build the number position by position, ensuring each digit meets its minimum requirement while keeping the result as small as possible.

---

### **Question: Count '1'**

---

**Logic:**

1. **Read inputs**  
   First, take the number of test cases `t`. For each test case, read `n` and the string `s`.  
   ```python
   t = int(input())
   for i in range(t):
       n = int(input())
       s = input().strip()
   ```

2. **Count the number of '1's**  
   Use Python’s string method `.count('1')`.

3. **Compute total ones using derived formula**  
   ```python
   total_ones = (count of '1') × (n − 2) + n
   ```
   I derived this formula since I noticed every string has a baseline contribution equal to its length, `n`. Then, by testing examples, I saw that each '1' adds roughly `(n - 2)` extra to the total.

4. **Print the result**

---

### **Question: The Quest For Perfect Arrays**

---

**Logic:**

1. **Initialize the answer**  
   ```python
   ans = n
   ```

2. **Handle even numbers**  
   - Filter out all even numbers.  
   - If there are any, find the smallest (`L`) and largest (`R`) even number.  
   - Count how many numbers in the original array are within `[L, R]`.  
   - The number to remove = `n - keep`.  
   - Update `ans` if it’s smaller.

3. **Handle odd numbers**  
   Repeat the same process as even numbers.

4. **Output the result**

---

### **Question: The Blender's Limit**

---

**Logic:**

1. **Read the inputs**

2. **Choose the slower rate**  
   Since the faster rate can’t help reduce the steps below the slower rate, we take:  
   ```python
   rate = min(x, y)
   ```

3. **Compute the number of steps**  
   Divide the total items `n` by the chosen rate and round up to account for any remaining items:  
   ```python
   import math  
   print(math.ceil(n / rate))
   ```

4. **Output the result**

---

### **Question: Race 10**

---

**Logic:**

1. **Read inputs**

2. **Calculate Alice’s distances:**  
   ```python
   alice_x = abs(a - x)  
   alice_y = abs(a - y)
   ```

3. **Check every possible Bob choice**  
   Bob can pick numbers from `1` to `100` except Alice’s number. If Bob’s distances to both `x` and `y` are smaller than Alice’s, we have a solution.  
   ```python
   for bob in range(1, 101):
       if bob == a:
           continue  
       if abs(bob - x) < alice_x and abs(bob - y) < alice_y:
           print("YES")
           break
   else:
       print("NO")
   ```

4. **Print the result**
