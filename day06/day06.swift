import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

func parseInput(_ raw: String) -> [[String]] {
  let lines = raw.split(separator: "\n").map { line in
    line.split(separator: " ").map { val in
      String(val)
    }
  }
  return lines[0].indices.map { i in
    lines.map { Array($0)[i] }
  }
}

func solve(_ columns: [[String]]) -> Int {
  return columns.map { col in
    let red: (Int, (Int, Int) -> Int) = col.last! == "*" ? (1, *) : (0, +)
    return col.dropLast().map { Int($0)! }.reduce(red.0, red.1)
  }.reduce(0, +)
}

func parseColumns(_ raw: String) -> [[String]] {
  // This time it's just a list of strings, but it's pre-pivoted to be columnar strings
  let lines = raw.split(separator: "\n").map { Array($0) }
  let columns = lines[0].indices.map { i in
    String(lines.map { $0[i] }).trimmingCharacters(in: .whitespaces)
  }
  // Might as well do the hard part and separate them into problems too
  let problems = columns.split(whereSeparator: { $0.isEmpty }).map { Array($0) }
  // and extract the operator so everything is niiiiice and clean.
  return problems.map { problem in
    let op = String(problem[0].last!)
    let newProblemZero = problem[0].dropLast().trimmingCharacters(in: .whitespaces)
    return [newProblemZero] + problem.dropFirst() + [op]
  }
}

let raw = readInput()
print(solve(parseInput(raw)))
print(solve(parseColumns(raw)))
