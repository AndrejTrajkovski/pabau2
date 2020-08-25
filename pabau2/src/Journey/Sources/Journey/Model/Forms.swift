import ComposableArchitecture
import Model
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
			//FIXME
			var sum = 0
			var stepIndex = 0
			var selFormIndex = 0
			for (index, stepForm) in forms.sorted(by: \.stepType.order).enumerated() {
				let lower = sum
				let upper = lower + stepForm.forms.count
				if lower <= newValue && upper > newValue {
					stepIndex = index
					selFormIndex = newValue - lower
					break
				} else {
					sum = upper
				}
				print(lower, upper, sum)
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
			forms.count > currentStepTypeIndex {
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

	mutating func goToNextUncomplete() {
		forms.first(where: { !$0.isComplete }).map {
			selectedStep = $0.stepType
		}
	}
}
