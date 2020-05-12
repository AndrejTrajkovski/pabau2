import Model
import ComposableArchitecture

enum JourneyMode: Equatable {
	case patient
	case doctor
}

func stepToModeMap(_ stepType: StepType) -> JourneyMode {
	switch stepType {
	case .patientdetails: return .patient
	case .medicalhistory: return .patient
	case .consents: return .patient
	case .patientComplete: return .patient
	case .checkpatient: return .doctor
	case .treatmentnotes: return .doctor
	case .prescriptions: return .doctor
	case .photos: return .doctor
	case .recalls: return .doctor
	case .aftercares: return .doctor
	}
}

func stepType(form: MetaForm) -> StepType {
	switch form {
	case .aftercare(_):
		return .aftercares
	case .template(let template):
		return stepType(type: template.formType)
	case .patientDetails(_):
		return .patientdetails
	case .patientComplete:
		return .patientComplete
	}
}

func stepType(type: FormType) -> StepType {
	switch type {
	case .consent:
		return .consents
	case .history:
		return .medicalhistory
	case .prescription:
		return .prescriptions
	case .treatment:
		return .treatmentnotes
	}
}

public struct StepsState: Equatable {
	var stepsState: [StepState]
	var selectedIndex: Int
	var forms: [MetaFormAndStatus] {
		get { self.stepsState.flatMap(\.forms) }
		set {
			let grouped: [StepType: [MetaFormAndStatus]] =
				Dictionary.init(grouping: newValue,
												by: { stepType(form: $0.form) })
			let result = grouped.reduce(into: [StepState](), {
				$0.append(StepState.init(stepType: $1.key, forms: $1.value))
			})
			self.stepsState = result.sorted(by: { $0.stepType.order < $1.stepType.order })
		}
	}

	var isOnCompleteStep: Bool {
		self.forms.firstIndex(where: { extract(case: MetaForm.patientComplete, from: $0.form) != nil }) ==
		selectedIndex
	}
}

struct StepState: Equatable {
	let stepType: StepType
	var isComplete: Bool {
		return self.forms.map { $0.isComplete }.allSatisfy { $0 == true }
	}
//	var title: String {
//		return stepType.title.uppercased()
//	}
	var forms: [MetaFormAndStatus]
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway
	//	var patientForms: [MetaFormAndStatus]
	//	var patientSelectedIndex: Int
	//	var doctorForms: [MetaFormAndStatus]
	//	var doctorSelectedIndex: Int
	var treatmentForms: [FormTemplate]
	var doctor: StepsState
	var patient: StepsState
	//	var doctorForms: [MetaFormAndStatus]
	//	var selectedFormIndex: Int

	var runningDigits: [String] = []
	var unlocked: Bool = false
	var wrongAttempts: Int = 0

	//NAVIGATION
	var isHandBackDeviceActive: Bool = false
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isPatientCheckInMainActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false

	init(journey: Journey,
			 pathway: Pathway,
			 patientDetails: PatientDetails,
			 medHistory: FormTemplate,
			 consents: [FormTemplate]) {
		self.journey = journey
		self.pathway = pathway
		self.patient = Self.patient(pathway,
																patientDetails,
																medHistory,
																consents)
		self.doctor = Self.doctor(pathway,
															patientDetails,
															[],
															[])
		self.treatmentForms = JourneyMockAPI.mockTreatmentN
	}

	static func doctor(_ pathway: Pathway,
										 _ patientDetails: PatientDetails,
										 _ treatmentN: [FormTemplate],
										 _ prescriptions: [FormTemplate]
	) -> StepsState {
		let patientSteps: [StepState] =
			pathway.steps.map { $0.stepType }
				.filter { stepToModeMap($0) == .doctor }
				.map {
					StepState(stepType: $0,
										forms: Self.doctorForms($0,
																						patientDetails,
																						treatmentN,
																						[JourneyMockAPI.getPrescription()])
					)
		}.sorted(by: { $0.stepType.order < $1.stepType.order })
		return StepsState(stepsState: patientSteps,
											selectedIndex: 0)
	}

	static func patient(_ pathway: Pathway,
											_ patientDetails: PatientDetails,
											_ medHistory: FormTemplate,
											_ consents: [FormTemplate]) -> StepsState {
		var stepTypes = pathway.steps.map { $0.stepType }
		stepTypes.append(.patientComplete)
		let patientSteps: [StepState] =
			stepTypes
				.filter { stepToModeMap($0) == .patient }
				.map {
					StepState(stepType: $0, forms: Self.patientForms($0,
																													 patientDetails,
																													 medHistory,
																													 consents)
					)
		}.sorted(by: { $0.stepType.order < $1.stepType.order })
		return StepsState(stepsState: patientSteps,
											selectedIndex: 0)
	}

