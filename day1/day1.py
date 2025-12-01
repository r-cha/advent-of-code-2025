import sys
from typing import Literal


def read_input():
    with open(sys.argv[1]) as f:
        return f.read().strip()


type Position = int


class Rotation(int):
    def __new__(cls, direction: Literal["L", "R"], amount: int):
        value = -amount if direction == "L" else amount
        return super().__new__(cls, value)

    def __repr__(self) -> str:
        char = "L" if self < 0 else "R"
        return f"{char}{abs(self)}"


def parse_input(raw: str) -> list[Rotation]:
    return [
        Rotation("L" if line[0] == "L" else "R", int(line[1:]))
        for line in raw.splitlines()
    ]


def rotate(position: Position, rotation: Rotation) -> tuple[Position, int]:
    total = position + rotation
    new_position = total % 100

    current_lap = (position - int(rotation < 0)) // 100
    new_lap = (total - int(rotation < 0)) // 100
    wraps = new_lap - current_lap

    return new_position, abs(wraps)


def solve(parsed_input: list[Rotation]):
    dial_position = 50
    zeroes = 0
    total_wraps = 0
    print(f"The dial starts by pointing at {dial_position}.")
    for rotation in parsed_input:
        dial_position, wraps = rotate(dial_position, rotation)
        total_wraps += wraps
        print(
            f"The dial is rotated {rotation} to point at {dial_position}"
            f"{f'; during this rotation, it points at 0 {wraps} times.' if wraps else '.'}"
        )
        if dial_position == 0:
            zeroes += 1
    return zeroes, total_wraps


if __name__ == "__main__":
    raw = read_input()
    parsed = parse_input(raw)
    print(solve(parsed))
