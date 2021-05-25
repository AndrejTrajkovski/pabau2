import SwiftUI
import ComposableArchitecture
import Util
import ChooseEmployees
import ChooseLocation

public struct ChooseLocationAndEmployee: View {
	
	public init(store: Store<ChooseLocationAndEmployeeState, ChooseLocationAndEmployeeAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: State.init(state:)))
	}
	
	
	let store: Store<ChooseLocationAndEmployeeState, ChooseLocationAndEmployeeAction>
	@ObservedObject var viewStore: ViewStore<State, ChooseLocationAndEmployeeAction>
	
	struct State: Equatable {
		let employeeName: String
		let employeeColor: Color?
		let employeeError: String?
		let isChooseEmployeeActive: Bool
		
		let locationName: String
		let locationColor: Color?
		let locationError: String?
		let isChooseLocationActive: Bool
		
		init (state: ChooseLocationAndEmployeeState) {
			self.employeeName = state.chosenEmployee?.name ?? "Choose Employee"
			self.employeeColor = state.chosenEmployee == nil ? Color.grayPlaceholder : nil
			self.employeeError = state.employeeValidationError
			self.isChooseEmployeeActive = state.chooseEmployeeState != nil
			
			self.locationName = state.chosenLocation?.name ?? "Choose Location"
			self.locationColor = state.chosenLocation == nil ? Color.grayPlaceholder : nil
			self.locationError = state.locationValidationError
			self.isChooseLocationActive = state.chooseLocationState != nil
		}
	}
	
	public var body: some View {
		HStack(spacing: 24.0) {
			TitleAndValueLabel(
				"WITH",
				viewStore.state.employeeName,
				viewStore.state.employeeColor,
				.constant(viewStore.employeeError)
			).onTapGesture {
				self.viewStore.send(.onChooseEmployee)
			}
			NavigationLink.emptyHidden(viewStore.isChooseEmployeeActive,
									   IfLetStore(
										store.scope(
											state: { $0.chooseEmployeeState },
											action: { .chooseEmployee($0 )}),
										then: ChooseEmployeesView.init(store:)
									   )
			)
			TitleAndValueLabel(
				"LOCATION",
				viewStore.state.locationName,
				viewStore.state.locationColor,
				.constant(viewStore.locationError)
			).onTapGesture {
				self.viewStore.send(.onChooseLocation)
			}
			NavigationLink.emptyHidden(viewStore.isChooseLocationActive,
									   IfLetStore(
										store.scope(
											state: { $0.chooseLocationState },
											action: { .chooseLocation($0 )}),
										then: ChooseLocationView.init(store:)
									   )
			)
		}
	}
}
