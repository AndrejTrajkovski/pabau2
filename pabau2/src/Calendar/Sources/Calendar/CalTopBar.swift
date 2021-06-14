import SwiftUI
import ComposableArchitecture
import Model
import Util

struct CalTopBar: View {
	let store: Store<CalendarState, CalendarAction>
	@ObservedObject var viewStore: ViewStore<CalendarState, CalendarAction>
	
	init(store: Store<CalendarState, CalendarAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(Color(hex: "F9F9F9"))
                .frame(height: Constants.statusBarHeight)
			ZStack {
				addButton
					.padding(.leading, 20)
					.exploding(.leading)
				CalendarTypePicker(
					store:
						self.store.scope(
							state: { $0.calTypePicker },
							action: { .calTypePicker($0) }
						)
				)
				.padding()
				.exploding(.center)
				HStack {
					Button {
						viewStore.send(.changeCalScope)
					} label: {
						Image("calendar_icon")
							.renderingMode(.template)
							.accentColor(.blue)
					}
					Button(
						action: { viewStore.send(.toggleFilters)},
						label: filtersLabel
					)
				}
				.padding()
				.padding(.trailing, 20)
				.exploding(.trailing)
			}
			.frame(height: 50)
			.background(Color(hex: "F9F9F9"))
			Divider()
		}
	}
	
	var addButton: some View {
		HStack {
            if Constants.isPad {
                 padPlusButton
            } else {
                iphonePlusButton
            }
		}
	}

    var padPlusButton: some View {
        PlusButton {
            viewStore.send(.addEventDropdownToggle(true))
        }
        .popover(
            isPresented:
                viewStore.binding(
                    get: { $0.isAddEventDropdownShown },
                    send: CalendarAction.addEventDropdownToggle(false))
        ) {
            AddEventDropdown(store: store.stateless)
        }
    }

    var iphonePlusButton: some View {
        PlusButton {
            viewStore.send(.addEventDropdownToggle(true))
        }
        .actionSheet(isPresented: viewStore.binding(
                get: { $0.isAddEventDropdownShown },
                send: CalendarAction.addEventDropdownToggle(false))
        ) {
            ActionSheet(
                title: Text("Please choose"),
                message: nil,
                buttons: [
                    .default(
                        Text(EventType.appointment.title())
                    ) {
                        viewStore.send(.addEventDelay(.appointment))
                    },
                    .default(
                        Text(EventType.bookout.title())
                    ) {
                        viewStore.send(.addEventDelay(.bookout))
                    },
                    .default(
                        Text(EventType.shift.title())
                    ) {
                        viewStore.send(.addEventDelay(.shift))
                    },
                    .cancel()
                ]
            )
        }
    }

	@ViewBuilder
	func filtersLabel() -> some View {
		switch viewStore.state.filtersLoadingState {
		case .gotSuccess:
			Text(Texts.filters)
		case .gotError(_), .initial:
			Image(systemName: "exclamationmark.triangle.fill")
				.font(.system(size: 20))
				.foregroundColor(.red)
		case .loading:
			ActivityIndicator(isAnimating: .constant(true), style: .medium)
				.foregroundColor(Color.blue)
		}
	}
}
