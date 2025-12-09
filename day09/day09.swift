import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

struct Point: Hashable, CustomStringConvertible {
  let x, y: Int
  var description: String {
    "\(x),\(y)"
  }
}

func parseInput(_ raw: String) -> [Point] {
  return raw.split(separator: "\n").map { line in
    let nums = line.split(separator: ",").map { num in
      Int(String(num))!
    }
    return Point(x: nums[0], y: nums[1])
  }
}

func area(_ a: Point, _ b: Point) -> Int {
  return (abs(a.x - b.x) + 1) * (abs(a.y - b.y) + 1)
}

func calcAllAreas(_ points: [Point]) -> [(Int, Point, Point)] {
  var allPairs: [(Int, Point, Point)] = []
  for i in 0..<points.count {
    for j in (i + 1)..<points.count {
      allPairs.append((area(points[i], points[j]), points[i], points[j]))
    }
  }
  allPairs.sort { $0.0 > $1.0 }
  return allPairs
}

func drawBoundaries(_ points: [Point]) -> Set<Point> {
  var boundary: Set<Point> = []
  for i in points.indices {
    let a = points[i]
    let b = points[(i + 1) % points.count]
    for x in min(a.x, b.x)...max(a.x, b.x) {
      for y in min(a.y, b.y)...max(a.y, b.y) {
        boundary.insert(Point(x: x, y: y))
      }
    }
  }
  return boundary
}

func isSpanning(_ corner1: Point, _ corner2: Point, boundary: Set<Point>) -> Bool {
  let minX = min(corner1.x, corner2.x) + 1
  let maxX = max(corner1.x, corner2.x) - 1
  let minY = min(corner1.y, corner2.y) + 1
  let maxY = max(corner1.y, corner2.y) - 1

  return !boundary.contains { p in
    p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY
  }
}

func fillAllAreas(_ points: [Point]) -> (Int, Point, Point) {
  let allAreas = calcAllAreas(points)
  print(allAreas[0])  // part 1
  let boundaries = drawBoundaries(points)

  return allAreas.first { (totalArea, a, b) in
    isSpanning(a, b, boundary: boundaries)
  }!
}

print(fillAllAreas(parseInput(readInput())))
