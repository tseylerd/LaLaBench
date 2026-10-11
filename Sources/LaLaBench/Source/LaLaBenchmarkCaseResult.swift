public struct LaLaBenchmarkCaseResult: Codable, Sendable {
    public let followedInstructions: Bool
    public let followedFormat: Bool
    public let addressesTheRequest: Bool
    public let isAccurate: Bool
    public let score: Int // 1-5
    public let rationale: String
}
