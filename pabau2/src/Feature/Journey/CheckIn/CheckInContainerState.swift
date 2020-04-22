import Model

struct CheckInState {
	var journey: Journey
	var pathway: Pathway
	var selectedStepId: Int
	var templates: [FormTemplate]
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway
	var selectedStepId: Int
	var templates: [FormTemplate]

	init(journey: Journey,
			 pathway: Pathway,
			 selectedStepId: Int,
			 templates: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.selectedStepId = selectedStepId
		self.templates = templates
	}

	var selectedTemplate: FormTemplate
	{
		get {
			self.templates.first ?? FormTemplate.defaultEmpty }
		set {
			self.templates.remove(at: 0)
			self.templates.insert(newValue, at: 0)
		}
	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													selectedStepId: 0,
													templates: [])
	}
}
