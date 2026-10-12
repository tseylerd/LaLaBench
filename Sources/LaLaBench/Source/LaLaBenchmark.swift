import Foundation
import OSLog

@LaLaBenchmarkActor
public final class LaLaBenchmark {
    private static let LOG = Logger(subsystem: "Benchmark", category: "Benchmark")
    
    private let cases: [LaLaBenchmarkCase]
    private let engine: LaLaBenchmarkInferenceEngine
    
    public init(cases: [LaLaBenchmarkCase], llm: LaLaBenchmarkLLM) async throws {
        self.cases = cases
        self.engine = try await LaLaBenchmarkMLXInferenceEngine(llm: llm)
    }
    
    public init(cases: [LaLaBenchmarkCase], engine: LaLaBenchmarkInferenceEngine) async throws {
        self.cases = cases
        self.engine = engine
    }
    
    public func run() async throws -> LaLaBenchmarkResult {
        Self.LOG.info("Starting benchmark with \(self.cases.count) cases")
        
        var result: [LaLaBenchmarkCaseElement] = []
        var i = 0
        for benchmarkCase in cases {
            try Task.checkCancellation()
            
            Self.LOG.info("Evaluating case #\(i + 1)")
            i += 1
            let evaluator = LaLaBenchmarkCaseEvaluator(benchmarkCase: benchmarkCase, engine: engine)
            do {
                if let caseResult = try await evaluator.evaluate() {
                    Self.LOG.info("Evaluated successfully")
                    if let serialized = serialize(result: caseResult) {
                        Self.LOG.info("\(serialized)")
                    }
                    result.append(.success(result: caseResult))
                } else {
                    Self.LOG.warning("Failed to evaluate: no result")
                    result.append(.failure(error: "No result"))
                }
            } catch let error as CancellationError {
                throw error
            } catch {
                Self.LOG.error("Failed to evaluate: \(error.localizedDescription)")
                result.append(.failure(error: error.localizedDescription))
            }
        }
        return aggregate(results: result)
    }
    
    private func aggregate(results: [LaLaBenchmarkCaseElement]) -> LaLaBenchmarkResult {
        guard !results.isEmpty else {
            return LaLaBenchmarkResult(
                instructionFollowingRate: 0,
                formatFollowingRate: 0,
                requestAddressedRate: 0,
                accuracyRate: 0,
                averageScore: 0,
                benchmarkFailureRate: 0,
                results: []
            )
        }
        
        var instructionFollowingSum: Int = 0
        var formatFollowingSum: Int = 0
        var requestAddressedSum: Int = 0
        var accuracySum: Int = 0
        var averageScoreSum: Int = 0
        var failedBenchmarks: Int = 0
        var count: Int = 0
        
        for element in results {
            switch element {
            case .success(let result):
                instructionFollowingSum += (result.followedInstructions ? 1 : 0)
                formatFollowingSum += (result.followedFormat ? 1 : 0)
                requestAddressedSum += (result.addressesTheRequest ? 1 : 0)
                accuracySum += (result.isAccurate ? 1 : 0)
                averageScoreSum += result.score
                count += 1
            case .failure(_):
                failedBenchmarks += 1
                continue
            }
        }
        
        let instructionFollowingRate: Double = count == 0 ? 0 : Double(instructionFollowingSum) / Double(count)
        let formatFollowingRate: Double = count == 0 ? 0 : Double(formatFollowingSum) / Double(count)
        let requestAddressedRate: Double = count == 0 ? 0 : Double(requestAddressedSum) / Double(count)
        let accuracyRate: Double = count == 0 ? 0 : Double(accuracySum) / Double(count)
        let averageScore: Double = count == 0 ? 0 : Double(averageScoreSum) / Double(count)
        let benchmarkFailureRate: Double = Double(failedBenchmarks) / Double(results.count)
        
        return LaLaBenchmarkResult(
            instructionFollowingRate: instructionFollowingRate,
            formatFollowingRate: formatFollowingRate,
            requestAddressedRate: requestAddressedRate,
            accuracyRate: accuracyRate,
            averageScore: averageScore,
            benchmarkFailureRate: benchmarkFailureRate,
            results: results,
        )
    }
    
    private func serialize(result: LaLaBenchmarkCaseResult) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(result)
            return String(data: data, encoding: .utf8)
        } catch {
            Self.LOG.error("Failed to serialize evaluation result: \(error.localizedDescription)")
            return nil
        }
    }
}
