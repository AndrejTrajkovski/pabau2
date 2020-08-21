import Model
import ComposableArchitecture
import Overture
import Util
import Form

//TODO: Remove this and use IdentifiedArray from TCA
//protocol MyCollection {
//	associatedtype A: Identifiable
//	var byId: [A.ID: A] { get set }
//	var allIds: [A.ID] { get set }
//	var completed: [A.ID: Bool] { get set }
//}
//
//extension MyCollection {
//	var sorted: [A] {
//		allIds.map { byId[$0]! }
//	}
//}
//
//protocol EmptyInitializable {
//	init ()
//}
//
//extension MyCollection where Self: EmptyInitializable {
//	init(ids: [A.ID],
//		   fromAll: [A]) {
//		self.init()
//		self.allIds = ids
//		self.byId = flatten(fromAll.filter(pipe(get(\A.id), ids.contains)))
//		self.completed = allIds.reduce(into: [:], { $0[$1] = false })
//	}
//}
//
//extension MyCollection where A == FormTemplate {
//	func toMetaFormArray() -> [MetaFormAndStatus] {
//		return sorted.map {
//			let form = MetaForm.template($0)
//			guard let status = completed[$0.id] else { fatalError() }
//			return MetaFormAndStatus(form, status)
//		}
//	}
//}
//
//struct FormsCollection: MyCollection, Equatable, EmptyInitializable {
//	var byId: [Int: FormTemplate] = [:]
//	var allIds: [Int] = []
//	var completed: [Int: Bool] = [:]
//}
//
enum JourneyMode: Equatable {
	case patient
	case doctor
}

struct StepForms: Equatable, Identifiable {
	var stepType: StepType
	var forms: IdentifiedArrayOf<MetaFormAndStatus>
	var selectedIndex: Int
	var id: StepType { stepType }
	var isComplete: Bool {
		self.forms.allSatisfy(\.isComplete)
	}
}

public struct CheckInContainerState: Equatable {
	
	var patientArray: IdentifiedArrayOf<StepForms>
	var doctorArray: IdentifiedArrayOf<StepForms>
	
	var journey: Journey
	
	var allTreatmentForms: IdentifiedArrayOf<FormTemplate>
	var allConsents: IdentifiedArrayOf<FormTemplate>

	var selectedConsentsIds: [Int]
	var selectedTreatmentFormsIds: [Int]

//	var consents: IdentifiedArrayOf<MetaFormAndStatus>
//	var treatments: IdentifiedArrayOf<MetaFormAndStatus>

//	var aftercare: Aftercare
//	var aftercareCompleted: Bool

//	var patientDetails: PatientDetails
//	var patientDetailsCompleted: Bool

//	var patientComplete: PatientComplete

//	var checkPatientCompleted: Bool

//	var medHistory: FormTemplate
//	var medHistoryCompleted: Bool

	var patientSelectedStepType: StepType
	var doctorSelectedStepType: StepType
	var patientSelectedIndex: Int
	var doctorSelectedIndex: Int

//	var photosState: PhotosState
//	var photosCompleted: Bool

	var passcodeState = PasscodeState()
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
	var didGoBackToPatientMode: Bool = false
}

extension CheckInContainerState {

