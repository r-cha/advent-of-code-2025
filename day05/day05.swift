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
  var totalFresh = 0
  var including = 0
  for id in sorted {
    switch id.1 {
    case .ingredient:
      if including > 0 {
        totalFresh += 1
      }
    case .start:
      including += 1
    case .end:
      including -= 1
    }
  }
  return totalFresh
}

func solve2(ids: [ID]) -> Int {
  let sorted = ids.filter { id in id.1 != RangeType.ingredient }.sorted {
    ($0.0, $0.1) < ($1.0, $1.1)
  }
  var totalFresh = 0
  var including = 0
  var firstStarted: Int? = nil
  for id in sorted {
    switch id.1 {
    case .start:
      including += 1
      if including == 1 {
        firstStarted = id.0
      }
    case .end:
      including -= 1
      if including == 0 {
        totalFresh += id.0 + 1 - firstStarted!
        firstStarted = nil
      }
    default:
      break
    }
  }
  return totalFresh
}

let input = readInput()
let parsed = parseInput(raw: input)
let solution = solve(ids: parsed)
print(solution)
let solution2 = solve2(ids: parsed)
print(solution2)
