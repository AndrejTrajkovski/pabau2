import Model

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway

	init(journey: Journey,
			 pathway: Pathway,
			 templates: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.templates = templates
		self.steps = pathway.steps.reduce(into: [:], {
			$0[$1.id] = $1
		})
		self.templateByStep = pathway.steps.reduce(into: [:], {
//			$0[$1.id] = $1.formTemplate?.map(\.id)
			$0[$1.id] = $1.formTemplate?.first!.id
		})
	}

	var selectedStepId: Int = 0
	var completedSteps = [Int: Bool]()
	var steps = [Int: Step]()
	var templates = [FormTemplate]()
	var templateByStep = [Int: Int]()
	var selectedTemplate: FormTemplate {
		templates.filter{ $0.id == templateByStep[selectedStepId] }.first!
	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													templates: [])
	}
}
