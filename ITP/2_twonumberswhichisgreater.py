a = int(input("Enter a"))
b = int(input("Enter b"))
c = 0 

if a >= c and b >= c:
    if a%b == a:
        print("a is less than b")
    else:
        print("a is greater than b")

if a < c and b < c:
    if a%b == a:
        print("a is greater than b")
    else:
        print("a is less than b")

if a >= c and b < c: print("a is greater than b")
if a < c and b >= c: print("a is less than b")

