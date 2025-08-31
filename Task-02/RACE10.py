t = int(input())

for _ in range(t):
    a, x, y = map(int, input().split())
    alice_x = abs(a - x)
    alice_y = abs(a - y)

    for bob in range(1, 101):
        if bob == a:
            continue  

        if abs(bob - x) < alice_x and abs(bob - y) < alice_y:
            print("YES")
            break
    else:
        print("NO")
