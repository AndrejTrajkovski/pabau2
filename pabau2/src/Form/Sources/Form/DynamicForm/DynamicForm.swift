import Model
import SwiftUI
import ComposableArchitecture
import Util

struct ListDynamicFormStore: View {
	let store: Store<FormTemplate, FormTemplateAc>
}

struct ListDynamicForm: View {
	@Binding var template: FormTemplate
	init(template: Binding<FormTemplate>) {
		self._template = template
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}
	var body: some View {
		print("ListDynamicForm body")
		return List {
			DynamicForm(template: $template, isCheckingDetails: false)
		}
	}
}

struct DynamicForm: View {
	
	let isCheckingDetails: Bool
	@Binding var template: FormTemplate
	init(template: Binding<FormTemplate>,
		 isCheckingDetails: Bool) {
		self._template = template
		self.isCheckingDetails = isCheckingDetails
	}
	
	public var body: some View {
		VStack {
			Text(template.name).font(.title)
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
									),
								 isCheckingDetails: self.isCheckingDetails)
					.equatable()
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
