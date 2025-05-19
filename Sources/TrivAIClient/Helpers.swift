import Foundation

extension String {
    /// Produce array of growing substrings of self
    /// with each incremental chunk having a random length in specified range
    func growing<R: RandomNumberGenerator>(by range: ClosedRange<Int> = 1...12, using generator: inout R) -> [String] {
        var result: [String] = []
        guard !isEmpty else { return result }
        
        var currentEndIndex = index(startIndex, offsetBy: 1)
        
        while currentEndIndex < endIndex {
            let remainingDistance = distance(from: currentEndIndex, to: endIndex)
            let chunkLength = Int.random(in: range, using: &generator)
            let constrainedChunkLength = chunkLength.clamped(to: 1...remainingDistance)
            currentEndIndex = index(currentEndIndex, offsetBy: constrainedChunkLength)
            let growingSubstring = String(self[..<currentEndIndex])
            result.append(growingSubstring)
        }
        
        return result
    }
    
    func growing(by range: ClosedRange<Int> = 1...12) -> [String] {
        var systemGenerator = SystemRandomNumberGenerator()
        return growing(by: range, using: &systemGenerator)
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
