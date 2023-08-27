from math import sqrt, ceil

if __name__ == '__main__':

    radius = 5

    for i in range(-radius, radius + 1):
        num = ceil(sqrt(radius ** 2 - i ** 2))
        print("{:^{}}".format("".join("1" for _ in range(2 * num)), 2 * radius))
