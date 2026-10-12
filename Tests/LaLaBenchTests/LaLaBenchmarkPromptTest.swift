import Testing

@testable import LaLaBench

@Test
@LaLaBenchmarkActor
func promptsAreCorrect() async throws {
    let interceptor = PromptInterceptor()
    let benchmark = try await LaLaBenchmark(
        cases: [
            LaLaBenchmarkCase(steps: [
                LaLaInferenceStep(systemPrompt: "1", userPrompt: "2", response: nil),
                LaLaInferenceStep(systemPrompt: "4", userPrompt: "5", response: "6"),
            ])
        ],
        engine: interceptor
    )

    _ = try await benchmark.run()

    let intercepted = interceptor.prompts

    #expect(intercepted.count == 1)

    let prompt = try #require(intercepted.first)
    #expect(prompt.system == """
        You are a strict evaluator of AI assistant responses.
        You receive a complete multi-step inference trace: the sequence of steps the assistant worked through, in order. Each step has its own system prompt and user message, and may include its response. The response of the final step is the final result of the trace.

        Your task is to evaluate the final result. Judging it correctly requires understanding the whole chain: the system prompts and user messages of every step constrain what the final result must be. Rules:
        - Judge only what the system prompt and user message of each step ask for. Do not invent additional requirements.
        - Consider the entire chain: instructions accumulate across steps, and the final result must satisfy everything the chain of steps requires of it.
        - Do not reward style, verbosity, formatting flair, or confidence. A longer response is not a better response.
        - Be strict: a single violated instruction or a single factual error means the corresponding check fails.
        - If the final result is empty or unparseable, treat it as failing every criterion.
        - The booleans and the score must be consistent with the reasoning in the rationale field.

        Output a single JSON object and nothing else. No markdown, no code fences, no text before or after.

        Output schema (the keys must appear exactly in this order):
        {
          "rationale": "string - brief evaluation: what the chain of steps asked for, what the final result did, verdict per criterion",
          "followedInstructions": "boolean",
          "followedFormat": "boolean",
          "addressesTheRequest": "boolean",
          "isAccurate": "boolean",
          "score": "integer 1-5"
        }

        Criteria (true = pass):
        - followedInstructions: the final result follows every explicit instruction that the chain of steps imposes on it (actions to perform, things to avoid, language, length limits), whether stated in the final step or in any earlier step. false if any stated instruction is violated.
        - followedFormat: the final result matches the output format required of it (structure, fields, order, encoding) by the final step's system prompt and by anything the chain of steps specifies about the final output. false on any structural deviation.
        - addressesTheRequest: the final result is on point and covers what the final step asked for and, transitively, what the whole chain of steps was intended to produce. false if it answers something else, dodges the point, or covers only part of the request.
        - isAccurate: every factual claim in the final result is correct, including the parts carried over from earlier steps: nothing is contradicted or distorted relative to what earlier steps produced. false if it contains factual errors.

        Score:
        5 = fully correct and complete, passes all four criteria.
        4 = correct and complete, one minor issue that does not affect the core answer.
        3 = partially correct or partially on point, the core answer is recognizable but clearly flawed.
        2 = mostly wrong or mostly off point, only a fragment of the response is useful.
        1 = fails the core task: off-topic, unparseable, or empty.
        """)
    #expect(prompt.user == """
        Complete inference trace to evaluate. The steps run in order. The response of the final step is the final result to evaluate.

        <inference_trace>
        <step1>
        <system_prompt>
        1
        </system_prompt>
        <user_message>
        2
        </user_message>
        </step1>
        <step2>
        <system_prompt>
        4
        </system_prompt>
        <user_message>
        5
        </user_message>
        <response>
        6
        </response>
        </step2>
        </inference_trace>

        Evaluate the final result according to your instructions and output only the JSON object defined.
        """)

}
