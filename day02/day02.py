import sys


def read_input() -> str:
    with open(sys.argv[1]) as f:
        return f.read().strip()


def parse_input(raw: str):
    for id_range in raw.split(","):
        starts, finishes = id_range.split("-")
        yield range(int(starts), int(finishes) + 1)


def part1(s: str) -> bool:
    return s[: len(s) // 2] == s[len(s) // 2 :]


def part2(s: str) -> bool:
    for substr_length in range(1, len(s) // 2 + 1):
        if len(s) % substr_length != 0:
            continue
        subs = [s[i : i + substr_length] for i in range(0, len(s), substr_length)]
        if all(ss == subs[0] for ss in subs):
            return True
    return False


def solve(parsed, checker):
    total = 0
    for r in parsed:
        for x in r:
            if checker(str(x)):
                total += x
    return total


if __name__ == "__main__":
    raw = read_input()
    print(solve(parse_input(raw), part1))
    print(solve(parse_input(raw), part2))
