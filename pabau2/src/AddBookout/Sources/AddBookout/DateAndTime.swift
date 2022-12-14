import SwiftUI
import ComposableArchitecture
import Util
import Model
import SharedComponents

struct DateAndTime: View {
	let store: Store<AddBookoutState, AddBookoutAction>
	@ObservedObject var viewStore: ViewStore<AddBookoutState, AddBookoutAction>

	init(store: Store<AddBookoutState, AddBookoutAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack(spacing: 16) {
			HStack {
				DatePickerControl.init(
					"DAY",
					viewStore.binding(
						get: { $0.startDate },
						send: { .chooseStartDate($0) }
					),
					.constant(viewStore.dayValidator)
				).isHidden(!viewStore.isAllDay, remove: true)

				DatePickerControl.init(
					"DAY",
					viewStore.binding(
						get: { $0.startDate },
						send: { .chooseStartDate($0) }
					),
					.constant(viewStore.dayValidator),
					mode: .dateAndTime
				).isHidden(viewStore.isAllDay, remove: true)
			}
			GeometryReader { geometry in
				HStack {
                    SingleChoiceLink.init(
                        content: {
                            TitleAndValueLabel.init(
                                "DURATION",
                                self.viewStore.state.duration,
                                nil,
                                .constant(nil)
                            )
                        },
                        store: self.store.scope(
                            state: { $0.chooseDuration },
                            action: { .chooseDuration($0) }
                        ),
                        cell: TextAndCheckMarkContainer.init(state:),
                        title: "Duration"
                    )
                    .frame(width: geometry.size.width * 0.4)
                    DurationPicker(
                        store: store.scope(
                            state: { $0.choosePredefinedDuration },
                            action: { .choosePredefinedDuration($0) }
                        )
                    )
					.frame(maxWidth: .infinity)
				}
			}
		}.wrapAsSection(title: "Date & Time")
	}
}
