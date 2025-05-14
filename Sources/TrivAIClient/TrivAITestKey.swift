import Dependencies
import Foundation
import TrivAIModel
import Tiktoken

extension DependencyValues {
    public var trivAIClient: TrivAIClient {
        get { self[TrivAIClient.self] }
        set { self[TrivAIClient.self] = newValue }
    }
}

extension TrivAIClient: TestDependencyKey {
    public static let previewValue = Self()
    public static let testValue = Self(
        stream: { _,_,_,_,_ in
            let mock: String = try loadJSONResource(from: "TrivAIClientMock")
            let words = mock.splitRandomly(minLength: 1, maxLength: 12)

            return AsyncThrowingStream { continuation in
                @Dependency(\.continuousClock) var clock
                Task {
                    for word in words {
                        try await clock.sleep(for: .milliseconds(300))
                        continuation.yield(word)
                    }
                    continuation.finish()
                }
            }
        }
    )
}


func loadJSONResource<T: Codable>(from filename: String) throws -> T {
    guard let url = Bundle.module.url(forResource: filename, withExtension: "json") else {
        throw TrivAIClientError.missingResource("\(filename).json")
    }
    let data = try Data(contentsOf: url)
    let decoded = try JSONDecoder().decode(T.self, from: data)
    return decoded
}

