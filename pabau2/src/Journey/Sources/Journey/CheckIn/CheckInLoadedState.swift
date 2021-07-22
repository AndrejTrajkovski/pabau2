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
	
    var passcodeForDoctorMode: PasscodeState?
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
}

public enum CheckInLoadedAction: Equatable {
    case didTouchHandbackDevice
    case patient(CheckInPatientAction)
    case doctor(CheckInDoctorAction)
    case passcodeForDoctorMode(PasscodeAction)
}

extension CheckInLoadedState {
	
	public init(appointment: Appointment,
				pathway: Pathway,
				template: PathwayTemplate) {
		self.appointment = appointment
		self.pathway = pathway
		self.pathwayTemplate = template
		self.patientStepStates = stepsAndEntries(pathway, template, .patient).map {
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
	
	var isHandBackDeviceActive: Bool {
		get { isPatientComplete == .complete }
		set { isPatientComplete = newValue ? .complete : .pending }
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

func toCheckInForms(stepsActions: [Effect<StepsActions, Never>]) -> [Effect<CheckInContainerAction, Never>] {
    let pipeInits = pipe(CheckInPatientAction.steps,
                         CheckInLoadedAction.patient,
                         CheckInContainerAction.loaded)
    return stepsActions.map { $0.map(pipeInits) }
}

let getFormsForPathway = uncurry(pipe(stepsAndEntries(_:_:_:), curry(getForms(stepsAndEntries:formAPI:clientId:))))
let getCheckInFormsForPathway = pipe(getFormsForPathway, toCheckInForms(stepsActions:))
public func getCheckInFormsOneAfterAnother(pathway: Pathway,
                                           template: PathwayTemplate,
                                           journeyMode: JourneyMode,
                                           formAPI: FormAPI,
                                           clientId: Client.ID) -> Effect<CheckInContainerAction, Never> {
    let effects = with(((pathway, template, journeyMode), formAPI, clientId), getCheckInFormsForPathway)
    print("number of requests:", effects.count)
    return Effect.concatenate(effects)
}

//func getCheckInForms(loadedState: CheckInLoadedState) ->

public func stepsAndEntries(_ pathway: Pathway, _ template: PathwayTemplate, _ journeyMode: JourneyMode) -> [StepAndStepEntry] {
    print("here")
    print(pathway, template)
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
        print(stepAndEntry)
		guard let templateId = stepAndEntry.entry?.htmlFormInfo?.chosenFormTemplateId else {
			return nil
		}
        let pipeInits: (Result<HTMLForm, RequestError>) -> StepAction
        
        if stepAndEntry.entry!.htmlFormInfo!.possibleFormTemplates.count == 1 {
            pipeInits = pipe(HTMLFormAction.gotForm, HTMLFormStepContainerAction.singleForm, StepAction.htmlForm)
        } else {
            pipeInits = pipe(HTMLFormAction.gotForm, MultipleFormsAction.htmlForm, HTMLFormStepContainerAction.multipleForms, StepAction.htmlForm)
        }
        
		return formAPI.getForm(templateId: templateId, entryId: stepAndEntry.entry?.htmlFormInfo?.formEntryId)
			.catchToEffect()
			.map(pipeInits)
        
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
