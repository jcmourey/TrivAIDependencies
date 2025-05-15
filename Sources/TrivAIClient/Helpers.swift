import Foundation

extension String {
    /// Splits the string into random-length substrings.
    /// - Parameters:
    ///   - minLength: minimum length of each substring (default 1)
    ///   - maxLength: maximum length of each substring (default 12)
    /// - Returns: An array of substrings whose lengths are between minLength and maxLength.
    func splitRandomly(minLength: Int = 1, maxLength: Int) -> [String] {
        var result: [String] = []
        var start = startIndex
        
        while start < endIndex {
            // How many characters remain?
            let remaining = distance(from: start, to: endIndex)
            // Pick a random length, but don’t exceed what’s left
            let length = Int.random(in: minLength...maxLength).clamped(to: 1...remaining)
            
            // Advance an index by that length
            let next = index(start, offsetBy: length)
            // Slice and append
            result.append(String(self[start..<next]))
            // Move start forward
            start = next
        }
        
        return result
    }
    
    func tokenize(minLength: Int = 1, maxLength: Int) -> [Int] {
        var result: [Int] = []
        var start = startIndex
        
        while start < endIndex {
            // How many characters remain?
            let remaining = distance(from: start, to: endIndex)
            
            // Pick a random length, but don’t exceed what’s left
            let length = Int.random(in: minLength...maxLength).clamped(to: 1...remaining)
            
            // Record length
            result.append(length)
            
            // Advance an index by that length
            start = index(start, offsetBy: length)
        }
        
        return result
    }
    
    /// Produce array of growing substrings of self
    /// - Parameters:
    ///   - minLength: minimum length of each substring (default 1)
    ///   - maxLength: maximum length of each substring (default 12)
    /// - Returns: An array of substrings each encompassing the previous one and growing by a number of characters between minLength and maxLength.
    func growing(minLength: Int = 1, maxLength: Int = 12) -> [String] {
        var result: [String] = []
        var start = startIndex
        
        while start < endIndex {
            // How many characters remain?
            let remaining = distance(from: start, to: endIndex)
            // Pick a random length, but don’t exceed what’s left
            let length = Int.random(in: minLength...maxLength).clamped(to: 1...remaining)
            
            // Advance an index by that length
            let next = index(start, offsetBy: length)
            // Slice and append
            result.append(String(self[startIndex..<next]))
            // Move start forward
            start = next
        }
        
        return result
    }
}

private extension Comparable {
    /// Clamp self to the given closed range.
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
