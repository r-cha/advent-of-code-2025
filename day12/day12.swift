import Foundation

func readInput() -> String {
  let filename = CommandLine.arguments[1]
  guard let contents = try? String(contentsOfFile: filename, encoding: .utf8) else {
    fatalError("Could not read file: \(filename)")
  }
  return contents
}

struct Position: Hashable {
  let x: Int
  let y: Int
}

struct Shape {
  let variants: [[Position]]  // precomputed rotations/flips, normalized to origin
  var cellCount: Int {
    return variants.first?.count ?? 0
  }
}

struct Region {
  let width: Int
  let height: Int
  let targets: [Int]  // number of desired presents of each shape
}

func normalize(_ shape: [Position]) -> [Position] {
  let minX = shape.map { $0.x }.min() ?? 0
  let minY = shape.map { $0.y }.min() ?? 0
  return shape.map { Position(x: $0.x - minX, y: $0.y - minY) }.sorted { (a, b) in
    if a.x == b.x {
      return a.y < b.y
    }
    return a.x < b.x
  }
}

func generateVariants(_ shape: [Position]) -> Shape {
  var variants = Set<[Position]>()
  var current = shape
  for _ in 0..<4 {
    // Rotate 90 degrees
    current = current.map { Position(x: $0.y, y: -$0.x) }
    variants.insert(normalize(current))
    // Flip horizontally
    let flipped = current.map { Position(x: -$0.x, y: $0.y) }
    variants.insert(normalize(flipped))
  }
  return Shape(variants: Array(variants))
}

func parseInput(_ raw: String) -> (shapes: [Shape], regions: [Region]) {
  let parts = raw.components(separatedBy: "\n\n")
  let shapes = parts.dropLast().map { block in
    let lines = block.split(separator: "\n").dropFirst()
    let coordinates = lines.enumerated().flatMap { (y, line) in
      line.enumerated().compactMap { (x, char) in
        char == "#" ? Position(x: x, y: y) : nil
      }
    }
    return generateVariants(coordinates)
  }
  let regions = parts.last!.split(separator: "\n").map { line in
    let regionParts = line.split(separator: ":")
    let dimensions = regionParts[0].split(separator: "x").map { Int($0)! }
    let targets = regionParts[1].split(separator: " ").map { Int($0)! }
    return Region(width: dimensions[0], height: dimensions[1], targets: targets)
  }
  return (shapes, regions)
}

func solve(shapes: [Shape], regions: [Region]) -> Int {
  return regions.map({ region in
    let avail = region.width * region.height
    let sumAreas = region.targets.enumerated().map({ i, target in
      target * shapes[i].cellCount
    }).reduce(0, +)
    return sumAreas < avail ? 1 : 0
  }).reduce(0, +)
}

let raw = readInput()
let (shapes, regions) = parseInput(raw)
print(solve(shapes: shapes, regions: regions))
