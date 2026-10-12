import MLXLLM
import MLX
import MLXLMCommon
import MLXHuggingFace
import HuggingFace
import Tokenizers
import Foundation

@LaLaBenchmarkActor
public protocol LaLaBenchmarkInferenceEngine {
    func infer(system: String, user: String) async throws -> AsyncStream<Generation>
}
