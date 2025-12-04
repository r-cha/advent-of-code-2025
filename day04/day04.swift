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

func solve(grid: [[Bool]]) -> [(Int, Int)] {
  (0..<grid.count).flatMap { row in
    (0..<grid[0].count).compactMap { col in
      let window = (-1...1).flatMap { dr in
        (-1...1).map { dc in
          let r = row + dr
          let c = col + dc
          return (r >= 0 && r < grid.count && c >= 0 && c < grid[0].count) ? grid[r][c] : false
        }
      }
      return (window[4] && window.filter { $0 }.count < 5) ? (row, col) : nil
    }
  }
}

func updateGrid(grid: [[Bool]], toRemove: [(Int, Int)]) -> [[Bool]] {
  var newGrid = grid
  for (r, c) in toRemove {
    newGrid[r][c] = false
  }
  return newGrid
}

func solve2(grid: [[Bool]], acc: Int = 0) -> Int {
  let spots = solve(grid: grid)
  if spots.count == 0 { return acc }
  return solve2(grid: updateGrid(grid: grid, toRemove: spots), acc: acc + spots.count)
}

let input = readInput()
let parsed = parseInput(raw: input)
let solution = solve(grid: parsed)
print(solution.count)
let solution2 = solve2(grid: parsed)
print(solution2)
