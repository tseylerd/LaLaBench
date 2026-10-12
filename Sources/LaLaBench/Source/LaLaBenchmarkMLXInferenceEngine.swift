import MLXLLM
import MLX
import MLX
import MLXLMCommon
import MLXHuggingFace
import HuggingFace
import Tokenizers
import Foundation
import FoundationModels
import MLXFoundationModels
import OSLog

@LaLaBenchmarkActor
final class LaLaBenchmarkMLXInferenceEngine: LaLaBenchmarkInferenceEngine {
    private static let LOG = Logger(subsystem: "Inference", category: "LaLaBenchmarkMLXInferenceEngine")
    
    private static let CONFIGURATION_FACTORY: (URL) -> ModelConfiguration = { url in
        ModelConfiguration(directory: url)
    }
    
    private let model: MLXLanguageModel
    
    init(llm: LaLaBenchmarkLLM) async throws {
        
        let configuration = Self.CONFIGURATION_FACTORY(llm.url)
        self.model = MLXLanguageModel(configuration: configuration, capabilities: [.guidedGeneration, .reasoning]) { s in
            llm.url
        } load: { configuration, _ in
            try await LLMModelFactory.shared.loadContainer(from: LaLaDummyDownloader(), using: #huggingFaceTokenizerLoader(), configuration: configuration)
        }
    }
    
    func infer(system: String, user: String) async throws -> LaLaBenchmarkCaseResult? {
        let session = LanguageModelSession(model: model, instructions: system)
        let response = try await session.respond(to: user, generating: LaLaBenchmarkCaseResult.self, options: GenerationOptions(temperature: 0), contextOptions: ContextOptions(includeSchemaInPrompt: true, reasoningLevel: .custom("no_think")))
        return response.content
    }
}

fileprivate struct LaLaDummyDownloader: MLXLMCommon.Downloader {
    func download(id: String, revision: String?, matching patterns: [String], useLatest: Bool, progressHandler: @escaping (Progress) -> Void) async throws -> URL {
        fatalError("Must not download anything")
    }
}
