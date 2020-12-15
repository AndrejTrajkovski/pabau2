import Model
import ComposableArchitecture
import Overture
import Util
import Form

public struct CheckInContainerState: Equatable {

	let journey: Journey
	let pathway: Pathway

	var patientDetails: PatientDetails
	var patientDetailsStatus: Bool

	var medicalHistory: FormTemplate
	var medicalHistoryStatus: Bool

	var consents: IdentifiedArrayOf<FormTemplate>
	var consentsStatuses: [FormTemplate.ID: Bool]

	var treatmentNotes: IdentifiedArrayOf<FormTemplate>
	var treatmentNotesStatuses: [FormTemplate.ID: Bool]

	var prescriptions: IdentifiedArrayOf<FormTemplate>
	var prescriptionsStatuses: [FormTemplate.ID: Bool]

	var allTreatmentForms: IdentifiedArrayOf<FormTemplate>
	var allConsents: IdentifiedArrayOf<FormTemplate>

	var aftercare: Aftercare?
	var aftercareStatus: Bool

	var isPatientComplete: Bool

	var photos: PhotosState

	var selectedConsentsIds: [FormTemplate.ID]
	var selectedTreatmentFormsIds: [FormTemplate.ID]

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
				forms: treatmentNotes,
				templates: allTreatmentForms,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedTreatmentFormsIds
			)
		}
		set {
			treatmentNotes = newValue.forms
			self.allTreatmentForms = newValue.templates
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
		}
	}

	var chooseConsents: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
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
		 pathway: Pathway,
		 patientDetails: PatientDetails,
		 medHistory: FormTemplate,
		 consents: IdentifiedArrayOf<FormTemplate>,
		 allConsents: IdentifiedArrayOf<FormTemplate>,
		 photosState: PhotosState) {
		self.journey = journey
		self.pathway = pathway
		self.patientDetails = patientDetails
		self.medicalHistory = medHistory
		self.consents = consents
		self.allConsents = allConsents
		self.allTreatmentForms = IdentifiedArray(FormTemplate.mockTreatmentN)
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
		self.patientDetailsStatus = false
		self.medicalHistoryStatus = false
		self.consentsStatuses = Dictionary.init(grouping: consents, by: { $0.id }).mapValues { _ in return false }
		self.treatmentNotes = []
		self.treatmentNotesStatuses = [:]
		self.prescriptions = []
		self.prescriptionsStatuses = [:]
		self.aftercareStatus = false
		self.isPatientComplete = false
		self.photos = PhotosState([[:]])
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
	}
}

extension CheckInContainerState {

	var doctorCheckIn: CheckInDoctorState {
		get {
			CheckInDoctorState(
				journey: self.journey,
				pathway: self.pathway,
				treatmentNotes: self.treatmentNotes,
				treatmentNotesStatuses: self.treatmentNotesStatuses,
				prescriptions: self.prescriptions,
				prescriptionsStatuses: self.prescriptionsStatuses,
				aftercare: self.aftercare,
				aftercareStatus: self.aftercareStatus,
				photos: self.photos,
				doctorSelectedIndex: self.doctorSelectedIndex
			)
		}
		set {
			self.treatmentNotes = newValue.treatmentNotes
			self.treatmentNotesStatuses = newValue.treatmentNotesStatuses
			self.prescriptions = newValue.prescriptions
			self.prescriptionsStatuses = newValue.prescriptionsStatuses
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
				medicalHistory: medicalHistory,
				medicalHistoryStatus: medicalHistoryStatus,
				consents: consents,
				consentsStatuses: consentsStatuses,
				isPatientComplete: isPatientComplete,
				selectedIdx: patientSelectedIndex)
		}

		set {
			self.patientDetails = newValue.patientDetails
			self.patientDetailsStatus = newValue.patientDetailsStatus
			self.medicalHistory = newValue.medicalHistory
			self.medicalHistoryStatus = newValue.medicalHistoryStatus
			self.consents = newValue.consents
			self.consentsStatuses = newValue.consentsStatuses
			self.isPatientComplete = newValue.isPatientComplete
			self.patientSelectedIndex = newValue.selectedIdx
		}
	}
}
