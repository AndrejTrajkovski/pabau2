import Model
import ComposableArchitecture
import Overture
import Util
import Form

struct Forms: Equatable {
	var forms: IdentifiedArrayOf<StepForms>
	var selectedStep: StepType
	
	var flat: [MetaFormAndStatus] {
		forms.flatMap(\.forms)
	}
	
	var flatSelectedIndex: Int {
		get {
			let indexOfSelStep = forms.firstIndex(where: { $0.stepType == selectedStep })!
			let partial = forms.prefix(upTo: indexOfSelStep)
			let upToSum = partial.reduce(0) {
					$0 + $1.forms.count
			}
			return upToSum + selectedStepForms.selFormIndex
		}
		set {
			var result: ([[Int]], Int) = ([], 0)
			result = forms.reduce(result) { (localResult: ([[Int]], Int), stepForms: StepForms) in
				var previousCount = result.1
				if previousCount != 0 {
					previousCount += 1
				}
				let currentMapped = stepForms.forms.indices.map { $0 + previousCount }
				result.0.append(currentMapped)
				result.1 = currentMapped.last!
				return result
			}
			let indices = result.0.map {
				($0.first!, $0.last!)
			}
			var stepIndex = 0
			var selFormIndex = 0
			indices.enumerated().forEach { (index, lowerUpperTup) in
				let lower = lowerUpperTup.0
				let upper = lowerUpperTup.1
				if (lower <= newValue && upper >= newValue) {
					stepIndex = index
					selFormIndex = upper - newValue - 1
				}
			}
			selectedStep = forms[stepIndex].stepType
			selectedStepForms.selFormIndex = selFormIndex
		}
	}
	
	var selectedStepForms: StepForms {
		get { forms[id: selectedStep]! }
		set { forms[id: selectedStep] = newValue}
	}
	
	var selectedForm: MetaFormAndStatus {
		forms[id: selectedStep]!.selectedForm
	}
	
	mutating func select(step: StepType, idx: Int) {
		self.selectedStep = step
		self.forms[id: step]!.selFormIndex = idx
	}
	
	mutating func next() {
		if !forms[id: selectedStep]!.nextIndex() {
			if let currentStepTypeIndex = forms.firstIndex(where: { $0.stepType == selectedStep }),
			forms.count + 1 > currentStepTypeIndex {
				let nextStepIndex = currentStepTypeIndex + 1
				selectedStep = forms[nextStepIndex].stepType
			}
		}
	}
	
	mutating func previous() {
		if !forms[id: selectedStep]!.previousIndex() {
			if let currentStepTypeIndex = forms.firstIndex(where: { $0.stepType == selectedStep }),
			currentStepTypeIndex > 0 {
				let previousStepIndex = currentStepTypeIndex - 1
				selectedStep = forms[previousStepIndex].stepType
			}
		}
	}
}

enum JourneyMode: Equatable {
	case patient
	case doctor
}

public struct StepForms: Equatable, Identifiable {
	var stepType: StepType
	var forms: IdentifiedArrayOf<MetaFormAndStatus>
	var selFormIndex: Int
	
	var selectedForm: MetaFormAndStatus {
		self.forms[selFormIndex]
	}
	
	public var id: StepType { stepType }
	
	var isComplete: Bool {
		self.forms.allSatisfy(\.isComplete)
	}
	
	mutating func previousIndex() -> Bool {
		if selFormIndex > 0 {
			selFormIndex -= 1
			return true
		} else {
			return false
		}
	}
	
	mutating func nextIndex() -> Bool {
		if forms.count + 1 > selFormIndex {
			selFormIndex += 1
			return true
		} else {
			return false
		}
	}
}

public struct CheckInContainerState: Equatable {
	
	var patientForms: Forms
	var doctorForms: Forms
	
	var journey: Journey
	
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
			self.journey = newValue.journey
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
				forms: patientForms.forms[id: .consents]?.forms ?? [],
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
		let doctorStepTypes = stepTypes.filter(filterBy(.doctor))
		doctorStepTypes.map {
			switch $0 {
				case .patientdetails:
					return StepForms(stepType: $0, forms: [PatientDetails()], selFormIndex: 0)
			case .medicalhistory:
				return StepForms(stepType: $0, forms: [FormTemplate.getMedHistory()],
												 selFormIndex: 0)
			case .consents:
				return StepForms(stepType: $0, forms: consents.map(MetaFormAndStatus.init(form:, <#T##isComplete: Bool##Bool#>, index: <#T##Int#>)), selFormIndex: <#T##Int#>)
			}
			
		}
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
