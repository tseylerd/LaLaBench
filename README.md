> It's alpha, everything is expected to change.

# LaLaBench
A benchmark tool to evaluate prompts and inference pipelines in Swift.

Useful for app developers who develop apps with AI features in Swift.

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/LaLaBench.git", from: "0.1-alpha"),
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

print(result.averageScore)            // 1-5, average quality of the final results
print(result.accuracyRate)            // 0-1, share of cases with no factual errors
print(result.instructionFollowingRate)
print(result.formatFollowingRate)
print(result.requestAddressedRate)
print(result.benchmarkFailureRate)    // 0-1, cases the benchmark itself failed to evaluate
```

Each case result contains the four checks (`followedInstructions`, `followedFormat`, `addressesTheRequest`, `isAccurate`), a score from 1 to 5, and a `rationale` explaining the verdict.

## Technical details
- Uses [mlx-swift-lm](https://github.com/ml-explore/mlx-swift-lm). Everything runs locally on Apple Silicon.
- Pass a path to a downloaded MLX model. Nothing is downloaded at runtime.
- The judge prompts are bundled in the package, so you don't need to write your own evaluation prompt.
- Inference runs with temperature 0 and thinking disabled.
- Use a capable local model as the judge. The quality of the scores depends on it.
- One judge, one run: treat the numbers as a relative signal, not an absolute measure.
