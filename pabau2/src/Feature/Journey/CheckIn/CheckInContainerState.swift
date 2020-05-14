import Model
import ComposableArchitecture
import Overture

enum JourneyMode: Equatable {
	case patient
	case doctor
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway
	
	var runningPrescriptions: [Int: FormTemplate]
	var prescriptionsCompleted: [Int: Bool]
	
	var allConsents: [Int: FormTemplate]
	var selectedConsentsIds: [Int]
	var consentsCompleted: [Int: Bool]
	var runningConsents: [Int: FormTemplate]
	
	var allTreatmentForms: [Int: FormTemplate]
	var selectedTreatmentFormsIds: [Int]
	var treatmentFormsCompleted: [Int: Bool]
	var runningTreatmentForms: [Int: FormTemplate]
	
	var aftercare: Aftercare
	var aftercareCompleted: Bool
	
	var patientDetails: PatientDetails
	var patientDetailsCompleted: Bool
	
	var patientComplete: PatientComplete
	
	var checkPatientCompleted: Bool
	
	var medHistory: FormTemplate
	var medHistoryCompleted: Bool
	
	var patientSelectedIndex: Int
	var doctorSelectedIndex: Int
	
	var photosCompleted: Bool
	var recall: Recall
	var recallCompleted: Bool
	
	var runningDigits: [String] = []
	var unlocked: Bool = false
	var wrongAttempts: Int = 0

	//NAVIGATION
	var isHandBackDeviceActive: Bool = false
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isPatientCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false

	init(journey: Journey,
			 pathway: Pathway,
			 patientDetails: PatientDetails,
			 medHistory: FormTemplate,
			 allConsents: [Int: FormTemplate],
			 selectedConsentsIds: [Int]) {
		self.journey = journey
		self.pathway = pathway
		self.allConsents = allConsents
		self.selectedConsentsIds = selectedConsentsIds
		self.allTreatmentForms = flatten(JourneyMockAPI.mockTreatmentN)
		self.runningConsents = selected(allConsents, selectedConsentsIds)
		self.runningTreatmentForms = [:]
		self.consentsCompleted = [:]
		self.selectedTreatmentFormsIds = []
		self.treatmentFormsCompleted = [:]
		self.aftercare = Aftercare()
		self.aftercareCompleted = false
		self.patientDetails = PatientDetails()
		self.patientDetailsCompleted = false
		self.patientComplete = PatientComplete()
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
		self.runningPrescriptions = [:]
		self.prescriptionsCompleted = [:]
		self.checkPatientCompleted = false
		self.photosCompleted = false
		self.recall = Recall()
		self.recallCompleted = false
		self.medHistory = JourneyMockAPI.getMedHistory()
		self.medHistoryCompleted = false
	}
}

func indexOfStep(_ pathway: Pathway,
								 _ journeyMode: JourneyMode,
								 _ stepType: StepType) -> Int? {
	return pathway.steps
		.filter(with(.patient, filterStepType))
		.sorted(by: \.stepType.order)
		.firstIndex(where: { $0.stepType == stepType })
}

struct PatientCheckInState: Equatable {
	var isPatientCheckInMainActive: Bool
	var journey: Journey
	var patientSelectedIndex: Int
	var pathway: Pathway
	var medHistory: FormTemplate
	var medHistoryCompleted: Bool
	var patientDetails: PatientDetails
	var patientDetailsCompleted: Bool
	var patientComplete: PatientComplete
	var consentsCompleted: [Int: Bool]
	var runningConsents: [Int: FormTemplate]
	
//	var patientSteps: [Step] {
//		self.pathway.steps.filter(with(.patient, filterStepType))
//	}
	
	var topView: TopViewState {
		get {
			TopViewState(totalSteps: formsArray.count,
									 completedSteps: 2,
									 xButtonActiveFlag: isPatientCheckInMainActive,
									 journey: journey)
		}
		set {
			self.isPatientCheckInMainActive = newValue.xButtonActiveFlag
		}
	}
	
