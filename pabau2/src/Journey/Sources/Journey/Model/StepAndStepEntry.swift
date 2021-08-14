import Model

public struct StepAndStepEntry: Equatable {
    let step: Step
    let entry: StepEntry?
    
    public init(step: Step,
                entry: StepEntry?) {
        self.step = step
        self.entry = entry
    }
}
