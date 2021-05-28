import Model
import ComposableArchitecture
import Overture
import Util
import Form
import ChoosePathway

public struct CheckInContainerState: Equatable {
	
	let appointment: Appointment
	let choosePathway: ChoosePathwayState
//	let pathway: Pathway
//	let pathwayTemplate: PathwayTemplate
	
	var isPatientModeActive: Bool = false
	
	var patientDetailsLS: LoadingState
	var patientDetails: ClientBuilder?
	var patientDetailsStatus: StepStatus
	
	var medicalHistories: IdentifiedArrayOf<HTMLFormParentState>
	
	var consents: IdentifiedArrayOf<HTMLFormParentState>
	
	var treatmentNotes: IdentifiedArrayOf<HTMLFormParentState>
	
	var prescriptions: IdentifiedArrayOf<HTMLFormParentState>
	
	var aftercare: Aftercare?
	var aftercareStatus: Bool
	
	var isPatientComplete: StepStatus
	
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
	
	public init(appointment: Appointment) {
		self.appointment = appointment
		self.choosePathway = ChoosePathwayState(selectedAppointment: appointment)
//		self.patientDetails = patientDetails
		self.medicalHistories = []
		self.consents = []
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
		self.treatmentNotes = []
		self.prescriptions = []
		self.aftercareStatus = false
		self.isPatientComplete = .pending
		self.photos = PhotosState([[:]])
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
		self.patientDetailsLS = .initial
		self.patientDetailsStatus = .pending
	}
}


extension CheckInContainerState {
	
	var doctorSummary: DoctorSummaryState {
		get {
			DoctorSummaryState(appointment: appointment,
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
		get { isPatientComplete == .complete }
		set { isPatientComplete = newValue ? .complete : .pending }
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
	
	var doctorCheckIn: CheckInDoctorState {
		get {
			CheckInDoctorState(
				appointment: self.appointment,
				pathway: self.choosePathway.selectedPathway!,
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
				appointment: appointment,
				pathway: self.choosePathway.selectedPathway!,
				patientDetails: patientDetails!,
				patientDetailsStatus: patientDetailsStatus,
				medicalHistories: medicalHistories,
				consents: consents,
				isPatientComplete: isPatientComplete,
				selectedIdx: patientSelectedIndex,
				patientDetailsLS: patientDetailsLS
			)
		}
		
		set {
			self.patientDetails = newValue.patientDetails
			self.patientDetailsStatus = newValue.patientDetailsStatus
			self.medicalHistories = newValue.medicalHistories
			self.consents = newValue.consents
			self.isPatientComplete = newValue.isPatientComplete
			self.patientSelectedIndex = newValue.selectedIdx
			self.patientDetailsLS = newValue.patientDetailsLS
		}
	}
}
