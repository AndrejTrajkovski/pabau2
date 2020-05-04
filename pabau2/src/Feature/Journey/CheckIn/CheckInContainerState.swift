import Model
import CasePaths

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
]

struct FormsState: Equatable {
	var forms: [MetaFormAndStatus]
	var selectedIndex: Int
	init (_ forms: [MetaFormAndStatus], _ selectedIndex: Int) {
		self.forms = forms
		self.selectedIndex = selectedIndex
	}
}

extension FormsState {
	var isOnCompleteStep: Bool {
		self.forms.firstIndex(where: { $0.form == .patientComplete }) ==
		selectedIndex
	}
}

struct DoctorStep {
	let stepName: String
	let isComplete: String
	let forms: [MetaFormAndStatus]
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway

	var patientForms: [MetaFormAndStatus]
	var patientSelectedIndex: Int
	var doctorForms: [MetaFormAndStatus]
	var doctorSelectedIndex: Int
	var treatmentForms: [FormTemplate]
//	var doctorForms: [MetaFormAndStatus]
//	var selectedFormIndex: Int
	//NAVIGATION
	var isDoctorSummaryActive: Bool
//	var patientMode: Bool = false
//	var handBackDevice: Bool = false
//	var passcode: Bool = false
//	var chooseTreatment: Bool = false
	var journeySummary: Bool = false
	var doctorMode: Bool = false

	init(journey: Journey,
			 pathway: Pathway,
			 consents: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.patientForms = []
		self.patientForms += [MetaFormAndStatus(MetaForm.patientDetails(PatientDetails()), false)]
		self.patientForms += zip(consents.map(MetaForm.template), consents.map { _ in false})
		.map(MetaFormAndStatus.init)
		self.patientForms += [MetaFormAndStatus(MetaForm.patientComplete, false)]
		self.patientSelectedIndex = 0
		self.doctorForms = []
		self.doctorSelectedIndex = 0
		self.treatmentForms = JourneyMockAPI.mockConsents
		self.isDoctorSummaryActive = false
		
//		let steps = pathway.steps.filter { stepToModeMap[$0.stepType] == .doctor }
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
	var doctor: FormsState {
		get {
			FormsState(self.doctorForms, self.doctorSelectedIndex)
		}
		set {
			self.doctorForms = newValue.forms
			self.doctorSelectedIndex = newValue.selectedIndex
		}
	}

	var patient: FormsState {
		get {
			FormsState(self.patientForms, self.patientSelectedIndex)
		}
		set {
			self.patientForms = newValue.forms
			self.patientSelectedIndex = newValue.selectedIndex
		}
	}
	
	var chooseTreatments: ChooseFormState {
		get {
			let ids = doctorForms
				.map{ $0.form }
				.compactMap { extract(case: MetaForm.template, from: $0) }
				.map({ $0.id })
			return ChooseFormState(selectedJourney: journey,
											selectedPathway: pathway,
											selectedTemplatesIds: ids,
											templates: treatmentForms,
											templatesLoadingState: .initial)
		}
		set {
			self.doctorForms = newValue.templates.filter { newValue.selectedTemplatesIds.contains($0.id )}
				.map { MetaForm.template($0) }
				.map { MetaFormAndStatus.init( $0, false)}
			self.treatmentForms = newValue.templates
		}
	}
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