	var patientCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: patientSelectedIndex,
				forms: patientArray,
				selectedStepType: patientSelectedStepType,
				xButtonActiveFlag: true, //handled in checkInMiddleware
				journey: journey,
				journeyMode: .patient)
		}
		set {
			self.patientSelectedIndex = newValue.selectedIndex
			self.patientArray = newValue.forms
			self.patientSelectedStepType = newValue.selectedStepType
			self.journey = newValue.journey
		}
	}

	var doctorCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: doctorSelectedIndex,
				forms: doctorArray,
				selectedStepType: doctorSelectedStepType,
				xButtonActiveFlag: isDoctorCheckInMainActive,
				journey: journey,
				journeyMode: .doctor)
		}
		set {
			self.doctorSelectedIndex = newValue.selectedIndex
			self.doctorArray = newValue.forms
			self.doctorSelectedStepType = newValue.selectedStepType
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

	var chooseTreatments: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
				forms: doctorArray[id: .treatmentnotes]?.forms ?? [],
				templates: allTreatmentForms,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedTreatmentFormsIds
			)
		}
		set {
			self.doctorArray[id: .treatmentnotes]?.forms = newValue.forms
			self.allTreatmentForms = newValue.templates
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
		}
	}
	
	var chooseConsents: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
				forms: self.patientArray[id: .consents]?.forms ?? [],
				templates: allConsents,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedConsentsIds
			)
		}
		set {
			self.patientArray[id: .consents]?.forms = newValue.forms
			self.allConsents = newValue.templates
			self.selectedConsentsIds = newValue.selectedTemplatesIds
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
			return extract(case: MetaForm.patientComplete,
										 from: patientArray[id: .patientComplete]!.forms.first!.form)!
						.isPatientComplete
		}
		set {
			let patientComplete = MetaForm.patientComplete(PatientComplete(isPatientComplete: newValue))
			let old = patientArray[id: .patientComplete]!.forms.first!
			let newForm = MetaFormAndStatus(patientComplete,
																			old.isComplete,
																			index: old.index)
			patientArray[id: .patientComplete]!.forms = [newForm]
		}
	}

	var checkPatient: CheckPatient {
		let patDetailsWrapped = patientArray[id: .patientdetails]?.forms.first?.form
		let patDetails = extract(case: MetaForm.patientDetails,
														 from: patDetailsWrapped)
		let medHistory = patientArray[id: .medicalhistory]?.forms.elements ?? []
		let consents = patientArray[id: .consents]?.forms.elements ?? []
		let patientForms = (medHistory + consents)
			.map(\.form)
			.compactMap { extract(case: MetaForm.template, from: $0) }
		return CheckPatient(patDetails: patDetails,
												patForms: patientForms)
	}

	var handback: HandBackDeviceState {
		get {
			HandBackDeviceState(isEnterPasscodeActive: self.isEnterPasscodeActive,
													isNavBarHidden: !self.passcode.passcode.unlocked
			)
		}
	}
}

extension CheckInContainerState {

	init(journey: Journey,
			 pathway: Pathway,
			 patientDetails: PatientDetails,
			 medHistory: FormTemplate,
			 consents: IdentifiedArrayOf<FormTemplate>,
			 allConsents: IdentifiedArrayOf<FormTemplate>,
			 patientComplete: PatientComplete = PatientComplete(isPatientComplete: false),
			 photosState: PhotosState) {
		self.journey = journey
		var stepTypes = pathway.steps.map { $0.stepType }
		stepTypes.append(StepType.patientComplete)
		self.allConsents = allConsents
		self.allTreatmentForms = IdentifiedArray(FormTemplate.mockTreatmentN)
		
//		self.consents = consents
//		self.treatments = FormsCollection(ids: [], fromAll: [])
//		self.aftercare = JourneyMocks.aftercare
//		self.aftercareCompleted = false
//		self.patientDetails = patientDetails
//		self.patientDetailsCompleted = false
//		self.patientComplete = patientComplete
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
//		self.runningPrescriptions = [:]
//		self.prescriptionsCompleted = [:]
//		self.checkPatientCompleted = false
//		self.medHistory = FormTemplate.getMedHistory()
//		self.medHistoryCompleted = false
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
//		self.photosState = photosState
//		self.photosCompleted = false
	}
}

extension IdentifiedArrayOf where Element == StepForms {
	var photosState: PhotosState {
		get {
			return extract(case: MetaForm.photos,
										 from: self[id: StepType.photos as! ID]!.forms.first!.form)!
		}
		set {
			self[id: StepType.photos as! ID]!.forms[0].form = MetaForm.photos(newValue)
		}
	}
}
