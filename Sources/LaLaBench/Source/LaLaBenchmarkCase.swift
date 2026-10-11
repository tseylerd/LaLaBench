public struct LaLaBenchmarkCase: Sendable {
    public let steps: [LaLaInferenceStep]
    
    public init(steps: [LaLaInferenceStep]) {
        self.steps = steps
    }
}

public struct LaLaInferenceStep: Sendable {
    public let systemPrompt: String
    public let userPrompt: String
    public let response: String?
    
    public init(systemPrompt: String, userPrompt: String, response: String?) {
        self.systemPrompt = systemPrompt
        self.userPrompt = userPrompt
        self.response = response
    }
}
