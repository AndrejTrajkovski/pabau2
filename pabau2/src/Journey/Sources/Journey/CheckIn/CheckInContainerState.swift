import Model
import ComposableArchitecture
import Overture
import Util
import Form

public struct CheckInContainerState: Equatable {
	var patientForms: Forms
	var doctorForms: Forms
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

	var patientCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				forms: patientForms,
				xButtonActiveFlag: true, //handled in checkInMiddleware
				journey: journey,
				journeyMode: .patient)
		}
		set {
			self.patientForms = newValue.forms
		}
	}

	var doctorCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				forms: doctorForms,
				xButtonActiveFlag: isDoctorCheckInMainActive,
				journey: journey,
				journeyMode: .doctor)
		}
		set {
			self.doctorForms = newValue.forms
			self.isDoctorCheckInMainActive = newValue.xButtonActiveFlag
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
			self.patientForms.forms[id: .consents]?.forms = newValue.forms
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
										 from: patientForms.forms[id: .patientComplete]!.forms.first!.form)!
						.isPatientComplete
		}
		set {
			let patientComplete = MetaForm.patientComplete(PatientComplete(isPatientComplete: newValue))
			let old = patientForms.forms[id: .patientComplete]!.forms.first!
			let newForm = MetaFormAndStatus(patientComplete,
																			old.isComplete,
																			index: old.index)
			patientForms.forms[id: .patientComplete]!.forms = [newForm]
		}
	}

	var checkPatient: CheckPatient {
		let patDetailsWrapped = patientForms.forms[id: .patientdetails]?.forms.first?.form
		let patDetails = extract(case: MetaForm.patientDetails,
														 from: patDetailsWrapped)
		let medHistory = patientForms.forms[id: .medicalhistory]?.forms.elements ?? []
		let consents = patientForms.forms[id: .consents]?.forms.elements ?? []
		let patientForms = (medHistory + consents)
			.map(\.form)
			.compactMap { extract(case: MetaForm.template, from: $0) }
		return CheckPatient(patDetails: patDetails,
												patForms: patientForms)
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
		let patientStepTypes = stepTypes.filter(filterBy(.patient))
		let patientForms = makePatientForms(stepTypes: patientStepTypes, consents: consents)
		self.patientForms = Forms.init(forms: IdentifiedArray(patientForms),
																	selectedStep: patientStepTypes.sorted(by: \.order).first!)
		let doctorStepTypes = stepTypes.filter(filterBy(.doctor))
		let doctorForms = makeDoctorForms(stepTypes: doctorStepTypes,
																			patientDetails: patientDetails,
																			medHistory: medHistory,
																			consents: consents,
																			treatmentNotes: [],
																			prescriptions: [],
																			photos: PhotosState.init([[:]]))
		self.doctorForms = Forms.init(forms: IdentifiedArray(doctorForms),
																	selectedStep: doctorStepTypes.sorted(by: \.order).first!)
		self.allConsents = allConsents
		self.allTreatmentForms = IdentifiedArray(FormTemplate.mockTreatmentN)
		self.selectedConsentsIds = []
		self.selectedTreatmentFormsIds = []
	}
}

extension Forms {
	var photosState: PhotosState {
		get {
			return extract(case: MetaForm.photos,
										 from: forms[id: .photos]!.forms.first!.form)!
		}
		set {
			forms[id: .photos]!.forms[0].form = MetaForm.photos(newValue)
		}
	}
}
