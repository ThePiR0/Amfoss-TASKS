t = int(input())
for _ in range(t):
    n = int(input())
    a = list(map(int, input().split()))
    ans = n  
    evens = [x for x in a if x % 2 == 0]
    if evens:
        L = min(evens)
        R = max(evens)
        keep = sum(1 for x in a if L <= x <= R)
        ans = min(ans, n - keep)
    odds = [x for x in a if x % 2 == 1]
    if odds:
        L = min(odds)
        R = max(odds)
        keep = sum(1 for x in a if L <= x <= R)
        ans = min(ans, n - keep)
    print(ans)
