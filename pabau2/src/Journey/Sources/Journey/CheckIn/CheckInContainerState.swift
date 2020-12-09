import Model
import ComposableArchitecture
import Overture
import Util
import Form

public struct CheckInContainerState: Equatable {

	let patientSteps: [StepType]
	let doctorSteps: [StepType]

	var doctorForms: Forms {
		get {
			let forms = [checkPatient, treatmentNotes, aftercare, prescriptions, photos]
			return Forms(forms: IdentifiedArrayOf(forms), selectedStep: doctorSelectedStep)
		}
		set {
			doctorSelectedStep = newValue.selectedStep
			newValue.forms.forEach {
				switch $0.stepType {
				case .checkpatient:
					self.isPatientChecked = $0.forms.first!.isComplete
				case .treatmentnotes:
					self.treatmentNotes = $0
				case .aftercares:
					self.aftercare = $0
				case .prescriptions:
					self.prescriptions = $0
				case .photos:
					self.photos = $0
				default: break
				}
			}
		}
	}
	
	var patientForms: Forms {
		get {
			let forms = [patientDetails, medicalHistory, consents, patientComplete]
			return Forms(forms: IdentifiedArrayOf(forms), selectedStep: patientSelectedStep)
		}

		set {
			patientSelectedStep = newValue.selectedStep
			newValue.forms.forEach {
				switch $0.stepType {
				case .patientdetails:
					self.patientDetails = $0
				case .medicalhistory:
					self.medicalHistory = $0
				case .consents:
					self.consents = $0
				case .patientComplete:
					self.patientComplete = $0
				default: break
				}
			}
		}
	}

	var isPatientChecked: Bool
	var checkPatient: StepForms {
		get {
			let pdasd = extract(case: MetaForm.patientDetails, from: self.patientDetails.forms.first!.form)!
			let medH = self.medicalHistory.forms.map(\.form).map {
				extract(case: MetaForm.template, from: $0)!
			}
			let consents = self.consents.forms.map(\.form).map {
				extract(case: MetaForm.template, from: $0)!
			}
			let cpd = CheckPatient(patDetails: pdasd,
								   patForms: medH + consents)
			let checkP = MetaFormAndStatus.init(MetaForm.checkPatient(cpd), isPatientChecked, index: 0)
			return StepForms(stepType: .checkpatient,
							 forms: IdentifiedArrayOf([checkP]))
		}
	}

	var patientDetails: PatientDetails
	var medicalHistory: FormTemplate
	var consents: [FormTemplate]

	var treatmentNotes: [FormTemplate]
	var aftercare: Aftercare?
	var prescriptions: [FormTemplate]
	var photos: PhotosState?
	var patientComplete: PatientComplete
	
	var doctorSelectedIndex: Int
	var patientSelectedIndex: Int
	
	var doctorSelectedStep: StepType
	var patientSelectedStep: StepType
	var patientDetails: StepForms
	var medicalHistory: StepForms
	var consents: StepForms

	var treatmentNotes: StepForms
	var aftercare: StepForms
	var prescriptions: StepForms
	var photos: StepForms
	var patientComplete: StepForms
	let journey: Journey

	var allTreatmentForms: IdentifiedArrayOf<FormTemplate>
	var allConsents: IdentifiedArrayOf<FormTemplate>

	var selectedConsentsIds: [Int]
	var selectedTreatmentFormsIds: [Int]
	var passcodeState = PasscodeState()
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
	var didGoBackToPatientMode: Bool = false
}

extension CheckInContainerState {
//	var patientCheckIn: CheckInViewState {
//		get {
//			CheckInViewState(
//				forms: patientForms,
//				xButtonActiveFlag: true, //handled in checkInMiddleware
//				journey: journey,
//				journeyMode: .patient)
//		}
//		set {
//			self.patientForms = newValue.forms
//		}
//	}
//
//	var doctorCheckIn: CheckInViewState {
//		get {
//			CheckInViewState(
//				forms: doctorForms,
//				xButtonActiveFlag: isDoctorCheckInMainActive,
//				journey: journey,
//				journeyMode: .doctor)
//		}
//		set {
//			self.doctorForms = newValue.forms
//			self.isDoctorCheckInMainActive = newValue.xButtonActiveFlag
//		}
//	}

