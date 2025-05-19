import InlineSnapshotTesting

extension Snapshotting where Value == [String], Format == String {
  static var arrayOfStrings: Self {
      Snapshotting<String, String>.lines.pullback { $0.joined(separator: "\n") }
  }
}

/// A simple seedable Linear Congruential Generator.
/// period ≈ 2⁶⁴, not cryptographically secure, but fine for tests.
struct LCGRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    /// - Parameter seed: any 64-bit value. Re-init with the same seed to repeat sequence.
    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Constants from Numerical Recipes
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
