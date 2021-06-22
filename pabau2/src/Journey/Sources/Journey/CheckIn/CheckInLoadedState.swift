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
		self.patientStepStates = stepEntries(pathway, pathwayTemplate, .patient)
		self.doctorStepStates = stepEntries(pathway, pathwayTemplate, .doctor)
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

public let getFormsForPathway = pipe(stepEntries(_:_:_:), curry(getForms(stepEntries:formAPI:clientId:)))

public func stepEntries(_ pathway: Pathway, _ template: PathwayTemplate, _ journeyMode: JourneyMode) -> [StepEntry] {
	return template.steps.compactMap { pathway.stepEntries[$0.id] }
		.filter { isIn(journeyMode, $0.stepType) }
}

func getForms(stepEntries: [StepEntry], formAPI: FormAPI, clientId: Client.ID) -> [Effect<StepsActions, Never>] {
	let stepActions: [Effect<StepsActions, Never>] = stepEntries.indices.compactMap { idx in
			let stepEntry = stepEntries[idx]
			if let getForm = getForm(stepEntry: stepEntry, formAPI: formAPI, clientId: clientId) {
				return getForm.map { StepsActions.steps(idx: idx, action: $0) }
			} else {
				return nil
			}
		}
	return stepActions
}

func getForm(stepEntry: StepEntry, formAPI: FormAPI, clientId: Client.ID) -> Effect<StepAction, Never>? {
	if stepEntry.stepType.isHTMLForm {
		guard let templateId = stepEntry.htmlFormInfo?.templateIdToLoad else {
			return nil
		}
		
		return formAPI.getForm(templateId: templateId, entryId: stepEntry.htmlFormInfo?.formEntryId)
			.catchToEffect()
			.map(pipe(HTMLFormAction.gotForm, HTMLFormStepContainerAction.htmlForm, StepAction.htmlForm))
	} else {
		switch stepEntry.stepType {
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
		case .patientComplete:
			return nil
		}
	}
}
