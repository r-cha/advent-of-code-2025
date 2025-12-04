import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

func parseInput(raw: String) -> [[Bool]] {
  return raw.split(separator: "\n").map { line in
    line.map { char in char == "@" }
  }
}

func solve(grid: [[Bool]]) -> (Int, [(Int, Int)]) {
  var totalSpots = 0
  var spots: [(Int, Int)] = []
  for row in 0..<grid.count {
    for col in 0..<grid[0].count {
      let window = (-1...1).map { dr in
        (-1...1).map { dc in
          let r = row + dr
          let c = col + dc
          return (r >= 0 && r < grid.count && c >= 0 && c < grid[0].count) ? grid[r][c] : false
        }
      }
      if window[1][1] && (window.flatMap { $0 }.filter { $0 }.count) < 5 {
        totalSpots += 1
        spots.append((row, col))
      }
    }
  }
  return (totalSpots, spots)
}

func updateGrid(grid: [[Bool]], toRemove: [(Int, Int)]) -> [[Bool]] {
  var newGrid = grid
  for (r, c) in toRemove {
    newGrid[r][c] = false
  }
  return newGrid
}

func solve2(grid: [[Bool]]) -> Int {
  var newGrid = grid
  var totalTotalSpots = 0
  var removed = true
  repeat {
    let (totalSpots, spots) = solve(grid: newGrid)
    totalTotalSpots += totalSpots
    newGrid = updateGrid(grid: newGrid, toRemove: spots)
    removed = totalSpots > 0
  } while removed
  return totalTotalSpots
}

let input = readInput()
let parsed = parseInput(raw: input)
let solution = solve(grid: parsed)
print(solution.0)
let solution2 = solve2(grid: parsed)
print(solution2)
