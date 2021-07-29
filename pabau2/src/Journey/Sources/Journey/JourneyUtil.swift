import Overture
import Model
import Form
import ComposableArchitecture

func flatten<T: Identifiable>(_ list: [T]) -> [T.ID: T] {
	Dictionary(uniqueKeysWithValues: Array(zip(list.map(\.id), list)))
}

func isIn(_ journeyMode: JourneyMode, _ stepType: StepType) -> Bool {
	stepToModeMap(stepType) == journeyMode
}

let filterBy = curry(isIn(_:_:))

let filterPatient = filterBy(.patient)
let filterDoctor = filterBy(.doctor)

func stepToModeMap(_ stepType: StepType) -> JourneyMode {
	switch stepType {
	case .patientdetails: return .patient
	case .medicalhistory: return .patient
	case .consents: return .patient
	case .treatmentnotes: return .doctor
	case .prescriptions: return .doctor
	case .photos: return .doctor
	case .aftercares: return .doctor
    case .lab:
        return .doctor
    case .video:
        return .patient
    case .timeline:
        return .doctor
    }
}

let filterStepType = filterBy
