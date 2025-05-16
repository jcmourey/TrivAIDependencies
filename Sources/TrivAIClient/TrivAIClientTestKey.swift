import Foundation
import Dependencies
import TrivAIResponseModel
import EventSource

extension DependencyValues {
    public var trivAIClient: TrivAIClient {
        get { self[TrivAIClient.self] }
        set { self[TrivAIClient.self] = newValue }
    }
}

enum TrivAIClientTestError: Error {
    case missingResource(String)
    case tokenizationFailed
    case decodingError(String)
}

struct TestEvent: EVEvent {
    var id: String? = nil
    var event: String?
    var data: String?
    var other: [String: String]? = nil
    var time: String? = nil
}

extension TrivAIClient: TestDependencyKey {
    public static let previewValue = Self.mock
    public static let testValue = Self.mock
    
    static let mock = Self(
        stream: { _,_,_,_,_ in
            .init { continuation in
                @Dependency(\.continuousClock) var clock
                @Dependency(\.uuid) var uuid
                
                func continueWithDelay(_ responseEvent: ResponseEvent) async throws {
                    continuation.yield(responseEvent)
                    try await clock.sleep(for: .milliseconds(100))
                }
                
                Task {
                    let mock: Response = try loadJSONResource(from: "TrivAIClientMockResponse")
                    
                    // Send mock Response bit by bit
                    
                    // 1. Send empty Response
                    try await continueWithDelay(.partial(Response()))
                    
                    // 2. Send the title bit by bit
                    for title in mock.title.growing() {
                        try await continueWithDelay(.partial(Response(title: title)))
                    }
                    
                    // 3. Send the introduction bit by bit
                    for introduction in mock.introduction.growing() {
                        try await continueWithDelay(.partial(Response(title: mock.title, introduction: introduction)))
                    }
                    
                    // 4. For each question, send the question text bit by bit, then each choice, then the explanation bit by bit
                    var questions = [Response.Question]()
                    for question in mock.questions {
                        for questionText in question.questionText.growing() {
                            print("questionText", questionText)
                            try await continueWithDelay(.partial(Response(title: mock.title, introduction: mock.introduction, questions: questions + [Response.Question(questionText: questionText)])))
                        }
                        var choices = [String]()
                        for choice in question.choices {
                            try await continueWithDelay(.partial(Response(title: mock.title, introduction: mock.introduction, questions: questions + [Response.Question(questionText: question.questionText, choices: choices + [choice])])))
                            choices.append(choice)
                        }
                        for explanation in question.explanation.growing() {
                            try await continueWithDelay(.partial(Response(title: mock.title, introduction: mock.introduction, questions: questions + [Response.Question(questionText: question.questionText, choices: question.choices, explanation: explanation)])))
                        }
                        questions.append(question)
                    }
                    
                    // 5. Send a document id to finish
                    continuation.yield(ResponseEvent.complete(documentID: uuid().uuidString))
                    continuation.finish()
                }
            }
        }
    )
}


func loadJSONResource<T: Decodable>(from filename: String) throws -> T {
    // 1. Find the URL for filename.json in your bundle
    guard let url = Bundle.module.url(forResource: filename, withExtension: "json") else {
        throw TrivAIClientTestError.missingResource("\(filename).json")
    }

    // 2. Read the raw data…
    let data = try Data(contentsOf: url)
    
    // 3. Return decoded data
    let decoded = try JSONDecoder().decode(T.self, from: data)
    return decoded
}
