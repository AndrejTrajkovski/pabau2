import Model
import ComposableArchitecture
import Overture
import Util

enum JourneyMode: Equatable {
	case patient
	case doctor
}

public struct CheckInContainerState: Equatable {
	var journey: Journey
	var stepTypes: [StepType]
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
	var patientSelectedIndex: Int
	var doctorSelectedIndex: Int
	var photosCompleted: Bool
	var recall: Recall
	var recallCompleted: Bool

	var passcodeState = PasscodeState()
	var isEnterPasscodeActive: Bool = false
	var isChooseConsentActive: Bool = false
	var isChooseTreatmentActive: Bool = false
	var isDoctorCheckInMainActive: Bool = false
	var isDoctorSummaryActive: Bool = false
}

extension CheckInContainerState {

	//TODO: OPTIMIZE FILTERING ON PATIENT VS DOCTOR
	var patientArray: [MetaFormAndStatus] {
		get {
			return transformInFormsArray(.patient, self)
		}
		set {
			transformBack(.patient,
										newValue,
										&self)
		}
	}

	var doctorArray: [MetaFormAndStatus] {
		get {
			return transformInFormsArray(.doctor, self)
		}
		set {
			transformBack(.doctor,
										newValue,
										&self)
		}
	}
}

extension CheckInContainerState {

	var patientCheckIn: CheckInViewState {
		get {
			CheckInViewState(
				selectedIndex: patientSelectedIndex,
				forms: patientArray,
				xButtonActiveFlag: true,//handled in checkInMiddleware
				journey: journey)
		}
		set {
			self.patientSelectedIndex = newValue.selectedIndex
			self.patientArray = newValue.forms
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
														 selectedTemplatesIds: selectedTreatmentFormsIds,
														 templates: allTreatmentForms,
														 templatesLoadingState: .initial)
		}
		set {
			self.selectedTreatmentFormsIds = newValue.selectedTemplatesIds
			self.treatmentFormsCompleted = newValue.selectedTemplatesIds.reduce(into: [Int: Bool]()) {
				$0[$1] = false
			}
			self.runningTreatmentForms = selected(allTreatmentForms, newValue.selectedTemplatesIds)
		}
	}

	var chooseConsents: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 selectedTemplatesIds: selectedConsentsIds,
														 templates: allConsents,
														 templatesLoadingState: .initial)
		}
		set {
			self.selectedConsentsIds = newValue.selectedTemplatesIds
			self.consentsCompleted = newValue.selectedTemplatesIds.reduce(into: [Int: Bool]()) {
				$0[$1] = false
			}
			self.runningConsents = selected(allConsents, newValue.selectedTemplatesIds)
		}
	}

	var passcode: PasscodeState {
		get {
			self.passcodeState
		}
		set {
			self.passcodeState = newValue
		}
	}

	var isHandBackDeviceActive: Bool {
		get {
			let pcform = patientArray.filter { stepType(form: $0.form) == .patientComplete }.first!
			let res = extract(case: MetaForm.patientComplete,
												from: pcform.form)!
				.isPatientComplete
			return res
		}
		set {
			self.patientComplete.isPatientComplete = newValue
		}
	}
}

extension CheckInContainerState {

	init(journey: Journey,
			 pathway: Pathway,
			 patientDetails: PatientDetails,
			 medHistory: FormTemplate,
			 allConsents: [Int: FormTemplate],
			 selectedConsentsIds: [Int],
			 patientComplete: PatientComplete = PatientComplete(isPatientComplete: true)) {
		self.journey = journey
		self.stepTypes = pathway.steps.map { $0.stepType }
		self.stepTypes.append(StepType.patientComplete)
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
		self.patientDetails = patientDetails
		self.patientDetailsCompleted = false
		self.patientComplete = patientComplete
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
	}
}
