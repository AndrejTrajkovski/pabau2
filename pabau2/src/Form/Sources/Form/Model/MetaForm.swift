import Model

public struct StepFormInfo: Equatable {
	public init(status: Bool, title: String) {
		self.status = status
		self.title = title
	}
	
	public var status: Bool
	public let title: String
}

//@dynamicMemberLookup
//struct FormTemplateAndStatus {
//	var formTemplate: FormTemplate
//	var status: Bool
//
//	public subscript<T>(dynamicMember keyPath: KeyPath<FormTemplate, T>) -> T
//	{
//		return formTemplate[keyPath: keyPath]
//	}
//}
//
//extension FormTemplateAndStatus: MetaForm {
//	public var canProceed: Bool {
//		get {
//			self.formStructure.canProceed
//		}
//	}
//
//	public var title: String {
//		switch self.formType {
//		case .consent, .treatment:
//			return self.name
//		case .history:
//			return "HISTORY"
//		case .prescription:
//			return "PRESCRIPTION"
//		}
//	}
//
//	public var stepType: StepType {
//		switch self.formType {
//		case .consent:
//			return .consents
//		case .history:
//			return .medicalhistory
//		case .prescription:
//			return .prescriptions
//		case .treatment:
//			return .treatmentnotes
//		}
//	}
//}
//
//extension PatientDetails: MetaForm {
//	public var title: String {
//		"ENTER PATIENT DETAILS"
//	}
//	public var stepType: StepType { .patientdetails }
//}
//
//extension Aftercare: MetaForm {
//	public var canProceed: Bool { true }
//	public var title: String { "AFTERCARE" }
//	public var stepType: StepType { .aftercares }
//}
//
//extension PatientComplete: MetaForm {
//	public var canProceed: Bool { true }
//	public var title: String { "COMPLETE" }
//	public var stepType: StepType { .patientComplete }
//}
//
//extension CheckPatient: MetaForm {
//	public var canProceed: Bool { true }
//	public var title: String { "CHECK PATIENT DETAILS" }
//	public var stepType: StepType { .checkpatient }
//}
//
//extension PhotosState: MetaForm {
//	public var canProceed: Bool { !photos.isEmpty }
//	public var title: String { "PHOTOS" }
//	public var stepType: StepType { .photos }
//}
