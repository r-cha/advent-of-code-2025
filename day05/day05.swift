import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

enum RangeType: Int, Comparable {
  case ingredient = 0
  case start = 1
  case end = 2
  static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

typealias ID = (Int, RangeType)

func parseInput(raw: String) -> [ID] {
  var ids: [ID] = []
  let parts = raw.split(separator: "\n\n")
  let (rangeblock, ingredientblock) = (parts[0], parts[1])
  for line in rangeblock.split(separator: "\n") {
    let rangeparts = line.split(separator: "-")
    ids.append((Int(rangeparts[0])!, RangeType.start))
    ids.append((Int(rangeparts[1])!, RangeType.end))
  }
  ids += ingredientblock.split(separator: "\n").map { line in
    (Int(line)!, RangeType.ingredient)
  }
  return ids
}

func solve(ids: [ID]) -> Int {
  let sorted = ids.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
  return sorted.reduce(into: (totalFresh: 0, including: 0)) { state, id in
    switch id.1 {
    case .ingredient:
      if state.including > 0 { state.totalFresh += 1 }
    case .start:
      state.including += 1
    case .end:
      state.including -= 1
    }
  }.totalFresh
}

func solve2(ids: [ID]) -> Int {
  let sorted = ids.filter { id in id.1 != RangeType.ingredient }.sorted {
    ($0.0, $0.1) < ($1.0, $1.1)
  }
  return sorted.reduce(into: (totalFresh: 0, including: 0, firstStarted: Int?.none)) {state, id in
    switch id.1 {
    case .start:
      state.including += 1
      if state.including == 1 {
        state.firstStarted = id.0
      }
    case .end:
      state.including -= 1
      if state.including == 0 {
        state.totalFresh += id.0 + 1 - state.firstStarted!
        state.firstStarted = nil
      }
    default:
      break
    }
  }.totalFresh
}

let input = readInput()
let parsed = parseInput(raw: input)
let solution = solve(ids: parsed)
print(solution)
let solution2 = solve2(ids: parsed)
print(solution2)
