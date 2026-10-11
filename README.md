> [!WARNING]
> It's alpha, everything is expected to change.

# LaLaBench
A benchmark tool to evaluate prompts and inference pipelines in Swift.

Useful for app developers who develop apps with AI features in Swift.

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tseylerd/LaLaBench.git", from: "0.1-alpha"),
]
```

and the product to your target:

```swift
.target(name: "YourApp", dependencies: [
    .product(name: "LaLaBench", package: "LaLaBench"),
])
```

## How to use

```swift
import LaLaBench

// The judge model, running locally. Point it at an already downloaded MLX model.
let llm = LaLaBenchmarkLLM(url: URL(filePath: "models/qwen3-8b-4bit"))

// A benchmark case is a trace of inference steps.
// The response of the final step is the result that gets evaluated.
let benchmarkCase = LaLaBenchmarkCase(steps: [
    LaLaInferenceStep(
        systemPrompt: "Answer in one short sentence.",
        userPrompt: "What is the capital of France?",
        response: "The capital of France is Paris."
    )
])

let benchmark = try await LaLaBenchmark(cases: [benchmarkCase], llm: llm)
let result = try await benchmark.run()

print(result.averageScore)            // 1-5, average quality
print(result.accuracyRate)            // 0-1, no factual errors
print(result.instructionFollowingRate) // 0-1, followed all instructions
print(result.formatFollowingRate)     // 0-1, matches the requested format
print(result.requestAddressedRate)    // 0-1, on point
print(result.benchmarkFailureRate)    // 0-1, rate of failed to evaluate cases
```

Each case result contains:

- `followedInstructions` (every explicit instruction from all steps is followed)
- `followedFormat` (output matches the requested format)
- `addressesTheRequest` (on point, covers what was asked)
- `isAccurate` (no factual errors)
- `score` (quality rating based on all criteria, from 1 to 5)
- `rationale` (verdict explanation)

Here's the structure of what you get back:

```swift
public struct LaLaBenchmarkResult: Sendable {
    public let instructionFollowingRate: Double  // 0-1, followed all instructions
    public let formatFollowingRate: Double       // 0-1, matches the requested format
    public let requestAddressedRate: Double      // 0-1, on point
    public let accuracyRate: Double              // 0-1, no factual errors
    public let averageScore: Double              // 1-5, average quality
    public let benchmarkFailureRate: Double      // 0-1, failed to evaluate
    public let results: [LaLaBenchmarkCaseElement]  // one per case
}

public enum LaLaBenchmarkCaseElement: Sendable {
    case success(result: LaLaBenchmarkCaseResult)  // judge returned a verdict
    case failure(error: String)                    // judge failed to produce one
}

public struct LaLaBenchmarkCaseResult: Codable, Sendable {
    public let followedInstructions: Bool  // all explicit instructions were followed
    public let followedFormat: Bool        // matches the requested format
    public let addressesTheRequest: Bool   // on point, covers what was asked
    public let isAccurate: Bool            // no factual errors
    public let score: Int                  // 1-5
    public let rationale: String           // why the judge decided that
}
```

## Technical details
- Uses [mlx-swift-lm](https://github.com/ml-explore/mlx-swift-lm). Everything runs locally on Apple Silicon.
- Pass a path to a downloaded MLX model. Nothing is downloaded at runtime.
- The judge prompts are bundled in the package, so you don't need to write your own evaluation prompt.
- Inference runs with temperature 0 and thinking disabled.
- Use a capable local model as the judge. The quality of the scores depends on it.
- One judge, one run: treat the numbers as a relative signal, not an absolute measure.
