public struct LaLaBenchmarkCase: Sendable {
    public let steps: [LaLaInferenceStep]
    
    public init(steps: [LaLaInferenceStep]) {
        self.steps = steps
    }
}

public struct LaLaInferenceStep: Sendable {
    public let systemPrompt: String
    public let userPrompt: String
    public let fields: [LaLaResponseField]?
    public let response: String?
    
    public init(systemPrompt: String, userPrompt: String, fields: [LaLaResponseField]?, response: String?) {
        self.systemPrompt = systemPrompt
        self.userPrompt = userPrompt
        self.fields = fields
        self.response = response
    }
}

public struct LaLaResponseField: Sendable, Encodable {
    public let name: String
    public let description: String

    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}