	func wrapForm(_ stepType: StepType) -> [MetaFormAndStatus] {
		switch stepType {
		case .patientdetails:
			let form = MetaForm.patientDetails(patientDetails)
			return [MetaFormAndStatus(form, patientDetailsCompleted)]
		case .medicalhistory:
			let form = MetaForm.template(medHistory)
			return [MetaFormAndStatus(form, medHistoryCompleted)]
		case .consents:
			return runningConsents.map {
				let form = MetaForm.template($0.value)
				guard let status = consentsCompleted[$0.value.id] else { fatalError() }
				return MetaFormAndStatus(form, status)
			}
		case .checkpatient,
				 .treatmentnotes,
				 .prescriptions,
				 .photos,
				 .recalls,
				 .aftercares:
			fatalError("doctor steps, should be filtered earlier")
		case .patientComplete:
			let form = MetaForm.patientComplete(patientComplete)
			return [MetaFormAndStatus(form, false)]
		}
	}
	
	mutating func unwrap(_ metaFormAndStatus: MetaFormAndStatus) {
		let metaForm = metaFormAndStatus.form
		let isComplete = metaFormAndStatus.isComplete
		switch stepType(form: metaForm) {
		case .patientdetails:
			self.patientDetails = extract(case: MetaForm.patientDetails, from: metaForm)!
			self.patientDetailsCompleted = isComplete
		case .medicalhistory:
			self.medHistory = extract(case: MetaForm.template, from: metaForm)!
			self.medHistoryCompleted = isComplete
		case .consents:
			let consent = extract(case: MetaForm.template, from: metaForm)!
			self.runningConsents[consent.id] = consent
			self.consentsCompleted[consent.id] = isComplete
		case .checkpatient,
				 .treatmentnotes,
				 .prescriptions,
				 .photos,
				 .recalls,
				 .aftercares:
			fatalError("doctor steps, should be filtered earlier")
		case .patientComplete:
			self.patientComplete = extract(case: MetaForm.patientComplete, from: metaForm)!
		}
	}
	
	var formsArray: [MetaForm] {
		get {
			self.pathway.steps
				.filter(with(.patient, filterStepType))
				.reduce(into: [MetaForm]()) {
					$0.append(contentsOf: with($1, (pipe(get(\.stepType), wrapForm(_:)))))
			}.sorted(by: their(pipe(stepType(form:), get(\.order))))
		}
		set {
			newValue.forEach { unwrap($0) }
		}
	}
}

struct DoctorCheckInState: Equatable {
	var doctorSelectedIndex: Int
	var pathway: Pathway
	var aftercare: Aftercare
	var aftercareCompleted: Bool
	var runningTreatmentForms: [Int: FormTemplate]
	var treatmentFormsCompleted: [Int: Bool]
	var checkPatientCompleted: Bool
	var runningPrescriptions: [Int: FormTemplate]
	var prescriptionsCompleted: [Int: Bool]
	var photosCompleted: Bool
	var recall: Recall
	var recallCompleted: Bool
}

let filterStepTypeFlipped = pipe(get(\Step.stepType), flip(filterBy))
let filterStepType = flip(filterStepTypeFlipped)

struct CheckInViewState: Equatable {
	var selectedIndex: Int
	var forms: [Int: MetaForm]
	var completedForms: [Int: Bool]
	var order: [Int]
}

func selected(_ templates: [Int: FormTemplate], _ selectedIds: [Int]) -> [Int: FormTemplate] {
	templates.filter { selectedIds.contains($0.key) }
}

extension CheckInContainerState {
	
