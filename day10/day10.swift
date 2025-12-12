import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

typealias Machine = (Int, [Int], [Int])

func parseStatusLight(_ raw: String) -> Int {
  let powers = raw.dropFirst().dropLast().enumerated().compactMap { i, char in
    char == "#" ? i : nil
  }
  return powers.reduce(0) { acc, p in
    acc + (1 << p)
  }
}

func parseButton(_ raw: String) -> Int {
  return raw.dropFirst().dropLast().split(separator: ",").compactMap { Int($0) }.reduce(0) {
    acc, p in
    acc + (1 << p)
  }
}

func parseJoltages(_ raw: String) -> [Int] {
  return raw.dropFirst().dropLast().split(separator: ",").compactMap { Int($0) }
}

func parseInput(_ raw: String) -> [Machine] {
  return raw.split(separator: "\n").map { line in
    let items = line.split(separator: " ").map(String.init)
    let statusLights = parseStatusLight(items.first!)
    let buttons = items.dropFirst().dropLast().map(parseButton)
    let joltages = parseJoltages(items.last!)
    return (statusLights, buttons, joltages)
  }
}

func minPressesStatus(_ buttons: [Int], target: Int) -> Int? {
  var visited = [Int: Int]()
  visited[0] = 0
  var queue = [0]

  while !queue.isEmpty {
    let state = queue.removeFirst()
    let presses = visited[state]!

    if state == target { return presses }

    for button in buttons {
      let next = state ^ button
      if visited[next] == nil {
        visited[next] = presses + 1
        queue.append(next)
      }
    }
  }
  return nil
}

func solve(_ machines: [Machine]) -> Int {
  return machines.compactMap { minPressesStatus($0.1, target: $0.0) }.reduce(0, +)
}

struct Registers: Hashable {
  let regs: [Int]
}

struct Rational: CustomStringConvertible {
  var num: Int
  var den: Int

  init(_ n: Int, _ d: Int = 1) {
    precondition(d != 0)
    let g = Self.gcd(abs(n), abs(d))
    let sign = d < 0 ? -1 : 1
    num = sign * n / g
    den = sign * d / g
  }

  private static func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
  }

  static func + (l: Rational, r: Rational) -> Rational {
    Rational(l.num * r.den + r.num * l.den, l.den * r.den)
  }
  static func - (l: Rational, r: Rational) -> Rational {
    Rational(l.num * r.den - r.num * l.den, l.den * r.den)
  }
  static func * (l: Rational, r: Rational) -> Rational {
    Rational(l.num * r.num, l.den * r.den)
  }
  static func / (l: Rational, r: Rational) -> Rational {
    Rational(l.num * r.den, l.den * r.num)
  }

  static func -= (l: inout Rational, r: Rational) {
    l = l - r
  }

  static func *= (l: inout Rational, r: Rational) {
    l = l * r
  }

  var isZero: Bool { num == 0 }
  var isPositive: Bool { num > 0 }
  var floor: Int { num / den }
  var isNegative: Bool { num < 0 }
  var intValue: Int? { den == 1 ? num : nil }
  var description: String { den == 1 ? "\(num)" : "\(num)/\(den)" }
}

var debugMode = false

func minPressesJoltages(_ buttons: [Int], target: [Int]) -> Int? {
  let m = target.count
  let n = buttons.count

  // Build matrix: m rows (registers), n columns (buttons) + 1 (target)
  var matrix = (0..<m).map { r in
    buttons.map { b in Rational((b >> r) & 1) } + [Rational(target[r])]
  }

  // Gaussian elimination
  var pivotCols = [Int]()
  var row = 0
  var col = 0

  // First, get to RREF
  while row < m && col < n {
    let pivotRow = (row..<m).first { !matrix[$0][col].isZero }
    if pivotRow == nil {
      col += 1
      continue
    }
    matrix.swapAt(row, pivotRow!)
    let pivot = matrix[row][col]
    matrix[row] = matrix[row].map { $0 / pivot }
    for r in 0..<m where r != row {
      let factor = matrix[r][col]
      for c in 0...n {
        matrix[r][c] -= factor * matrix[row][c]
      }
    }
    pivotCols.append(col)
    row += 1
    col += 1
  }

  // Check for inconsistency
  for r in row..<m {
    if !matrix[r][n].isZero { return nil }
  }

  let freeCols = (0..<n).filter { !pivotCols.contains($0) }

  // Compute bounds for free variables
  let maxTarget = target.max() ?? 1
  var lowerBounds = freeCols.map { _ in 0 }
  var upperBounds = freeCols.map { _ in maxTarget }

  for (i, _) in pivotCols.enumerated() {
    let rhs = matrix[i][n]
    var posCoeffs: [(Int, Rational)] = []
    var negCoeffs: [(Int, Rational)] = []

    for (j, fc) in freeCols.enumerated() {
      let c = matrix[i][fc]
      if c.isPositive { posCoeffs.append((j, c)) } else if c.isNegative { negCoeffs.append((j, c)) }
    }

    // Upper bounds: valid when all free var coefficients are non-negative
    if !posCoeffs.isEmpty && negCoeffs.isEmpty && !rhs.isNegative {
      for (j, c) in posCoeffs {
        upperBounds[j] = min(upperBounds[j], (rhs / c).floor)
      }
    }

    // Lower bounds: only valid when exactly one free variable has negative coefficient
    // (otherwise the constraint is a combined constraint on multiple variables)
    if posCoeffs.isEmpty && negCoeffs.count == 1 && rhs.isNegative {
      let (j, c) = negCoeffs[0]
      let bound = rhs / c
      let lb = (bound.num + bound.den - 1) / bound.den
      lowerBounds[j] = max(lowerBounds[j], lb)
    }
  }

  // Ensure bounds are valid
  for j in 0..<freeCols.count {
    upperBounds[j] = max(lowerBounds[j], upperBounds[j])
  }

  var best: Int? = nil

  func enumerate(_ idx: Int, _ freeVals: [Int]) {
    if idx == freeCols.count {
      var total = freeVals.reduce(0, +)
      for (i, _) in pivotCols.enumerated() {
        var val = matrix[i][n]
        for (j, fc) in freeCols.enumerated() {
          val -= matrix[i][fc] * Rational(freeVals[j])
        }
        if val.isNegative { return }
        if val.intValue == nil { return }
        total += val.intValue!
      }
      if best == nil || total < best! { best = total }
      return
    }
    for v in lowerBounds[idx]...upperBounds[idx] {
      enumerate(idx + 1, freeVals + [v])
    }
  }

  enumerate(0, [])
  return best
}
func solve2(_ machines: [Machine]) -> Int {
  return machines.compactMap { minPressesJoltages($0.1, target: $0.2) }.reduce(0, +)
}

let raw = readInput()
let machines = parseInput(raw)
print(solve(machines))

print(solve2(machines))  // 11825 < 19502 < x < 20052 && x != 19506 && x != 18577
