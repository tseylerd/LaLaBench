import FoundationModels

@Generable(description: "A strict evaluation result of the final response of a multi-step AI assistant inference trace: a brief rationale with a verdict per criterion, four pass/fail booleans that are consistent with the rationale, and a score from 1 to 5.")
public struct LaLaBenchmarkCaseResult: Codable, Sendable {
    @Guide(description: "true if the final result follows every explicit instruction that the chain of steps imposes on it (actions to perform, things to avoid, language, length limits), whether stated in the final step or in any earlier step. false if any stated instruction is violated.")
    public let followedInstructions: Bool
    @Guide(description: "true if the final result matches the output format required of it (structure, fields, order, encoding) by the final step's system prompt and by anything the chain of steps specifies about the final output. false on any structural deviation.")
    public let followedFormat: Bool
    @Guide(description: "true if the final result is on point and covers what the final step asked for and, transitively, what the whole chain of steps was intended to produce. false if it answers something else, dodges the point, or covers only part of the request.")
    public let addressesTheRequest: Bool
    @Guide(description: "true if every factual claim in the final result is correct, including the parts carried over from earlier steps: nothing is contradicted or distorted relative to what earlier steps produced. false if it contains factual errors.")
    public let isAccurate: Bool
    @Guide(description: "Overall quality from 1 to 5: 5 = fully correct and complete, 4 = correct with one minor issue, 3 = partially correct with a clearly flawed core answer, 2 = mostly wrong, 1 = fails the core task (off-topic, unparseable, or empty). Must be consistent with the booleans and the rationale.")
    public let score: Int // 1-5
    @Guide(description: "Brief evaluation: what the chain of steps asked for, what the final result did, and a verdict per criterion. The booleans and the score must be consistent with this reasoning.")
    public let rationale: String
}
