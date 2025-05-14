import Foundation
import Dependencies
import TrivAIClient
import TrivAIModel
import EventSource

extension TrivAIClient: DependencyKey {
    public static let liveValue = Self(
        stream: { topic, difficulty, numberOfQuestions, language, hostStyle in
            AsyncThrowingStream { continuation in
                Task {
                    let urlString = "http://localhost:8080/stream"
                    guard var components = URLComponents(string: "http://localhost:8080/stream") else {
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
                            print("Received an error:", error.localizedDescription)
                        case .event(let event):
                            guard let eventTypeString = event.event, let eventType = ResponseEventType(rawValue: eventTypeString) else {
                                throw TrivAIClientError.unknownEventType(event.event)
                            }
                            guard let eventDataString = event.data else {
                                throw TrivAIClientError.noDataForEventType(eventType)
                            }
                            guard let eventData = eventDataString.data(using: .utf8) else {
                                throw TrivAIClientError.stringCantBeDecodedToData(eventDataString)
                            }
                            switch eventType {
                            case .partial:
                                let response = try JSONDecoder().decode(Response.self, from: eventData)
                                continuation.yield(.partial(response))
                            case .error:
                                throw TrivAIClientError.openAIError(eventDataString)
                            case .refusal:
                                throw TrivAIClientError.openAIRefusal(eventDataString)
                            case .complete:
                                let document = try JSONDecoder().decode(TrivAIDocument.self, from: eventData)
                                continuation.yield(.complete(document))
                            }
                            print("Received an event", event.data ?? "")
                        case .closed:
                            print("Connection was closed.")
                        }
                    }
                }
            }
        }
    )
}
