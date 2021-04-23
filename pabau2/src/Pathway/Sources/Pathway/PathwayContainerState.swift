import Model

public struct PathwayContainerState: Equatable {
	
	init(
		appointment: Appointment,
		pathway: Pathway,
		pathwayTemplate: PathwayTemplate
	) {
		self.appointment = appointment
		self.pathway = pathway
		self.pathwayTemplate = pathwayTemplate
		self.steps = makeSteps(pathway: pathway, template: pathwayTemplate, appointment: appointment)
		self.selectedIdx = 0
	}
	
	let appointment: Appointment
	let pathway: Pathway
	let pathwayTemplate: PathwayTemplate
	var steps: [StepState]
	var selectedIdx: Int
}
