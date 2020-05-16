import Model
import ComposableArchitecture
import Overture

enum JourneyMode: Equatable {
	case patient
	case doctor
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var pathway: Pathway
	var runningPrescriptions: [Int: FormTemplate]
	var prescriptionsCompleted: [Int: Bool]
	var allConsents: [Int: FormTemplate]
	var selectedConsentsIds: [Int]
	var consentsCompleted: [Int: Bool]
	var runningConsents: [Int: FormTemplate]
	var allTreatmentForms: [Int: FormTemplate]
	var selectedTreatmentFormsIds: [Int]
	var treatmentFormsCompleted: [Int: Bool]
	var runningTreatmentForms: [Int: FormTemplate]
	var aftercare: Aftercare
	var aftercareCompleted: Bool
	var patientDetails: PatientDetails
	var patientDetailsCompleted: Bool
	var patientComplete: PatientComplete
	var checkPatientCompleted: Bool
	var medHistory: FormTemplate
	var medHistoryCompleted: Bool
	var checkPatientForm: CheckPatientForm
	var patientSelectedIndex: Int
	var doctorSelectedIndex: Int
	var photosCompleted: Bool
	var recall: Recall
	var recallCompleted: Bool
	var runningDigits: [String] = []
	var unlocked: Bool = false
	var wrongAttempts: Int = 0
	
	//NAVIGATION
	var isHandBackDeviceActive: Bool = false
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isPatientCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false

	init(journey: Journey,
			 pathway: Pathway,
			 patientDetails: PatientDetails,
			 medHistory: FormTemplate,
			 allConsents: [Int: FormTemplate],
			 selectedConsentsIds: [Int]) {
		self.journey = journey
		self.pathway = pathway
		self.allConsents = allConsents
		self.selectedConsentsIds = selectedConsentsIds
		self.allTreatmentForms = flatten(JourneyMockAPI.mockTreatmentN)
		self.runningConsents = selected(allConsents, selectedConsentsIds)
		self.runningTreatmentForms = [:]
		self.consentsCompleted = runningConsents.map { $0.key }.reduce(into: [Int: Bool]()) {
			$0[$1] = false
		}
		self.selectedTreatmentFormsIds = []
		self.treatmentFormsCompleted = [:]
		self.aftercare = Aftercare()
		self.aftercareCompleted = false
		self.patientDetails = PatientDetails()
		self.patientDetailsCompleted = false
		self.patientComplete = PatientComplete()
		self.patientSelectedIndex = 0
		self.doctorSelectedIndex = 0
		self.runningPrescriptions = [:]
		self.prescriptionsCompleted = [:]
		self.checkPatientCompleted = false
		self.photosCompleted = false
		self.recall = Recall()
		self.recallCompleted = false
		self.medHistory = JourneyMockAPI.getMedHistory()
		self.medHistoryCompleted = false
		self.checkPatientForm = CheckPatientForm()
	}
}

extension CheckInContainerState {

	//TODO: OPTIMIZE FILTERING ON PATIENT VS DOCTOR
	var patientArray: [MetaFormAndStatus] {
		get {
			return forms(.patient, self)
		}
		set {
			newValue.filter(
				with(.patient, filterMetaFormsByJourneyMode)
			).forEach {
				unwrap(&self, $0)
			}
		}
	}

	var doctorArray: [MetaFormAndStatus] {
		get {
			return forms(.doctor, self)
		}
		set {
			newValue.filter(
				with(.doctor, filterMetaFormsByJourneyMode)
			).forEach {
					unwrap(&self, $0)
			}
		}
	}
}

func forms(_ journeyMode: JourneyMode,
					 _ state: CheckInContainerState) -> [MetaFormAndStatus] {
	state.pathway.steps
		.filter(with(journeyMode, filterStepType))
		.reduce(into: [MetaFormAndStatus]()) {
			$0.append(contentsOf:
				with($1, (pipe(get(\.stepType),
											 with(state, curry(wrapForm(_:_:)))))))
	}
	.sorted(by: their(pipe(get(\.form), stepType(form:), get(\.order))))
}

extension CheckInContainerState {

