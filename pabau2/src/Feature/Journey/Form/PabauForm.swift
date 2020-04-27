import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

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

struct PabauForm: View {
	
	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding var cssFields: [CSSField]
	init(cssFields: Binding<[CSSField]>) {
		self._cssFields = cssFields
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}

	public var body: some View {
		print("pabau form body")
		return List {
			ForEach(cssFields.indices, id:\.self ){ index in
				FormSectionField(cssField:
					Binding(
						get: { self.cssFields[index] },
						set: {
							(newValue) in self.cssFields[index] = newValue
					})
				).equatable()
			}
		}.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}
