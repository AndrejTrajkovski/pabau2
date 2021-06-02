import Model
import ComposableArchitecture
import Overture
import Util
import Form
import ChoosePathway

public struct CheckInParentState: Equatable {
	public var loadingOrLoaded: CheckInLoadingOrLoadedState
	var isAnimationFinished: Bool = false
	let appointment: Appointment
	
	public init(loadedState: CheckInContainerState) {
		self.loadingOrLoaded = .loaded(loadedState)
		self.appointment = loadedState.appointment
	}
	
	public init(loadingState: CheckInLoadingState) {
		self.loadingOrLoaded = .loading(loadingState)
		self.appointment = loadingState.appointment
	}
}

public enum CheckInLoadingOrLoadedState: Equatable {
	case loading(CheckInLoadingState)
	case loaded(CheckInContainerState)
}

public struct CheckInInfo: Equatable {
	let appointment: Appointment
	let pathwayId: Pathway.ID
	let pathwayTemplateId: PathwayTemplate.ID
}

public struct CheckInLoadingState: Equatable {
	public let appointment: Appointment
	public var pathwaysLoadingState: LoadingState
	public let pathwayId: Pathway.ID
	public let pathwayTemplateId: PathwayTemplate.ID
	
	public init(
		appointment: Appointment,
		pathwayId: Pathway.ID,
		pathwayTemplateId: PathwayTemplate.ID,
		pathwaysLoadingState: LoadingState
	) {
		self.appointment = appointment
		self.pathwayId = pathwayId
		self.pathwayTemplateId = pathwayTemplateId
		self.pathwaysLoadingState = pathwaysLoadingState
	}
}

public struct CheckInContainerState: Equatable {
	
	let appointment: Appointment
	var pathway: Pathway
	let pathwayTemplate: PathwayTemplate
	
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
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
}

extension CheckInContainerState {
	
	public init(appointment: Appointment,
				pathway: Pathway,
				template: PathwayTemplate) {
		self.appointment = appointment
//		self.patientDetails = patientDetails
		self.pathway = pathway
		self.pathwayTemplate = template
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
	
	var passcode: PasscodeContainerState {
		get {
			PasscodeContainerState(
				passcode: self.passcodeState,
				isDoctorCheckInMainActive: self.isDoctorCheckInMainActive
			)
		}
		set {
			self.passcodeState = newValue.passcode
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
				pathway: pathwayTemplate,
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
				pathway: pathwayTemplate,
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
