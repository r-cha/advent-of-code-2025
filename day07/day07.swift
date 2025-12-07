import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

struct Point: Hashable {
  let x, y: Int
}

class Node {
  let point: Point
  var left, right: Node?

  var loc: Int { point.x }
  var depth: Int { point.y }

  init(_ point: Point) {
    self.point = point
  }
}

func parseInput(_ raw: String) -> [[Character]] {
  return raw.split(separator: "\n").map { Array($0) }
}

func solve(_ lines: [[Character]]) -> (Int, Node?) {
  var splits = 0
  var beamIndices = Set<Int>()
  var head: Node? = nil
  var nodes: [Point: Node] = [:]
  func getOrCreate(_ point: Point) -> Node {
    if let node = nodes[point] { return node }
    let node = Node(point)
    nodes[point] = node
    return node
  }

  for (d, line) in lines.enumerated() {
    for (i, char) in line.enumerated() {
      let point = Point(x: i, y: d)
      switch char {
      case ".":
        break
      case "S":
        beamIndices.insert(i)
        head = getOrCreate(point)

      case "^":
        if beamIndices.remove(i) != nil {
          splits += 1
          beamIndices.insert(i + 1)
          beamIndices.insert(i - 1)
        }
        let node = getOrCreate(point)
        for parent in nodes.values where parent.depth < d {
          if parent.loc - 1 == i { parent.left = parent.left ?? node }
          if parent.loc + 1 == i { parent.right = parent.right ?? node }
        }
      default:
        break
      }
    }
  }
  return (splits, head)
}

func solve2(_ root: Node?) -> Int {
  var cache: [Point: Int] = [:]

  func count(_ node: Node?) -> Int {
    guard let node = node else { return 1 }
    if let cached = cache[node.point] { return cached }
    let res = count(node.left) + count(node.right)
    cache[node.point] = res
    return res
  }

  return count(root)
}

let raw = readInput()
let (splits, head) = solve(parseInput(raw))
print(splits)
let timelines = solve2(head)
print(timelines)
