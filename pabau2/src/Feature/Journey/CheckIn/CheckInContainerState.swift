import Model

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway

	init(journey: Journey,
			 pathway: Pathway,
			 templates: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
//		self.templates = templates
//		self.steps = pathway.steps.reduce(into: [:], {
//			$0[$1.id] = $1
//		})
//		self.templateByStep = pathway.steps.reduce(into: [:], {
//			$0[$1.id] = $1.formTemplate?.first!.id
//		})
	}

	var selectedStepId: Int = 0
//	var completedSteps = [Int: Bool]()
//	var steps = [Int: Step]()
//	var templates = [FormTemplate]()
//	var templateByStep = [Int: Int]()
	public var selectedTemplate: FormTemplate
	=
		FormTemplate(id: 1,
								 name: "Consent - Hair Extension",
								 formType: .consent,
						 ePaper: false,
						 formStructure:
	FormStructure(formStructure: [
		CSSField(id: 1, cssClass:
			.checkboxes(
				[
					CheckBoxChoice(1, "choice 1", true),
					CheckBoxChoice(2, "choice 2", false),
					CheckBoxChoice(3, "choice 3", false)
				]
			)
		),
		CSSField(id: 2, cssClass:
			.checkboxes(
				[
					CheckBoxChoice(4, "choice 4", false),
					CheckBoxChoice(5, "choice 5", false),
					CheckBoxChoice(6, "choice 6", true)
				]
			)
		),
		CSSField(id: 3,
						 cssClass: .staticText(
							StaticText(1, "Hey what's going on?"))
		),
		CSSField(id: 4,
						 cssClass: .radio(Radio(4,
																		[RadioChoice(1, "radio choice 1"),
																		 RadioChoice(2, "radio choice 2")],
																		1)
			)
		)
	]))
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													templates: [])
	}
}
