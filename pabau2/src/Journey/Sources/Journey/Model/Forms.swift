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
			let result = forms.reduce(into: ([[Int]](), -1)) { localResult, stepForms in
				let previousCount = localResult.1 + 1
				let currentMapped = stepForms.forms.indices.map { $0 + previousCount }
				localResult.0.append(currentMapped)
				localResult.1 = currentMapped.last ?? -1
			}
			let indices = result.0.map {
				($0.first!, $0.last!)
			}
			var stepIndex = 0
			var selFormIndex = 0
			indices.enumerated().forEach { (index, lowerUpperTup) in
				let lower = lowerUpperTup.0
				let upper = lowerUpperTup.1
				if lower <= newValue && upper >= newValue {
					stepIndex = index
					selFormIndex = newValue - lower
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

	mutating func goToNextUncomplete() {
		forms.first(where: { !$0.isComplete }).map {
			selectedStep = $0.stepType
		}
	}
}
