import Model
import Form

struct PathwayHTMLFormParentState: Equatable {
	
	public var step: Step
	public var stepEntry: StepEntry
	public var htmlForm: HTMLFormParentState
	
	init(step: Step,
		 stepEntry: StepEntry,
		 htmlForm: HTMLFormParentState) {
		self.step = step
		self.stepEntry = stepEntry
		self.htmlForm = htmlForm
	}
}
