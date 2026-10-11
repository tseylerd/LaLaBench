import Foundation

public struct LaLaBenchmarkResult: Sendable {
    public let instructionFollowingRate: Double
    public let formatFollowingRate: Double
    public let requestAddressedRate: Double
    public let accuracyRate: Double
    public let averageScore: Double
    public let benchmarkFailureRate: Double
    
    public let results: [LaLaBenchmarkCaseElement]
}
