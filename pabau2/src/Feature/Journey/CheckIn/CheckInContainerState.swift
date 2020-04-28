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
	var consents: [FormTemplate]
//	var currentFields: [CSSField]
	
	init(journey: Journey,
			 pathway: Pathway,
			 selectedStepId: Int,
			 consents: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.selectedStepId = selectedStepId
		self.consents = consents
//		self.currentFields = consents.first?.formStructure.formStructure ?? []
	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													selectedStepId: 0,
													consents: [])
	}
}
