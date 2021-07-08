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
	
	var isPatientComplete: StepStatus = .pending
	
	var selectedConsentsIds: [HTMLForm.ID]
	var selectedTreatmentFormsIds: [HTMLForm.ID]
	
	var patientSelectedIndex: Int
	var doctorSelectedIndex: Int
	
	var passcodeStateForDoctorMode = PasscodeState()
	var isEnterPasscodeForDoctorModeActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
}

public enum CheckInLoadedAction: Equatable {
    case didTouchHandbackDevice
    case patient(CheckInPatientAction)
    case doctor(CheckInDoctorAction)
    case passcode(PasscodeAction)
}

extension CheckInLoadedState {
	
	public init(appointment: Appointment,
				pathway: Pathway,
				template: PathwayTemplate) {
		self.appointment = appointment
		self.pathway = pathway
		self.pathwayTemplate = template
		self.patientStepStates = stepsAndEntries(pathway, pathwayTemplate, .patient).map {
			StepState.init(stepAndEntry: $0, clientId: appointment.customerId, pathway: pathway)
		}
		self.doctorStepStates = stepsAndEntries(pathway, pathwayTemplate, .doctor).map {
			StepState.init(stepAndEntry: $0, clientId: appointment.customerId, pathway: pathway)
		}
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
	}
}

extension CheckInLoadedState {
	
	var passcode: PasscodeContainerState {
		get {
			PasscodeContainerState(
				passcode: self.passcodeStateForDoctorMode,
				isDoctorCheckInMainActive: self.isDoctorCheckInMainActive
			)
		}
		set {
			self.passcodeStateForDoctorMode = newValue.passcode
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}
	
	var isHandBackDeviceActive: Bool {
		get { isPatientComplete == .complete }
		set { isPatientComplete = newValue ? .complete : .pending }
	}
	
	var handback: HandBackDeviceState {
		get {
			HandBackDeviceState(isEnterPasscodeActive: self.isEnterPasscodeForDoctorModeActive,
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

public let getFormsForPathway = uncurry(pipe(stepsAndEntries(_:_:_:), curry(getForms(stepsAndEntries:formAPI:clientId:))))

public func stepsAndEntries(_ pathway: Pathway, _ template: PathwayTemplate, _ journeyMode: JourneyMode) -> [StepAndStepEntry] {
	return template.steps
		.filter { isIn(journeyMode, $0.stepType) }
		.map { StepAndStepEntry(step: $0, entry: pathway.stepEntries[$0.id]) }
		
}

func getForms(stepsAndEntries: [StepAndStepEntry], formAPI: FormAPI, clientId: Client.ID) -> [Effect<StepsActions, Never>] {
	let stepActions: [Effect<StepsActions, Never>] = stepsAndEntries.indices.compactMap { idx in
			let stepAndEntry = stepsAndEntries[idx]
			if let getForm = getForm(stepAndEntry: stepAndEntry, formAPI: formAPI, clientId: clientId) {
				return getForm.map { StepsActions.steps(idx: idx, action: $0) }
			} else {
				return nil
			}
		}
	return stepActions
}

func getForm(stepAndEntry: StepAndStepEntry, formAPI: FormAPI, clientId: Client.ID) -> Effect<StepAction, Never>? {
	if stepAndEntry.step.stepType.isHTMLForm {
		guard let templateId = stepAndEntry.entry?.htmlFormInfo?.templateIdToLoad else {
			return nil
		}
		
		return formAPI.getForm(templateId: templateId, entryId: stepAndEntry.entry?.htmlFormInfo?.formEntryId)
			.catchToEffect()
			.map(pipe(HTMLFormAction.gotForm, HTMLFormStepContainerAction.htmlForm, StepAction.htmlForm))
	} else {
		switch stepAndEntry.step.stepType {
		case .consents, .medicalhistory, .treatmentnotes, .prescriptions:
			fatalError("should be handled previously")
		case .patientdetails:
			return formAPI.getPatientDetails(clientId: clientId)
				.catchToEffect()
				.map { $0.map(ClientBuilder.init(client:))}
				.map(pipe(PatientDetailsParentAction.gotGETResponse, StepAction.patientDetails))
		case .aftercares:
			return nil
		case .checkpatient:
			return nil
		case .photos:
			return nil
		}
	}
}
