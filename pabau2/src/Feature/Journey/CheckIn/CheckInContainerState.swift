import Model

enum JourneyMode: Equatable {
	case patient
	case doctor
}

let stepToModeMap: [StepType: JourneyMode] = [
	.patientdetails : .patient,
	.medicalhistory : .patient,
	.consents : .patient,
	.checkpatient : .doctor,
	.treatmentnotes : .doctor,
	.prescriptions : .doctor,
	.photos : .doctor,
	.recalls : .doctor,
	.aftercares : .doctor,
//	.mediaimages : .patient,
//	.mediavideos : .patient,
]

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
	
	init(journey: Journey,
			 pathway: Pathway,
			 selectedStepId: Int,
			 consents: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.selectedStepId = selectedStepId
		self.consents = consents
	}
}

extension CheckInContainerState {
	
	var patient: StepFormsState {
		StepFormsState(journeyMode: .patient,
									 steps: pathway.steps,
									 forms: <#T##[MetaForm]#>, runningForms: <#T##[MetaForm]#>, selectedFormIndex: <#T##Int#>, completedForms: <#T##[Int : Bool]#>)
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
