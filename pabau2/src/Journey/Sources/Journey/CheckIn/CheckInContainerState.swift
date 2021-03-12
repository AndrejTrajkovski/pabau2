import Model
import ComposableArchitecture
import Overture
import Util
import Form

public struct CheckInContainerState: Equatable {

	let journey: Journey
	let pathway: PathwayTemplate

	var patientDetailsLS: LoadingState
	var patientDetails: ClientBuilder
	var patientDetailsStatus: Bool

	var medicalHistoryId: HTMLForm.ID
	var medicalHistory: HTMLFormParentState

	var consents: IdentifiedArrayOf<HTMLFormParentState>

	var treatmentNotes: IdentifiedArrayOf<HTMLFormParentState>

	var prescriptions: IdentifiedArrayOf<HTMLFormParentState>

	var allTreatmentForms: IdentifiedArrayOf<FormTemplateInfo>
	var allConsents: IdentifiedArrayOf<FormTemplateInfo>

	var aftercare: Aftercare?
	var aftercareStatus: Bool

	var isPatientComplete: Bool

	var photos: PhotosState

	var selectedConsentsIds: [HTMLForm.ID]
	var selectedTreatmentFormsIds: [HTMLForm.ID]

	var patientSelectedIndex: Int
	var doctorSelectedIndex: Int

	var passcodeState = PasscodeState()
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
	var didGoBackToPatientMode: Bool = false
}

extension CheckInContainerState {

	var doctorSummary: DoctorSummaryState {
		get {
			DoctorSummaryState(journey: journey,
							   isChooseConsentActive: isChooseConsentActive,
							   isChooseTreatmentActive: isChooseTreatmentActive,
							   isDoctorCheckInMainActive: isDoctorCheckInMainActive,
							   doctorCheckIn: doctorCheckIn)
		}
		set {
			self.doctorCheckIn = newValue.doctorCheckIn
			self.isChooseConsentActive = newValue.isChooseConsentActive
			self.isChooseTreatmentActive = newValue.isChooseTreatmentActive
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var chooseTreatments: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
				mode: .treatmentNotes,
				forms: treatmentNotes,
				templates: allTreatmentForms,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedTreatmentFormsIds
			)
		}
		set {
			self.treatmentNotes = newValue.forms
			self.allTreatmentForms = newValue.templates
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
		}
	}

	var chooseConsents: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
				mode: .consentsCheckIn,
				forms: consents,
				templates: allConsents,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedConsentsIds
			)
		}
		set {
			self.consents = newValue.forms
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
		get { isPatientComplete }
		set { isPatientComplete = newValue }
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
		 pathway: PathwayTemplate,
		 patientDetails: ClientBuilder,
		 medicalHistoryId: HTMLForm.ID,
		 medHistory: HTMLFormParentState,
		 consents: IdentifiedArrayOf<FormTemplateInfo>,
		 allConsents: IdentifiedArrayOf<FormTemplateInfo>,
		 photosState: PhotosState) {
		self.journey = journey
		self.pathway = pathway
		self.patientDetails = patientDetails
		self.medicalHistory = medHistory
		self.consents = []
		self.allConsents = allConsents
		self.allTreatmentForms = []
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
		self.treatmentNotes = []
		self.prescriptions = []
		self.aftercareStatus = false
		self.isPatientComplete = false
		self.photos = PhotosState([[:]])
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
		self.patientDetailsLS = .initial
		self.medicalHistoryId = medicalHistoryId
		self.patientDetailsStatus = false
	}
}

extension CheckInContainerState {

	var doctorCheckIn: CheckInDoctorState {
		get {
			CheckInDoctorState(
				journey: self.journey,
				pathway: self.pathway,
				treatmentNotes: self.treatmentNotes,
				prescriptions: self.prescriptions,
				aftercare: self.aftercare,
				aftercareStatus: self.aftercareStatus,
				photos: self.photos,
				doctorSelectedIndex: self.doctorSelectedIndex
			)
		}
		set {
			self.treatmentNotes = newValue.treatmentNotes
			self.prescriptions = newValue.prescriptions
			self.aftercare = newValue.aftercare
			self.aftercareStatus = newValue.aftercareStatus
			self.photos = newValue.photos
			self.doctorSelectedIndex = newValue.doctorSelectedIndex
		}
	}

	var patientCheckIn: CheckInPatientState {
		get {
			CheckInPatientState(
				journey: journey,
				pathway: pathway,
				patientDetails: patientDetails,
				patientDetailsStatus: patientDetailsStatus,
				medicalHistoryId: medicalHistoryId,
				medicalHistory: medicalHistory,
				consents: consents,
				isPatientComplete: isPatientComplete,
				selectedIdx: patientSelectedIndex,
				patientDetailsLS: patientDetailsLS
			)
		}

		set {
			self.patientDetails = newValue.patientDetails
			self.patientDetailsStatus = newValue.patientDetailsStatus
			self.medicalHistory = newValue.medicalHistory
			self.consents = newValue.consents
			self.isPatientComplete = newValue.isPatientComplete
			self.patientSelectedIndex = newValue.selectedIdx
			self.patientDetailsLS = newValue.patientDetailsLS
		}
	}
}
