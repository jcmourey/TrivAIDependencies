import DependenciesMacros
import Dependencies
import TrivAIModel
import EventSource
import Foundation

@DependencyClient
public struct TrivAIClient: Sendable {
    public var stream: @Sendable (
        _ topic: String?,
        _ difficulty: String?,
        _ numberOfQuestions: Int?,
        _ language: String?,
        _ hostStyle: String?
    ) async throws -> AsyncThrowingStream<ResponseEvent, Error>
}

public enum TrivAIClientError: Error {
    case invalidURL(String)
    case missingResource(String)
    case invalidURLComponents(URLComponents)
    case missingEventType(EVEvent)
    case missingEventData(EVEvent)
    case invalidEventType(String)
    case stringCantBeDecodedToData(String)
    case openAIError(String)
    case openAIRefusal(String)
}

public enum ResponseEvent {
    case partial(Response)
    case complete(documentID: String)
    
    public init(from evEvent: EVEvent) throws {
        guard let eventTypeString = evEvent.event else {
            throw TrivAIClientError.missingEventType(evEvent)
        }
        guard let eventDataString = evEvent.data else {
            throw TrivAIClientError.missingEventData(evEvent)
        }
        switch eventTypeString {
        case "partial":
            guard let eventData = eventDataString.data(using: .utf8) else {
                throw TrivAIClientError.stringCantBeDecodedToData(eventDataString)
            }
            let response = try JSONDecoder().decode(Response.self, from: eventData)
            self = .partial(response)
            
        case "error":
            throw TrivAIClientError.openAIError(eventDataString)
            
        case "refusal":
            throw TrivAIClientError.openAIRefusal(eventDataString)
            
        case "complete":
            self = .complete(documentID: eventDataString)
            
        default:
            throw TrivAIClientError.invalidEventType(eventTypeString)
        }
    }
}
