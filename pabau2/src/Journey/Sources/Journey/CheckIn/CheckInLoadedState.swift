import Model
import ComposableArchitecture
import Overture
import Util
import Form
import ChoosePathway

public struct CheckInLoadedState: Equatable {
	
	public let appointment: Appointment
	public let pathway: Pathway
	public let pathwayTemplate: PathwayTemplate
	
	var patientStepStates: [StepState]
	var doctorStepStates: [StepState]
	
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

extension CheckInLoadedState {
	
	public init(appointment: Appointment,
				pathway: Pathway,
				template: PathwayTemplate) {
		self.appointment = appointment
//		self.patientDetails = patientDetails
		self.pathway = pathway
		self.pathwayTemplate = template
		self.patientStepStates = []
		self.doctorStepStates = []
//		IdentifiedArray(pathway.stepEntries.filter { $0.value.stepType == .medicalhistory }.map { HTMLFormStepContainerState.init(stepId: $0.key, stepEntry: $0.value, clientId: appointment.customerId, pathwayId: pathway.id) })
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
		self.aftercareStatus = false
		self.isPatientComplete = .pending
		self.photos = PhotosState([[:]])
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
	}
}

extension CheckInLoadedState {
	
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

extension CheckInLoadedState {
	
	var doctorCheckIn: CheckInDoctorState {
		get {
			CheckInDoctorState(
				appointment: self.appointment,
				pathway: pathwayTemplate,
				stepStates: self.doctorStepStates,
				doctorSelectedIndex: self.doctorSelectedIndex
			)
		}
		set {
			self.doctorStepStates = newValue.stepStates
			self.doctorSelectedIndex = newValue.doctorSelectedIndex
		}
	}
	
	public var patientCheckIn: CheckInPatientState {
		get {
			CheckInPatientState(
				appointment: appointment,
				pathway: pathway,
				pathwayTemplate: pathwayTemplate,
				stepStates: patientStepStates,
				selectedIdx: patientSelectedIndex
			)
		}
		
		set {
			self.patientStepStates = newValue.stepStates
			self.patientSelectedIndex = newValue.selectedIdx
		}
	}
}

extension Pathway {
	func orderedPatientSteps() -> [Dictionary<Step.ID, StepEntry>.Element] {
		stepEntries.filter { filterPatient($0.value.stepType)}
			.sorted(by: { $0.value.order ?? 0 < $1.value.order ?? 0 })
	}
	
	func orderedDoctorSteps() -> [Dictionary<Step.ID, StepEntry>.Element] {
		stepEntries.filter { filterPatient($0.value.stepType)}
			.sorted(by: { $0.value.order ?? 0 < $1.value.order ?? 0 })
	}
}
