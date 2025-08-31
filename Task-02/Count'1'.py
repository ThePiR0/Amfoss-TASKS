t = int(input())
for i in range(t):
    n = int(input())
    s = input().strip()
    cnt1 = s.count('1')
    total_ones = cnt1 * (n - 2) + n
    print(total_ones)
