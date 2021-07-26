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
	
    public var patientCheckIn: CheckInPathwayState
    public var doctorCheckIn: CheckInPathwayState
    
    var isHandBackDeviceActive: Bool = false
	
    var passcodeForDoctorMode: PasscodeState?
	var isDoctorCheckInMainActive: Bool = false
}

public enum CheckInLoadedAction: Equatable {
    case didTouchHandbackDevice
    case patient(CheckInPathwayAction)
    case doctor(CheckInPathwayAction)
    case passcodeForDoctorMode(PasscodeAction)
}

extension CheckInLoadedState {
	
	public init(appointment: Appointment,
				pathway: Pathway,
				template: PathwayTemplate) {
		self.appointment = appointment
		self.pathway = pathway
		self.pathwayTemplate = template
		let patientStepStates = stepsAndEntries(pathway, template, .patient).map {
            StepState.init(stepAndEntry: $0, clientId: appointment.customerId, pathway: pathway, appId: appointment.id)
		}
        self.patientCheckIn = CheckInPathwayState(appointment: appointment,
                                                  pathway: pathway,
                                                  pathwayTemplate: pathwayTemplate,
                                                  stepStates: patientStepStates,
                                                  selectedIdx: 0)
		let doctorStepStates = stepsAndEntries(pathway, pathwayTemplate, .doctor).map {
            StepState.init(stepAndEntry: $0, clientId: appointment.customerId, pathway: pathway, appId: appointment.id)
		}
        self.doctorCheckIn = CheckInPathwayState(appointment: appointment,
                                                 pathway: pathway,
                                                 pathwayTemplate: pathwayTemplate,
                                                 stepStates: doctorStepStates,
                                                 selectedIdx: 0)
	}
}

let pipeToContainerAction = pipe(CheckInPathwayAction.steps,
                                 CheckInLoadedAction.patient,
                                 CheckInContainerAction.loaded)

let pipeToLoadedAction = pipe(CheckInPathwayAction.steps,
                              CheckInLoadedAction.patient)

func toActions<Action>(_ pipeToAction: @escaping (StepsActions) -> Action, stepsActions: [Effect<StepsActions, Never>]) -> [Effect<Action, Never>] {
    return stepsActions.map { $0.map(pipeToAction) }
}

func toLoadedActions(stepsActions: [Effect<StepsActions, Never>]) -> [Effect<CheckInLoadedAction, Never>] {
    return toActions(pipeToLoadedAction, stepsActions: stepsActions)
}

func toCheckContainerAction(stepsActions: [Effect<StepsActions, Never>]) -> [Effect<CheckInContainerAction, Never>] {
    return toActions(pipeToContainerAction, stepsActions: stepsActions)
}


let getFormsForPathway = uncurry(pipe(stepsAndEntries(_:_:_:), curry(getForms(stepsAndEntries:formAPI:clientId:))))

let getCheckInFormsForPathway = pipe(getFormsForPathway, toCheckContainerAction(stepsActions:))
let getLoadedActionsFormsForPathway = pipe(getFormsForPathway, toLoadedActions(stepsActions:))

func getLoadedActionsOneAfterAnother(_ pathway: Pathway,
                                     _ template: PathwayTemplate,
                                     _ journeyMode: JourneyMode,
                                     _ formAPI: FormAPI,
                                     _ clientId: Client.ID) -> Effect<CheckInLoadedAction, Never> {
    let effects = with(((pathway, template, journeyMode), formAPI, clientId), getLoadedActionsFormsForPathway)
    return Effect.concatenate(effects)
}

public func getCheckInFormsOneAfterAnother(pathway: Pathway,
                                           template: PathwayTemplate,
                                           journeyMode: JourneyMode,
                                           formAPI: FormAPI,
                                           clientId: Client.ID) -> Effect<CheckInContainerAction, Never> {
    let effects = with(((pathway, template, journeyMode), formAPI, clientId), getCheckInFormsForPathway)
    return Effect.concatenate(effects)
}

//func getCheckInForms(loadedState: CheckInLoadedState) ->

public func stepsAndEntries(_ pathway: Pathway, _ template: PathwayTemplate, _ journeyMode: JourneyMode) -> [StepAndStepEntry] {
    print("here")
    print(pathway, template)
	return template.steps
        .filter(\.stepType.isHandledOniOS)
		.filter { isIn(journeyMode, $0.stepType) }
		.map { StepAndStepEntry(step: $0, entry: pathway.stepEntries[$0.id]) }
}

func getForms(stepsAndEntries: [StepAndStepEntry], formAPI: FormAPI, clientId: Client.ID) -> [Effect<StepsActions, Never>] {
	let stepActions: [Effect<StepsActions, Never>] = stepsAndEntries.indices.compactMap { idx in
			let stepAndEntry = stepsAndEntries[idx]
			if let getForm = getForm(stepAndEntry: stepAndEntry, formAPI: formAPI, clientId: clientId) {
                return getForm.map { StepsActions.steps(idx: idx, action: StepAction.stepType($0)) }
			} else {
				return nil
			}
		}
	return stepActions
}

func getForm(stepAndEntry: StepAndStepEntry, formAPI: FormAPI, clientId: Client.ID) -> Effect<StepBodyAction, Never>? {
	if stepAndEntry.step.stepType.isHTMLForm {
        print(stepAndEntry)
		guard let templateToGet = stepAndEntry.entry?.htmlFormInfo?.chosenFormTemplateId else {
			return nil
		}
        
//        let templateToGet: HTMLForm.ID
//        if let templateId = stepAndEntry.entry?.htmlFormInfo?.chosenFormTemplateId {
//            templateToGet = templateId
//        } else if let firstOfPossible = stepAndEntry.entry?.htmlFormInfo?.possibleFormTemplates.first?.id {
//            templateToGet = firstOfPossible
//        } else {
//            return nil
//        }
        
        let pipeInits: (Result<HTMLForm, RequestError>) -> StepBodyAction = pipe(HTMLFormAction.gotForm, HTMLFormStepContainerAction.chosenForm, StepBodyAction.htmlForm)
        
		return formAPI.getForm(templateId: templateToGet, entryId: stepAndEntry.entry?.htmlFormInfo?.formEntryId)
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
				.map(pipe(PatientDetailsParentAction.gotGETResponse, StepBodyAction.patientDetails))
		case .aftercares:
			return nil
		case .checkpatient:
			return nil
		case .photos:
			return nil
        case .lab:
            return nil
        case .video:
            return nil
        case .timeline:
            return nil
        }
	}
}