	var doctorCheckIn: DoctorCheckInState {
		get {
			DoctorCheckInState(
				doctorSelectedIndex: doctorSelectedIndex,
				pathway: pathway,
				aftercare: aftercare,
				aftercareCompleted: aftercareCompleted,
				runningTreatmentForms: runningTreatmentForms,
				treatmentFormsCompleted: treatmentFormsCompleted,
				checkPatientCompleted: checkPatientCompleted,
				runningPrescriptions: runningPrescriptions,
				prescriptionsCompleted: prescriptionsCompleted,
				photosCompleted: photosCompleted,
				recall: recall,
				recallCompleted: recallCompleted
			)
		}
		set {
			self.doctorSelectedIndex = newValue.doctorSelectedIndex
			self.pathway = newValue.pathway
			self.aftercare = newValue.aftercare
			self.aftercareCompleted = newValue.aftercareCompleted
			self.runningTreatmentForms = newValue.runningTreatmentForms
			self.treatmentFormsCompleted = newValue.treatmentFormsCompleted
			self.checkPatientCompleted = newValue.checkPatientCompleted
			self.runningPrescriptions = newValue.runningPrescriptions
			self.prescriptionsCompleted = newValue.prescriptionsCompleted
			self.photosCompleted = newValue.photosCompleted
			self.recall = newValue.recall
			self.recallCompleted = newValue.recallCompleted
		}
	}
	
	var patientCheckIn: PatientCheckInState {
		get { PatientCheckInState(patientSelectedIndex: patientSelectedIndex,
															pathway: pathway,
															medHistory: medHistory,
															medHistoryCompleted: medHistoryCompleted,
															patientDetails: patientDetails,
															patientDetailsCompleted: patientDetailsCompleted,
															patientComplete: patientComplete,
															consentsCompleted: consentsCompleted,
															runningConsents: runningConsents)
		}
		set {
			self.patientSelectedIndex = newValue.patientSelectedIndex
			self.pathway = newValue.pathway
			self.medHistory = newValue.medHistory
			self.medHistoryCompleted = newValue.medHistoryCompleted
			self.patientDetails = newValue.patientDetails
			self.patientDetailsCompleted = newValue.patientDetailsCompleted
			self.patientComplete = newValue.patientComplete
			self.runningConsents = newValue.runningConsents
			self.consentsCompleted = newValue.consentsCompleted
		}
	}
	
	var doctorSummary: DoctorSummaryState {
		get {
			DoctorSummaryState(journey: journey,
												 isChooseConsentActive: isChooseConsentActive,
												 isChooseTreatmentActive: isChooseTreatmentActive,
												 isDoctorCheckInMainActive: isDoctorCheckInMainActive,
												 doctorCheckIn: doctorCheckIn)
		}
		set {
			self.journey = newValue.journey
			self.doctorCheckIn = newValue.doctorCheckIn
			self.isChooseConsentActive = newValue.isChooseConsentActive
			self.isChooseTreatmentActive = newValue.isChooseTreatmentActive
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var chooseTreatments: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 selectedPathway: pathway,
														 selectedTemplatesIds: selectedTreatmentFormsIds,
														 templates: allTreatmentForms,
														 templatesLoadingState: .initial)
		}
		set {
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
		}
	}

	var chooseConsents: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 selectedPathway: pathway,
														 selectedTemplatesIds: selectedConsentsIds,
														 templates: allConsents,
														 templatesLoadingState: .initial)
		}
		set {
			self.selectedConsentsIds = newValue.selectedTemplatesIds
		}
	}
	
	var passcode: PasscodeState {
		get {
			PasscodeState(runningDigits: self.runningDigits,
										unlocked: self.unlocked,
										isDoctorSummaryActive: self.isDoctorSummaryActive, wrongAttempts: self.wrongAttempts)
		}
		set {
			self.runningDigits = newValue.runningDigits
			self.unlocked = newValue.unlocked
			self.isDoctorSummaryActive = newValue.isDoctorSummaryActive
			self.wrongAttempts = newValue.wrongAttempts
		}
	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													patientDetails: PatientDetails(),
													medHistory: FormTemplate.defaultEmpty,
													allConsents: [:],
													selectedConsentsIds: []
		)
	}
}

