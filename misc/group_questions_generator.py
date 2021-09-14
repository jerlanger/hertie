import random
import sys


def partition(list_in, n):
    random.shuffle(list_in)
    shuffled = [list_in[i::n] for i in range(n)]
    for i in range(n):
        print(f"User {i+1}: {shuffled[i]}")


def set_params(range_stop, parts):
    range_in = list(range(1, range_stop+1))
    partition(range_in, parts)
    

if __name__ == '__main__':

    while True:
        try:
            range_stop = int(input("enter max questions:"))
            parts = int(input("enter number of participants:"))
            if range_stop <= sys.maxsize and parts <= sys.maxsize:
                break
            else:
                print("Integer too large! Please choose again.")
        except:
            print("Invalid selection. Please use only integers!")

    set_params(range_stop, parts)
