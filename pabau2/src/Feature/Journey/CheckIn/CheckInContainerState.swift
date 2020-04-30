import Model

enum JourneyMode: Equatable {
	case patient
	case doctor
}

let stepToModeMap: [StepType: JourneyMode] = [
	.patientdetails: .patient,
	.medicalhistory: .patient,
	.consents: .patient,
	.checkpatient: .doctor,
	.treatmentnotes: .doctor,
	.prescriptions: .doctor,
	.photos: .doctor,
	.recalls: .doctor,
	.aftercares: .doctor
//	.mediaimages : .patient,
//	.mediavideos : .patient,
]

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway

	var forms: [MetaFormAndStatus]
	var selectedFormIndex: Int
//	var patientDetails: PatientDetails?
//	var pdCompleted: Bool
//
//	var consents: [FormTemplate]
//	var consentsCompleted: [Bool]
//
//	var medicalHistory: FormTemplate?
//	var mhCompleted: Bool
//
//	var aftercare: Aftercare?
//	var aftercareCompleted: Bool
//
//	var treatments: [FormTemplate]
//	var treatmentsCompleted: [Bool]
//
//	var history: FormTemplate?
//	var historyCompleted: Bool
//
//	var presription: FormTemplate?
//	var presriptionCompleted: Bool

	init(journey: Journey,
			 pathway: Pathway,
			 consents: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.forms = zip(consents.map(MetaForm.template), consents.map { _ in false})
								.map(MetaFormAndStatus.init)
		self.forms += [MetaFormAndStatus(MetaForm.patientDetails(PatientDetails()), false)]
		self.selectedFormIndex = 0
//		self.consents = consents
//		if let patientDetails = patientDetails {
//			self.selectedForm = .patientDetails(patientDetails)
//		} else {
//			self.selectedForm = nil
//		}
//		self.treatments = []
//		self.aftercare = nil
	}
}

extension CheckInContainerState {

//			let steps = pathway.steps.filter { stepToModeMap[$0.stepType] == .patient }
//			var result = [MetaFormAndStatus]()
//			steps.forEach { step in
//				switch step.stepType {
//				case .consents:
//					result += zip(consents.map(MetaForm.template), consentsCompleted)
//						.map(MetaFormAndStatus.init)
//				case .patientdetails:
//					guard let patientDetails = patientDetails else {}
//					result += [MetaFormAndStatus(MetaForm.patientDetails(patientDetails), pdCompleted)]
//				case .medicalhistory:
//					guard let medicalHistory = medicalHistory else {}
//					result += [MetaFormAndStatus(MetaForm.template(medicalHistory), mhCompleted)]
//				case .checkpatient,
//						 .treatmentnotes,
//						 .prescriptions,
//						 .photos,
//						 .recalls,
//						 .aftercares:
//					fatalError("doctor steps, should be filtered earlier")
//				}
//			}
//		}
//	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													consents: [])
	}
}
