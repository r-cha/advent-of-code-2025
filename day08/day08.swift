import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

struct Point3: Hashable, CustomStringConvertible {
  let x, y, z: Int
  var description: String {
    "\(x),\(y),\(z)"
  }

  subscript(_ axis: Int) -> Int {
    switch axis {
    case 0: return x
    case 1: return y
    default: return z
    }
  }
}

func parseInput(_ raw: String) -> [Point3] {
  return raw.split(separator: "\n").map { line in
    let nums = line.split(separator: ",").map { num in
      Int(String(num))!
    }
    return Point3(x: nums[0], y: nums[1], z: nums[2])
  }
}

class UnionFind {
  private var parent: [Point3: Point3] = [:]
  private(set) var connectedPoints: Set<Point3> = []

  func find(_ p: Point3) -> Point3 {
    if parent[p] == nil { parent[p] = p }
    if parent[p] != p {
      parent[p] = find(parent[p]!)
    }
    return parent[p]!
  }

  func union(_ a: Point3, _ b: Point3) {
    connectedPoints.insert(a)
    connectedPoints.insert(b)
    parent[find(a)] = find(b)
  }

  func connected(_ a: Point3, _ b: Point3) -> Bool {
    return find(a) == find(b)
  }

  func groups() -> [[Point3]] {
    var groupMap: [Point3: [Point3]] = [:]
    for p in connectedPoints {
      groupMap[find(p), default: []].append(p)
    }
    return Array(groupMap.values)
  }
}

func distance(_ a: Point3, _ b: Point3) -> Double {
  let dx = Double(a.x - b.x)
  let dy = Double(a.y - b.y)
  let dz = Double(a.z - b.z)
  return sqrt((dx * dx) + (dy * dy) + (dz * dz))
}

func buildCircuits(_ points: [Point3], connectionsToMake: Int) -> [[Point3]] {
  let uf = UnionFind()

  // Pre-compute all pairwise distances and sort by distance
  var allPairs: [(Double, Point3, Point3)] = []
  for i in 0..<points.count {
    for j in (i + 1)..<points.count {
      allPairs.append((distance(points[i], points[j]), points[i], points[j]))
    }
  }
  allPairs.sort { $0.0 < $1.0 }

  var attemptsCount = 0
  for (_, a, b) in allPairs {
    if attemptsCount >= connectionsToMake { break }
    attemptsCount += 1
    if uf.connected(a, b) {
      print("Skipped \(a)\tand \(b) (already connected)")
      continue
    }
    uf.union(a, b)
    print("Connected \(a)\tand \(b)")
  }
  return uf.groups().sorted { $0.count > $1.count }
}

func solve(_ points: [Point3]) -> Int {
  let circuits = buildCircuits(points, connectionsToMake: 1000)
  print(circuits.map(\.count))
  return circuits.prefix(3).map(\.count).reduce(1, *)
}

let raw = readInput()
let points = parseInput(raw)
print(solve(points))
