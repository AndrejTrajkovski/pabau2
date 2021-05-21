import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents
import CoreDataModel
import ChooseEmployees
import ChooseLocation

struct FirstSection: View {
	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 16) {
				Buttons().isHidden(true, remove: true)
				SwitchCell(
					text: Texts.allDay,
					store: store.scope(
						state: { $0.isAllDay },
						action: { .isAllDay($0)}
					)
				)
				TitleAndValueLabel(
					"EMPLOYEE",
					self.viewStore.state.chooseEmployeesState.chosenEmployee?.name ?? "Choose Employee",
					self.viewStore.state.chooseEmployeesState.chosenEmployee?.name == nil ? Color.grayPlaceholder : nil,
					viewStore.binding(
						get: { $0.employeeConfigurator },
						send: .ignore
					)
				).onTapGesture {
					self.viewStore.send(.onChooseEmployee)
				}
				NavigationLink.emptyHidden(
					self.viewStore.state.chooseEmployeesState.isChooseEmployeesActive,
					ChooseEmployeesView(
						store: self.store.scope(
							state: { $0.chooseEmployeesState },
							action: { .chooseEmployeesAction($0) }
						)
					)
				)
				TitleAndValueLabel(
					"LOCATION",
					self.viewStore.state.chooseLocationState.chosenLocation?.name ?? "Choose Location",
					self.viewStore.state.chooseLocationState.chosenLocation?.name == nil ? Color.grayPlaceholder : nil
				).onTapGesture {
					self.viewStore.send(.onChooseLocation)
				}
				NavigationLink.emptyHidden(
					self.viewStore.state.chooseLocationState.isChooseLocationActive,
					ChooseLocationView(
						store: self.store.scope(
							state: { $0.chooseLocationState },
							action: { .chooseLocation($0) }
						)
					)
				)
			}.wrapAsSection(title: "Add Bookout")
		}
	}
}
