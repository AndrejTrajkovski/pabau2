import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

struct DynamicForm: View {
	
	@Binding var template: FormTemplate
	init(template: Binding<FormTemplate>) {
		self._template = template
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}

	public var body: some View {
		print("pabau form body")
		return
			List {
				ForEach(template.formStructure.formStructure.indices, id: \.self ) { index in
					FormSectionField(cssField:
						Binding(
							get: {
								if self.template.formStructure.formStructure.count > index {
									return self.template.formStructure.formStructure[index]
								} else {
									return CSSField.defaultEmpty
								}
						},
							set: {
								if self.template.formStructure.formStructure.count > index {
									self.template.formStructure.formStructure[index] = $0
								} else {
									
								}
							}
						)
					).equatable()
				}
			}
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
