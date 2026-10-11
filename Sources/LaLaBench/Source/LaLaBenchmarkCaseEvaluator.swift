import MLXLMCommon
import OSLog

@LaLaBenchmarkActor
final class LaLaBenchmarkCaseEvaluator {
    private static nonisolated let LOG = Logger(subsystem: "Benchmark", category: "BenchmarkCaseEvaluator")
    
    private let benchmarkCase: LaLaBenchmarkCase
    private let engine: LaLaBenchmarkInferenceEngine
    
    init(benchmarkCase: LaLaBenchmarkCase, engine: LaLaBenchmarkInferenceEngine) {
        self.benchmarkCase = benchmarkCase
        self.engine = engine
    }
    
    func evaluate() async throws -> LaLaBenchmarkCaseResult? {
        let system = LaLaBenchmarkUtil.SYSTEM_PROMPT
        let user = LaLaBenchmarkUtil.apply(benchmarkCase: benchmarkCase, into: LaLaBenchmarkUtil.USER_PROMPT)
        let stream = try await engine.infer(system: system, user: user)
        
        var result = ""
        for await element in stream {
            switch element {
            case .chunk(let string):
                result += string
            case .info(let generateCompletionInfo):
                Self.LOG.info("\(generateCompletionInfo.summary())")
            case .toolCall(_):
                continue
            case .rejectedToolCall(_):
                continue
            }
        }
        
        return parseResult(from: result)
    }
    
    private func parseResult(from text: String) -> LaLaBenchmarkCaseResult? {
        let decoder = JSONDecoder()
        guard let data = text.data(using: .utf8) else {
            Self.LOG.error("Failed to extract data from text")
            return nil
        }
        do {
            let decoded = try decoder.decode(LaLaBenchmarkCaseResult.self, from: data)
            guard decoded.score >= 1 && decoded.score <= 5 else {
                return LaLaBenchmarkCaseResult(
                    followedInstructions: decoded.followedInstructions,
                    followedFormat: decoded.followedFormat,
                    addressesTheRequest: decoded.addressesTheRequest,
                    isAccurate: decoded.isAccurate,
                    score: max(1, min(decoded.score, 5)),
                    rationale: decoded.rationale
                )
            }
            return decoded
        } catch {
            Self.LOG.error("Failed to decode: \(error.localizedDescription)\nOutput: \(text)")
        }
        
        return nil
    }
}
