import Model

public struct StepsState: Equatable {
	var stepsState: [StepState]
	var selectedIndex: Int
//	var forms: [MetaFormAndStatus] {
//		get { self.stepsState.flatMap(\.forms) }
//		set {
//			let grouped: [StepType: [MetaFormAndStatus]] =
//				Dictionary.init(grouping: newValue,
//												by: { stepType(form: $0.form) })
//			let result = grouped.reduce(into: [StepState](), {
//				$0.append(StepState.init(stepType: $1.key, forms: $1.value))
//			})
//			self.stepsState = result.sorted(by: { $0.stepType.order < $1.stepType.order })
//		}
//	}
//	var isOnCompleteStep: Bool {
//		self.forms.firstIndex(where: { extract(case: MetaForm.patientComplete, from: $0.form) != nil }) ==
//		selectedIndex
//	}
}

//
//extension StepsState {
//	var treatmentNotes: [FormTemplate] {
//		get {
//			forms
//				.map{ $0.form }
//				.compactMap { extract(case: MetaForm.template, from: $0) }
//				.filter { $0.formType == .treatment }
//		}
//		set {
//			self.forms.append(contentsOf: newValue.map {
//				MetaFormAndStatus.init(MetaForm.template($0), false)
//			})
//		}
//	}
//}
