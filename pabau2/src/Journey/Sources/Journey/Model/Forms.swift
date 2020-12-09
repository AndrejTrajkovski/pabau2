//import ComposableArchitecture
//import Model
//import Form
//
//struct Forms: Equatable {
//	var forms: IdentifiedArrayOf<StepForms>
//	var selectedStep: StepType
//
//	var flat: [MetaFormAndStatus] {
//		forms.flatMap(\.forms)
//	}
//
//	var flatSelectedIndex: Int {
//		get {
//			let indexOfSelStep = forms.firstIndex(where: { $0.stepType == selectedStep })!
//			let partial = forms.prefix(upTo: indexOfSelStep)
//			let upToSum = partial.reduce(0) {
//					$0 + $1.forms.count
//			}
//			return upToSum + selectedStepForms.selFormIndex
//		}
//		set {
//			var previousUpper = 0
//			var stepIndex = 0
//			var selFormIndex = 0
//			for (index, stepForm) in forms.sorted(by: \.stepType.order).enumerated() {
//				let lower = previousUpper
//				let upper = lower + stepForm.forms.count
//				if lower <= newValue && upper > newValue {
//					stepIndex = index
//					selFormIndex = newValue - lower
//					break
//				} else {
//					previousUpper = upper
//				}
//			}
//			selectedStep = forms[stepIndex].stepType
//			selectedStepForms.selFormIndex = selFormIndex
//		}
//	}
//
//	var selectedStepForms: StepForms {
//		get { forms[id: selectedStep]! }
//		set { forms[id: selectedStep] = newValue}
//	}
//}
