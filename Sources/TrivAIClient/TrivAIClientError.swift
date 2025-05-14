import Foundation
import EventSource

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
