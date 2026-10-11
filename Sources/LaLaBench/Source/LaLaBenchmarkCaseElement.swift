public enum LaLaBenchmarkCaseElement: Sendable {
    case success(result: LaLaBenchmarkCaseResult)
    case failure(error: String)
}
