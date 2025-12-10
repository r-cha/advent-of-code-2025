import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

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

func parseInput(_ raw: String) -> [(Int, [Int], [Int])] {
  return raw.split(separator: "\n").map { line in
    let items = line.split(separator: " ").map(String.init)
    let statusLights = parseStatusLight(items.first!)
    let buttons = items.dropFirst().dropLast().map(parseButton)
    let joltages = parseJoltages(items.last!)
    return (statusLights, buttons, joltages)
  }
}

func minPresses(_ buttons: [Int], target: Int) -> Int? {
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

func solve(_ machines: [(Int, [Int], [Int])]) -> Int {
  return machines.compactMap { minPresses($0.1, target: $0.0) }.reduce(0, +)
}

let raw = readInput()
let machines = parseInput(raw)
print(solve(machines))
