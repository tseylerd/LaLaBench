import Foundation

struct LaLaBenchmarkUtil {
    static let SYSTEM_PROMPT = loadPrompt(named: "system")
    static let USER_PROMPT = loadPrompt(named: "user")

    private static let STEPS_PROMPT_PARAMETER = "{{steps}}"

    private init() { }
        
    static func findBundle(called: String) -> URL? {
        return Bundle.module.url(forResource: called, withExtension: "bundle")
    }
    
    static func read(_ url: URL) -> String? {
        let data = FileManager.default.contents(atPath: url.path)
        
        guard let data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    static func apply(benchmarkCase: LaLaBenchmarkCase, into: String) -> String {
        into.replacingOccurrences(of: STEPS_PROMPT_PARAMETER, with: render(steps: benchmarkCase.steps))
    }
    
    private static func loadPrompt(named: String) -> String {
        guard let bundle = findBundle(called: "Prompts") else {
            fatalError("Failed to find bundle with prompts")
        }
        
        let dir = bundle.appendingPathComponent("\(named).txt")
        guard let content = read(dir) else {
            fatalError("Failed to read \(named) prompt")
        }
        
        return content
    }
    
    private static func render(steps: [LaLaInferenceStep]) -> String {
        steps.enumerated()
            .map { index, step in
                let stepTag = "<step\(index + 1)>"
                let responseBlock = if let response = step.response {
                    """
                    \n<response>
                    \(response)
                    </response>
                    """
                } else {
                    ""
                }
                return """
                \(stepTag)
                <system_prompt>
                \(step.systemPrompt)
                </system_prompt>
                <user_message>
                \(step.userPrompt)
                </user_message>\(responseBlock)
                </step\(index + 1)>
                """
            }
            .joined(separator: "\n")
    }
    
}
