import Testing
import Dependencies
import DependenciesTestSupport
@testable import TrivAIClient

@Test(
    .dependencies {
        $0.continuousClock = ImmediateClock()
        $0.uuid = .incrementing
    }
) func testStream() async throws {
    @Dependency(\.trivAIClient) var trivAIClient
    
    for try await responseEvent in try await trivAIClient.stream(topic: nil, difficulty: nil, numberOfQuestions: nil, language: nil, hostStyle: nil) {
    }
}
