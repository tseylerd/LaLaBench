@testable import LaLaBench
import MLXLMCommon

@LaLaBenchmarkActor
final class PromptInterceptor: LaLaBenchmarkInferenceEngine {
    var prompts: [InterceptedPrompt] = []
    
    func infer(system: String, user: String) async throws -> LaLaBenchmarkCaseResult? {
        prompts.append(InterceptedPrompt(system: system.trimmingCharacters(in: .whitespacesAndNewlines), user: user.trimmingCharacters(in: .whitespacesAndNewlines)))
        
        return nil
    }
}

struct InterceptedPrompt {
    let system: String
    let user: String
}
