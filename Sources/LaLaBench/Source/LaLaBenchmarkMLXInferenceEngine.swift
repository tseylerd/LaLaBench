import MLXLLM
import MLX
import MLXLMCommon
import MLXHuggingFace
import HuggingFace
import Tokenizers
import Foundation

@LaLaBenchmarkActor
final class LaLaBenchmarkMLXInferenceEngine: LaLaBenchmarkInferenceEngine {
    private static let CONFIGURATION_FACTORY: (URL) -> ModelConfiguration = { url in
        ModelConfiguration(directory: url)
    }
    
    private let container: ModelContainer
    
    init(llm: LaLaBenchmarkLLM) async throws {
        let configuration = Self.CONFIGURATION_FACTORY(llm.url)
        self.container = try await LLMModelFactory.shared.loadContainer(from: LaLaDummyDownloader(), using: #huggingFaceTokenizerLoader(), configuration: configuration)
    }
    
    func infer(system: String, user: String) async throws -> AsyncStream<Generation> {
        var messages: [Chat.Message] = []
        messages.append(.system(system))
        messages.append(.user(user))
        
        let parameters = GenerateParameters(temperature: 0)
        
        let additionalContext: [String: any Sendable] = ["enable_thinking" : false]
        let userInput = UserInput(chat: messages, additionalContext: additionalContext)
        
        let input = try await container.prepare(input: userInput)
        let stream = try await container.generate(input: input, parameters: parameters)
        return stream
    }
}

fileprivate struct LaLaDummyDownloader: MLXLMCommon.Downloader {
    func download(id: String, revision: String?, matching patterns: [String], useLatest: Bool, progressHandler: @escaping (Progress) -> Void) async throws -> URL {
        fatalError("Must not download anything")
    }
}