	static func patientForms(_ stepType: StepType,
													 _ patientDetails: PatientDetails,
													 _ medHistory: FormTemplate,
													 _ consents: [FormTemplate]) -> [MetaFormAndStatus] {
		switch stepType {
		case .patientdetails:
			return [MetaFormAndStatus(MetaForm.patientDetails(patientDetails), false)]
		case .medicalhistory:
			return [MetaFormAndStatus(MetaForm.template(medHistory), false)]
		case .consents:
			return zip(
				consents.map(MetaForm.template), consents.map { _ in false })
				.map(MetaFormAndStatus.init)
		case .checkpatient,
				 .treatmentnotes,
				 .prescriptions,
				 .photos,
				 .recalls,
				 .aftercares:
			fatalError("doctor steps, should be filtered earlier")
		case .patientComplete:
			return [MetaFormAndStatus(MetaForm.patientComplete(PatientComplete()), false)]
		}
	}

	static func doctorForms(_ stepType: StepType,
													_ patientDetails: PatientDetails,
													_ treatmentN: [FormTemplate],
													_ prescriptions: [FormTemplate]
	) -> [MetaFormAndStatus] {
		switch stepType {
		case .checkpatient:
			return [MetaFormAndStatus(MetaForm.patientDetails(patientDetails), false)]
		case .treatmentnotes:
			return zip(
				treatmentN.map(MetaForm.template), treatmentN.map { _ in false })
				.map(MetaFormAndStatus.init)
		case .prescriptions:
			return zip(
				prescriptions.map(MetaForm.template), prescriptions.map { _ in false })
				.map(MetaFormAndStatus.init)
		case .photos:
			return []//TODO
		case .recalls:
			return []//TODO
		case .aftercares:
			return []//TODO
		case .patientdetails,
				 .medicalhistory,
				 .consents:
			fatalError("patient steps, should be filtered earlier")
		case .patientComplete:
			return []
		}
	}
}

extension StepsState {
	var treatmentNotes: [FormTemplate] {
		get {
			forms
				.map{ $0.form }
				.compactMap { extract(case: MetaForm.template, from: $0) }
				.filter { $0.formType == .treatment }
		}
		set {
			self.forms.removeAll(where: { form in
					guard let template = extract(case: MetaForm.template, from: form.form),
						template.formType == .treatment else { return false}
					return newValue.contains(where: { $0.id == template.id })
			})
			self.forms.append(contentsOf: newValue.map {
				MetaFormAndStatus.init(MetaForm.template($0), false)
			})
		}
	}
}

extension CheckInContainerState {

	var doctorSummary: DoctorSummaryState {
		get {
			DoctorSummaryState(isChooseConsentActive: isChooseConsentActive,
												 isChooseTreatmentActive: isChooseTreatmentActive,
												 isDoctorCheckInMainActive: isDoctorCheckInMainActive,
												 doctor: doctor)
		}
		set {
			self.isChooseTreatmentActive = newValue.isChooseTreatmentActive
			self.doctor = newValue.doctor
			self.isChooseTreatmentActive = newValue.isChooseTreatmentActive
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var chooseTreatments: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 selectedPathway: pathway,
														 selectedTemplatesIds: doctor.treatmentNotes.map { $0.id},
														 templates: treatmentForms,
														 templatesLoadingState: .initial)
		}
		set {
			let doctorForms = newValue.templates.filter { newValue.selectedTemplatesIds.contains($0.id )}
//				.map { MetaForm.template($0) }
//				.map { MetaFormAndStatus.init( $0, false)}
			self.doctor.treatmentNotes = doctorForms
			self.treatmentForms = newValue.templates
		}
	}

	var passcode: PasscodeState {
		get {
			PasscodeState(runningDigits: self.runningDigits,
										unlocked: self.unlocked,
										isDoctorSummaryActive: self.isDoctorSummaryActive, wrongAttempts: self.wrongAttempts)
		}
		set {
			self.runningDigits = newValue.runningDigits
			self.unlocked = newValue.unlocked
			self.isDoctorSummaryActive = newValue.isDoctorSummaryActive
			self.wrongAttempts = newValue.wrongAttempts
		}
	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													patientDetails: PatientDetails(),
													medHistory: FormTemplate.defaultEmpty,
													consents: []
		)
	}
}
