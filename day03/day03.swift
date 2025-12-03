import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

func parseInput(raw: String) -> [[Int]] {
  let banks = raw.split(separator: "\n").map { line in
    line.map { char in Int(String(char))! }
  }
  return banks
}

func solve(banks: [[Int]], maxDigits: Int) -> Int {
  return banks.map { bank in
    (0..<maxDigits).reversed().reduce((num: 0, startIndex: 0)) { state, dropout in
      let slice = bank[state.startIndex...].dropLast(dropout)
      let digit = slice.max()!
      let index = slice.firstIndex(of: digit)!
      return (state.num * 10 + digit, index + 1)
    }.num
  }.reduce(0, +)
}

let input = readInput()
let parsed = parseInput(raw: input)
let solution = solve(banks: parsed, maxDigits: 2)
print(solution)
let solution2 = solve(banks: parsed, maxDigits: 12)
print(solution2)
