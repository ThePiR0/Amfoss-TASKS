def smallest_beautiful_number(s: str) -> str:
    digits = sorted(s)
    result = []
    for i in range(1, 11):
        need = 10 - i
        for j, d in enumerate(digits):
            if int(d) >= need:
                result.append(d)
                digits.pop(j)
                break
    return "".join(result)

t = int(input().strip())
for _ in range(t):
    s = input().strip()
    print(smallest_beautiful_number(s))