	var doctorSummary: DoctorSummaryState {
		get {
			DoctorSummaryState(journey: journey,
							   isChooseConsentActive: isChooseConsentActive,
							   isChooseTreatmentActive: isChooseTreatmentActive,
							   isDoctorCheckInMainActive: isDoctorCheckInMainActive,
							   doctorCheckIn: doctorCheckIn)
		}
		set {
			self.doctorCheckIn = newValue.doctorCheckIn
			self.isChooseConsentActive = newValue.isChooseConsentActive
			self.isChooseTreatmentActive = newValue.isChooseTreatmentActive
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var chooseTreatments: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
				forms: doctorForms.forms[id: .treatmentnotes]?.forms ?? [],
				templates: allTreatmentForms,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedTreatmentFormsIds
			)
		}
		set {
			self.doctorForms.forms[id: .treatmentnotes]?.forms = newValue.forms
			self.allTreatmentForms = newValue.templates
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
		}
	}

	var chooseConsents: ChooseFormJourneyState {
		get {
			return ChooseFormJourneyState(
				forms: patientForms.forms[id: .consents]?.forms ?? IdentifiedArray([]),
				templates: allConsents,
				templatesLoadingState: .initial,
				selectedTemplatesIds: selectedConsentsIds
			)
		}
		set {
			self.consents.forms = newValue.forms
			self.allConsents = newValue.templates
			self.selectedConsentsIds = newValue.selectedTemplatesIds
		}
	}

	var passcode: PasscodeContainerState {
		get {
			PasscodeContainerState(
				passcode: self.passcodeState,
				didGoBackToPatientMode: self.didGoBackToPatientMode,
				isDoctorCheckInMainActive: self.isDoctorCheckInMainActive
			)
		}
		set {
			self.passcodeState = newValue.passcode
			self.didGoBackToPatientMode = newValue.didGoBackToPatientMode
			self.isDoctorCheckInMainActive = newValue.isDoctorCheckInMainActive
		}
	}

	var isHandBackDeviceActive: Bool {
		get {
			return extract(case: MetaForm.patientComplete,
						   from: self.patientComplete.forms.first!.form)!
				.isPatientComplete
		}
		set {
			let patientComplete = MetaFormAndStatus(MetaForm(PatientComplete(isPatientComplete: newValue)), false, index: 0)
			self.patientComplete.forms = [patientComplete]
		}
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
	init(journey: Journey,
		 pathway: Pathway,
		 patientDetails: PatientDetails,
		 medHistory: FormTemplate,
		 consents: IdentifiedArrayOf<FormTemplate>,
		 allConsents: IdentifiedArrayOf<FormTemplate>,
		 patientComplete: PatientComplete = PatientComplete(isPatientComplete: false),
		 photosState: PhotosState) {
		self.journey = journey
		var stepTypes = pathway.steps.map { $0.stepType }
		stepTypes.append(StepType.patientComplete)
		self.patientSteps = stepTypes.filter(filterBy(.patient))
		self.doctorSteps = stepTypes.filter(filterBy(.doctor))
		let patDetailsArr = [MetaFormAndStatus(MetaForm(PatientDetails.empty), false, index: 0)]
		self.patientDetails = StepForms(stepType: .patientdetails,
										forms: IdentifiedArrayOf(patDetailsArr))
		let medHistoryArr = [MetaFormAndStatus(MetaForm.template(medHistory), false, index: 0)]
		self.medicalHistory = StepForms(stepType: .medicalhistory,
										forms: IdentifiedArrayOf(medHistoryArr))
		let consentsArr = wrap(consents)
		self.consents = StepForms(stepType: .consents,
								  forms: consentsArr)
		self.treatmentNotes = StepForms(stepType: .treatmentnotes,
										forms: [])
		let photosArr = [MetaFormAndStatus(MetaForm.photos(PhotosState.init([[:]])), false, index: 0)]
		self.photos = StepForms(stepType: .photos,
								forms: IdentifiedArrayOf(photosArr))
		let aftercareArr = [MetaFormAndStatus(MetaForm.aftercare(JourneyMocks.aftercare), false, index: 0)]
		self.aftercare = StepForms(stepType: .aftercares,
								   forms: IdentifiedArrayOf(aftercareArr))
		self.prescriptions = StepForms(stepType: .prescriptions,
									   forms: [])
		let patCompleteArr = [MetaFormAndStatus(MetaForm.patientComplete(PatientComplete()), false, index: 0)]
		self.patientComplete = StepForms(stepType: .patientComplete,
										 forms: IdentifiedArrayOf(patCompleteArr))
		self.isPatientChecked = false
		self.patientSelectedStep = .patientdetails
		self.doctorSelectedStep = .checkpatient
		self.allConsents = allConsents
		self.allTreatmentForms = IdentifiedArray(FormTemplate.mockTreatmentN)
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
	}
}
