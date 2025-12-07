import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

func parseInput(_ raw: String) -> [[Character]] {
  return raw.split(separator: "\n").map { Array($0) }
}

func solve(_ lines: [[Character]]) -> Int {
  var splits = 0
  var beamIndices = Set<Int>()
  for line in lines {
    for (i, char) in line.enumerated() {
      switch char {
      case ".":
        break
      case "S":
        beamIndices.insert(i)
      case "^":
        if beamIndices.remove(i) != nil {
          splits += 1
          beamIndices.insert(i + 1)
          beamIndices.insert(i - 1)
        }
      default:
        break
      }
    }
  }
  return splits
}

let raw = readInput()
print(solve(parseInput(raw)))
