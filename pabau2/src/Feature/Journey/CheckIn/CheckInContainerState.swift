import Model
import ComposableArchitecture
import Overture
import Util

protocol MyCollection {
	associatedtype A: Identifiable
	var byId: [A.ID: A] { get set }
	var allIds: [A.ID] { get set }
}

struct FormsCollection: MyCollection, Equatable {
	typealias A = FormTemplate
	var byId: [Int : FormTemplate]
	var allIds: [Int]
	var completed: [Int: Bool]
	var sorted: [FormTemplate] {
		allIds.map { byId[$0]! }
	}
	
	init(ids: [Int],
		   fromAll: [FormTemplate]) {
		self.allIds = ids
		self.byId = flatten(fromAll.filter(pipe(get(\FormTemplate.id), ids.contains)))
		self.completed = allIds.reduce(into: [:], { $0[$1] = false })
	}
}

enum JourneyMode: Equatable {
	case patient
	case doctor
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var stepTypes: [StepType]
	var runningPrescriptions: [Int: FormTemplate]
	var prescriptionsCompleted: [Int: Bool]
	
	var allTreatmentForms: [Int: FormTemplate]
	var allConsents: [Int: FormTemplate]
	
	var selectedConsentsIds: [Int]
	var selectedTreatmentFormsIds: [Int]
	
	var consents: FormsCollection
	var treatments: FormsCollection
//	var consentsCompleted: [Int: Bool]
//	var runningConsents: [Int: FormTemplate]
//	var treatmentFormsCompleted: [Int: Bool]
//	var runningTreatmentForms: [Int: FormTemplate]
	
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

	var passcodeState = PasscodeState()
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
	var didGoBackToPatientMode: Bool = false
}

extension CheckInContainerState {

	//TODO: OPTIMIZE FILTERING ON PATIENT VS DOCTOR
	var patientArray: [MetaFormAndStatus] {
		get {
			return transformInFormsArray(.patient, self)
		}
		set {
			transformBack(.patient, newValue, &self)
		}
	}

	var doctorArray: [MetaFormAndStatus] {
		get {
			return transformInFormsArray(.doctor, self)
		}
		set {
			transformBack(.doctor, newValue, &self)
		}
	}
}

extension CheckInContainerState {
	
	var patientCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: patientSelectedIndex,
				forms: patientArray,
				xButtonActiveFlag: true,//handled in checkInMiddleware
				journey: journey)
		}
		set {
			self.patientSelectedIndex = newValue.selectedIndex
			self.patientArray = newValue.forms
			self.journey = newValue.journey
		}
	}

	var doctorCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: doctorSelectedIndex,
				forms: doctorArray,
				xButtonActiveFlag: isDoctorCheckInMainActive,
				journey: journey)
		}
		set {
			self.doctorSelectedIndex = newValue.selectedIndex
			self.doctorArray = newValue.forms
			self.isDoctorCheckInMainActive = newValue.xButtonActiveFlag
			self.journey = newValue.journey
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
														 templates: allTreatmentForms,
														 templatesLoadingState: .initial,
														 selectedTemplatesIds:
				selectedTreatmentFormsIds,
														 forms: treatments)
		}
		set {
			self.allTreatmentForms = newValue.templates
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
			self.treatments = newValue.forms
		}
	}

	var chooseConsents: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 templates: allConsents,
														 templatesLoadingState: .initial,
														 selectedTemplatesIds: selectedConsentsIds,
														 forms: consents)
		}
		set {
			self.allConsents = newValue.templates
			self.selectedConsentsIds = newValue.selectedTemplatesIds
			self.consents = newValue.forms
		}
	}

	var passcode: PasscodeContainerState {
		get {
			PasscodeContainerState(
				passcode: self.passcodeState,
				didGoBackToPatientMode: self.didGoBackToPatientMode,
				isDoctorCheckInMainActive: self.isDoctorCheckInMainActive
			)
		}
		set {
			self.passcodeState = newValue.passcode
			self.didGoBackToPatientMode = newValue.didGoBackToPatientMode
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var isHandBackDeviceActive: Bool {
		get {
			let pcform = patientArray.filter { stepType(form: $0.form) == .patientComplete }.first!
			let res = extract(case: MetaForm.patientComplete,
												from: pcform.form)!
				.isPatientComplete
			return res
		}
		set {
			self.patientComplete.isPatientComplete = newValue
		}
	}
	
	var checkPatient: CheckPatient {
		let forms = [medHistory] + self.consents.sorted
		return CheckPatient(patDetails: self.patientDetails,
												patForms: forms)
	}
	
	var handback: HandBackDeviceState {
		get {
			HandBackDeviceState(isEnterPasscodeActive: self.isEnterPasscodeActive,
													isNavBarHidden: !self.passcode.passcode.unlocked
//														&& self.isEnterPasscodeActive
			)
		}
	}
}

extension CheckInContainerState {

	init(journey: Journey,
			 pathway: Pathway,
			 patientDetails: PatientDetails,
			 medHistory: FormTemplate,
			 consents: FormsCollection,
			 allConsents: [Int: FormTemplate],
			 patientComplete: PatientComplete = PatientComplete(isPatientComplete: true)) {
		self.journey = journey
		self.stepTypes = pathway.steps.map { $0.stepType }
		self.stepTypes.append(StepType.patientComplete)
		self.allConsents = allConsents
		self.allTreatmentForms = flatten(JourneyMockAPI.mockTreatmentN)
		self.consents = consents
		self.treatments = FormsCollection(ids: [], fromAll: [])
		self.aftercare = Aftercare()
		self.aftercareCompleted = false
		self.patientDetails = patientDetails
		self.patientDetailsCompleted = false
		self.patientComplete = patientComplete
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
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
	}
}
