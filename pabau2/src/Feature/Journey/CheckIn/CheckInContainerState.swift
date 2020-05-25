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
	var runningSelectedConsentsIds: [Int]
	var finalSelectedConsentsIds: [Int]
	var consentsCompleted: [Int: Bool]
	var runningConsents: [Int: FormTemplate]
	var allTreatmentForms: [Int: FormTemplate]
	var runningSelectedTreatmentFormsIds: [Int]
	var finalSelectedTreatmentFormsIds: [Int]
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
			transformBack(.patient, newValue, &self)
		}
	}

	var doctorArray: [MetaFormAndStatus] {
		get {
			return transformInFormsArray(.doctor, self)
		}
		set {
			transformBack(.doctor, newValue, &self)
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
														 finalSelectedTemplatesIds: finalSelectedTreatmentFormsIds,
														 templates: allTreatmentForms,
														 templatesLoadingState: .initial,
														 runningSelectedTemplatesIds:
				runningSelectedTreatmentFormsIds)
		}
		set {
			self.finalSelectedTreatmentFormsIds = newValue.finalSelectedTemplatesIds
			self.allTreatmentForms = newValue.templates
			self.runningSelectedTreatmentFormsIds = newValue.runningSelectedTemplatesIds
			updateWithKeepingOld(runningForms: &runningTreatmentForms,
													 finalSelectedTemplatesIds: finalSelectedTreatmentFormsIds,
													 allTemplates: allTreatmentForms)
			updateWithKeepingOld(formsCompleted: &treatmentFormsCompleted,
													 finalSelectedTemplatesIds: finalSelectedTreatmentFormsIds)
		}
	}

	var chooseConsents: ChooseFormState {
		get {
			return ChooseFormState(selectedJourney: journey,
														 finalSelectedTemplatesIds: finalSelectedConsentsIds,
														 templates: allConsents,
														 templatesLoadingState: .initial,
														 runningSelectedTemplatesIds: runningSelectedConsentsIds)
		}
		set {
			self.finalSelectedConsentsIds = newValue.finalSelectedTemplatesIds
			self.allConsents = newValue.templates
			self.runningSelectedConsentsIds = newValue.runningSelectedTemplatesIds
			
			updateWithKeepingOld(runningForms: &runningConsents,
													 finalSelectedTemplatesIds: finalSelectedConsentsIds,
													 allTemplates: allConsents)
			updateWithKeepingOld(formsCompleted: &consentsCompleted,
													 finalSelectedTemplatesIds: finalSelectedConsentsIds)
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
		self.finalSelectedConsentsIds = selectedConsentsIds
		self.allTreatmentForms = flatten(JourneyMockAPI.mockTreatmentN)
		self.runningConsents = selected(allConsents, selectedConsentsIds)
		self.runningTreatmentForms = [:]
		self.consentsCompleted = runningConsents.map { $0.key }.reduce(into: [Int: Bool]()) {
			$0[$1] = false
		}
		self.finalSelectedTreatmentFormsIds = []
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
		self.runningSelectedConsentsIds = selectedConsentsIds
		self.runningSelectedTreatmentFormsIds = []
	}
}