//extension CheckInViewState {
//	static func doctorForms(_ stepType: StepType,
//													_ patientDetails: PatientDetails,
//													_ treatmentN: [Int: FormTemplate],
//													_ prescriptions: [FormTemplate],
//													_ pdComplete: Bool,
//													_ treatmentNComplete: [Int: Bool]
//	) -> [MetaFormAndStatus] {
//		switch stepType {
//		case .checkpatient:
//			return [MetaFormAndStatus(MetaForm.patientDetails(patientDetails), false)]
//		case .treatmentnotes:
//			return zip(
//				treatmentN.map(MetaForm.template), treatmentN.map { _ in false })
//				.map(MetaFormAndStatus.init)
//		case .prescriptions:
//			return zip(
//				prescriptions.map(MetaForm.template), prescriptions.map { _ in false })
//				.map(MetaFormAndStatus.init)
//		case .photos:
//			return []//TODO
//		case .recalls:
//			return []//TODO
//		case .aftercares:
//			return []//TODO
//		case .patientdetails,
//				 .medicalhistory,
//				 .consents:
//			fatalError("patient steps, should be filtered earlier")
//		case .patientComplete:
//			return []
//		}
//	}
//
//	static func patientForms(_ stepType: StepType,
//													 _ patientDetails: PatientDetails,
//													 _ medHistory: FormTemplate,
//													 _ consents: [FormTemplate]) -> [MetaFormAndStatus] {
//		switch stepType {
//		case .patientdetails:
//			return [MetaFormAndStatus(MetaForm.patientDetails(patientDetails), false)]
//		case .medicalhistory:
//			return [MetaFormAndStatus(MetaForm.template(medHistory), false)]
//		case .consents:
//			return zip(
//				consents.map(MetaForm.template), consents.map { _ in false })
//				.map(MetaFormAndStatus.init)
//		case .checkpatient,
//				 .treatmentnotes,
//				 .prescriptions,
//				 .photos,
//				 .recalls,
//				 .aftercares:
//			fatalError("doctor steps, should be filtered earlier")
//		case .patientComplete:
//			return [MetaFormAndStatus(MetaForm.patientComplete(PatientComplete()), false)]
//		}
//	}
//}

//static func doctor(_ pathway: Pathway,
//									 _ patientDetails: PatientDetails,
//									 _ treatmentN: [FormTemplate],
//									 _ prescriptions: [FormTemplate]
//) -> StepsState {
//	let patientSteps: [StepState] =
//		pathway.steps.map { $0.stepType }
//			.filter { stepToModeMap($0) == .doctor }
//			.map {
//				StepState(stepType: $0,
//									forms: Self.doctorForms($0,
//																					patientDetails,
//																					treatmentN,
//																					[JourneyMockAPI.getPrescription()])
//				)
//	}.sorted(by: { $0.stepType.order < $1.stepType.order })
//	return StepsState(stepsState: patientSteps,
//										selectedIndex: 0)
//}
//
//static func patient(_ pathway: Pathway,
//										_ patientDetails: PatientDetails,
//										_ medHistory: FormTemplate,
//										_ consents: [FormTemplate]) -> StepsState {
//	var stepTypes = pathway.steps.map { $0.stepType }
//	stepTypes.append(.patientComplete)
//	let patientSteps: [StepState] =
//		stepTypes
//			.filter { stepToModeMap($0) == .patient }
//			.map {
//				StepState(stepType: $0, forms: Self.patientForms($0,
//																												 patientDetails,
//																												 medHistory,
//																												 consents)
//				)
//	}.sorted(by: { $0.stepType.order < $1.stepType.order })
//	return StepsState(stepsState: patientSteps,
//										selectedIndex: 0)
//}
