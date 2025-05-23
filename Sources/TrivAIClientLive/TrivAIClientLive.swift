import Foundation
import Dependencies
import TrivAIClient
import EventSource

extension TrivAIClient: DependencyKey {
    public static let liveValue = Self(
        stream: { topic, difficulty, numberOfQuestions, language, hostStyle in
            AsyncThrowingStream { continuation in
                Task {
                    let urlString = "http://localhost:8080/stream"
                    guard var components = URLComponents(string: urlString) else {
                        throw TrivAIClientError.invalidURL(urlString)
                    }
                    let numberOfQuestionsString = if let numberOfQuestions { "\(numberOfQuestions)" } else { nil as String? }
                    components.queryItems = [
                        .init(name: "topic", value: topic),
                        .init(name: "difficulty", value: difficulty),
                        .init(name: "number_of_questions", value: numberOfQuestionsString),
                        .init(name: "language", value: language),
                        .init(name: "host_style", value: hostStyle),
                    ]
                    guard let url = components.url else {
                        throw TrivAIClientError.invalidURLComponents(components)
                    }
                    let urlRequest = URLRequest(url: url)
                    let eventSource = EventSource()
                    let dataTask = await eventSource.dataTask(for: urlRequest)
                    for try await event in await dataTask.events() {
                        switch event {
                        case .open:
                            print("Connection was opened.")
                        case .error(let error):
                            throw error
                        case .event(let event):
                            let responseEvent = try ResponseEvent(from: event)
                            continuation.yield(responseEvent)
                        case .closed:
                            print("Connection was closed.")
                        }
                    }
                }
            }
        }
    )
}
