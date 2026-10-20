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
        guard let lastStep = benchmarkCase.steps.last else {
            return nil
        }
        
        guard let response = lastStep.response else {
            return LaLaBenchmarkCaseResult(
                followedInstructions: false,
                followedFormat: false,
                addressesTheRequest: false,
                isAccurate: false,
                score: 1,
                rationale: "No result"
            )
        }
        
        let system = LaLaBenchmarkUtil.SYSTEM_PROMPT
        let user = LaLaBenchmarkUtil.apply(benchmarkCase: benchmarkCase, into: LaLaBenchmarkUtil.USER_PROMPT)
        return try await engine.infer(system: system, user: user)
    }
}
