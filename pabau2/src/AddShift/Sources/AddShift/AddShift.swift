import SwiftUI
import ComposableArchitecture
import SharedComponents
import Model
import Util
import CoreDataModel
import ChooseLocationAndEmployee

public struct AddShift: View {
	
	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>
	
	public var body: some View {
		VStack {
			SwitchCell(
				text: "Published",
				store: store.scope(
					state: { $0.isPublished },
					action: { .isPublished($0)}
				))
				.wrapAsSection(title: "Add Shift")
			ChooseLocationAndEmployee(store:
										store.scope(
											state: { $0.chooseLocAndEmp },
											action: { .chooseLocAndEmp($0) })
			)
			DateAndTime(store: store)
				.wrapAsSection(title: "Date & Time")
			NotesSection(
				title: "SHIFT NOTE",
				tfLabel: "Add a shift note",
				store: store.scope(
					state: { $0.note },
					action: { .note($0)}
				)
			)
			AddEventPrimaryBtn(title: "Save Shift") {
				self.viewStore.send(.saveShift)
            }.padding([.top, .bottom], 30)
			//swiftui bug fix - https://stackoverflow.com/a/67312740/3050624
			NavigationLink(destination: EmptyView()) {
				EmptyView()
			}
			Spacer()
		}
		.addEventWrapper(onXBtnTap: { viewStore.send(.close) })
		.loadingView(.constant(self.viewStore.state.showsLoadingSpinner))
	}

	public init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

struct DateAndTime: View {
	
	let store: Store<AddShiftState, AddShiftAction>
	@ObservedObject var viewStore: ViewStore<AddShiftState, AddShiftAction>
	
	var body: some View {
		VStack(spacing: 16) {
			HStack(spacing: 16) {
				DatePickerControl(
					"Day",
					viewStore.binding(
						get: { $0.startDate },
						send: { .startDate($0) }
					), .constant(nil)
				)
			}
			HStack(spacing: 16) {
				DatePickerControl(
					"START TIME",
					viewStore.binding(
						get: { $0.startTime },
						send: { .startTime($0) }
					),
					.constant(viewStore.startTimeValidator),
					mode: .time
				)
				DatePickerControl(
					"END TIME",
					viewStore.binding(
						get: { $0.endTime },
						send: { .endTime($0) }
					),
					.constant(viewStore.endTimeValidator),
					mode: .time
				)
			}
		}
	}

	init(store: Store<AddShiftState, AddShiftAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
}

extension Employee: SingleChoiceElement { }
extension Location: SingleChoiceElement { }

extension AddShiftState {
	
	public static func makeEmpty(chooseLocAndEmp: ChooseLocationAndEmployeeState) -> AddShiftState {
		AddShiftState(
			shiftRotaID: nil,
			isPublished: true,
			chooseLocAndEmp: chooseLocAndEmp,
			startDate: nil,
			startTime: nil,
			endTime: nil,
			note: ""
		)
	}
	
	public static func makeEditing(shift: Shift,
								   chooseLocAndEmp: ChooseLocationAndEmployeeState
	) -> AddShiftState {
		AddShiftState(
			shiftRotaID: shift.rotaID,
			isPublished: shift.published ?? false,
			chooseLocAndEmp: chooseLocAndEmp,
			startDate: shift.date,
			startTime: shift.startTime,
			endTime: shift.endTime,
			note: shift.notes
		)
	}
}