	var patientCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: patientSelectedIndex,
				forms: patientArray,
				xButtonActiveFlag: isPatientCheckInMainActive,
				journey: journey)
		}
		set {
			self.patientSelectedIndex = newValue.selectedIndex
			self.patientArray = newValue.forms
			self.isDoctorCheckInMainActive = newValue.xButtonActiveFlag
			self.journey = newValue.journey
		}
	}

	var doctorCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: doctorSelectedIndex,
				forms: doctorArray,
				xButtonActiveFlag: isDoctorCheckInMainActive,
				journey: journey)
		}
		set {
			self.doctorSelectedIndex = newValue.selectedIndex
			self.doctorArray = newValue.forms
			self.isDoctorCheckInMainActive = newValue.xButtonActiveFlag
			self.journey = newValue.journey
		}
	}

	var doctorSummary: DoctorSummaryState {
		get {
			DoctorSummaryState(journey: journey,
												 isChooseConsentActive: isChooseConsentActive,
												 isChooseTreatmentActive: isChooseTreatmentActive,
												 isDoctorCheckInMainActive: isDoctorCheckInMainActive,
												 doctorCheckIn: doctorCheckIn)
		}
		set {
			self.journey = newValue.journey
			self.doctorCheckIn = newValue.doctorCheckIn
			self.isChooseConsentActive = newValue.isChooseConsentActive
			self.isChooseTreatmentActive = newValue.isChooseTreatmentActive
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var chooseTreatments: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 selectedPathway: pathway,
														 selectedTemplatesIds: selectedTreatmentFormsIds,
														 templates: allTreatmentForms,
														 templatesLoadingState: .initial)
		}
		set {
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
		}
	}

	var chooseConsents: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 selectedPathway: pathway,
														 selectedTemplatesIds: selectedConsentsIds,
														 templates: allConsents,
														 templatesLoadingState: .initial)
		}
		set {
			self.selectedConsentsIds = newValue.selectedTemplatesIds
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

public struct CheckInViewState: Equatable {
	var selectedIndex: Int
	var forms: [MetaFormAndStatus]
	var xButtonActiveFlag: Bool
	var journey: Journey

	var selectedForm: MetaFormAndStatus {
		return forms[selectedIndex]
	}

	var topView: TopViewState {
		get {
			TopViewState(totalSteps: self.forms.count,
									 completedSteps: self.forms.filter(\.isComplete).count,
									 xButtonActiveFlag: xButtonActiveFlag,
									 journey: journey)
		}
		set {
			self.xButtonActiveFlag = newValue.xButtonActiveFlag
		}
	}
}

extension CheckInContainerState {
	public static var defaultEmpty: CheckInContainerState {
		CheckInContainerState(journey: Journey.defaultEmpty,
													pathway: Pathway.defaultEmpty,
													patientDetails: PatientDetails(),
													medHistory: FormTemplate.defaultEmpty,
													allConsents: [:],
													selectedConsentsIds: []
		)
	}
}

func wrapForm(_ state: CheckInContainerState,
							_ stepType: StepType) -> [MetaFormAndStatus] {
	switch stepType {
	case .patientdetails:
		let form = MetaForm.patientDetails(state.patientDetails)
		return [MetaFormAndStatus(form, state.patientDetailsCompleted)]
	case .medicalhistory:
		let form = MetaForm.template(state.medHistory)
		return [MetaFormAndStatus(form, state.medHistoryCompleted)]
	case .consents:
		return state.runningConsents.map {
			let form = MetaForm.template($0.value)
			guard let status = state.consentsCompleted[$0.value.id] else { fatalError() }
			return MetaFormAndStatus(form, status)
		}
	case .checkpatient:
		let form = MetaForm.checkPatient(state.checkPatientForm)
		return [MetaFormAndStatus(form, state.checkPatientCompleted)]
	case .treatmentnotes:
		return state.runningTreatmentForms.map {
			let form = MetaForm.template($0.value)
			guard let status = state.treatmentFormsCompleted[$0.value.id] else { fatalError() }
			return MetaFormAndStatus(form, status)
		}
	case .prescriptions:
		return state.runningPrescriptions.map {
			let form = MetaForm.template($0.value)
			guard let status = state.prescriptionsCompleted[$0.value.id] else { fatalError() }
			return MetaFormAndStatus(form, status)
		}
	case .photos:
		return [] //TODO
	case .recalls:
		let form = MetaForm.recall(state.recall)
		return [MetaFormAndStatus(form, state.recallCompleted)]
	case .aftercares:
		let form = MetaForm.aftercare(state.aftercare)
		return [MetaFormAndStatus(form, state.aftercareCompleted)]
	case .patientComplete:
		let form = MetaForm.patientComplete(state.patientComplete)
		return [MetaFormAndStatus(form, false)]
	}
}

func unwrap(_ state: inout CheckInContainerState,
						_ metaFormAndStatus: MetaFormAndStatus) {
	let metaForm = metaFormAndStatus.form
	let isComplete = metaFormAndStatus.isComplete
	switch stepType(form: metaForm) {
	case .patientdetails:
		state.patientDetails = extract(case: MetaForm.patientDetails, from: metaForm)!
		state.patientDetailsCompleted = isComplete
	case .medicalhistory:
		state.medHistory = extract(case: MetaForm.template, from: metaForm)!
		state.medHistoryCompleted = isComplete
	case .consents:
		let consent = extract(case: MetaForm.template, from: metaForm)!
		state.runningConsents[consent.id] = consent
		state.consentsCompleted[consent.id] = isComplete
	case .checkpatient:
		state.checkPatientForm = extract(case: MetaForm.checkPatient, from: metaForm)!
		state.checkPatientCompleted = isComplete
	case .treatmentnotes:
		let treatmentnote = extract(case: MetaForm.template, from: metaForm)!
		state.runningTreatmentForms[treatmentnote.id] = treatmentnote
		state.treatmentFormsCompleted[treatmentnote.id] = isComplete
	case .prescriptions:
		let prescription = extract(case: MetaForm.template, from: metaForm)!
		state.runningPrescriptions[prescription.id] = prescription
		state.prescriptionsCompleted[prescription.id] = isComplete
	case .photos:
		return
	case .recalls:
		state.recall = extract(case: MetaForm.recall, from: metaForm)!
		state.recallCompleted = isComplete
	case .aftercares:
		state.aftercare = extract(case: MetaForm.aftercare, from: metaForm)!
		state.aftercareCompleted = isComplete
	case .patientComplete:
		state.patientComplete = extract(case: MetaForm.patientComplete, from: metaForm)!
	}
}
