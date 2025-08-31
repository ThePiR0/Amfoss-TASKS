import math

t = int(input())
for _ in range(t):
    n = int(input())
    x, y = map(int, input().split())
    rate = min(x, y)
    print(math.ceil(n / rate))
