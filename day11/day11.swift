import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

func parseInput(_ raw: String) -> [String: [String]] {
  return raw.split(separator: "\n").reduce(into: [:]) { dict, line in
    let parts = line.split(separator: ":")
    dict[String(parts[0])] = parts[1].split(separator: " ").map(String.init)
  }
}

func countPaths(
  _ servers: [String: [String]], start: String, target: String, required: Set<String> = []
) -> Int {
  var memo = [String: [Set<String>: Int]]()

  func count(_ node: String, _ requiredSeen: Set<String>) -> Int {
    // Have we made progress?
    let newRequiredSeen = required.contains(node) ? requiredSeen.union([node]) : requiredSeen

    if node == target {
      // We made it (only if we've been where we need to go)
      return newRequiredSeen == required ? 1 : 0
    }

    if let cached = memo[node]?[newRequiredSeen] { return cached }

    // Sum paths through neighbors
    let result = (servers[node] ?? []).reduce(0) { $0 + count($1, newRequiredSeen) }

    memo[node, default: [:]][newRequiredSeen] = result
    return result
  }

  return count(start, [])
}

let raw = readInput()
let servers = parseInput(raw)
print(countPaths(servers, start: "you", target: "out"))
print(countPaths(servers, start: "svr", target: "out", required: ["dac", "fft"]))
