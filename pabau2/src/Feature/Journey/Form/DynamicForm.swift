import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

struct DynamicForm: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding var template: FormTemplate
	init(template: Binding<FormTemplate>) {
		self._template = template
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}

	public var body: some View {
		print("pabau form body")
		return List {
			ForEach(template.formStructure.formStructure.indices, id: \.self ) { index in
				FormSectionField(cssField:
					Binding(
						get: { self.template.formStructure.formStructure[index] },
						set: { self.template.formStructure.formStructure[index] = $0 })
				).equatable()
			}
		}.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}

//let fieldsReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> =
//	indexed(reducer: fieldReducer,
//					\CheckInContainerState.currentFields,
//					/CheckInMainAction.form, { $0 })

//let fieldReducer: Reducer<CSSField, CheckInFormAction, JourneyEnvironemnt> =
//(
//	cssClassReducer.pullback(
//					 value: \CSSField.cssClass,
//					 action: /CheckInFormAction.self,
//					 environment: { $0 })
//)
