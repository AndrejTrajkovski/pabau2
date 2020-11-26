import ComposableArchitecture
import SwiftUI
import SharedComponents

public let chooseRepeatReducer: Reducer<ChooseRepeatState, ChooseRepeatAction, CalendarEnvironment> = .init { state, action, env in
	switch action {
	case .onBackBtn:
		state.isRepeatActive = false
	case .onRepeat(let interval):
		state.chosenRepeat = interval.map { RepeatOption(interval: $0, date: Date())}
		state.isRepeatActive = false
	}
	return .none
}

public enum RepeatInterval: Int, Identifiable, CaseIterable, Equatable {
	public var id: Int { rawValue }
	case everyDay
	case everyWeek
	case everyMonth
	case everyYear
	case custom

	var title: String {
		switch self {
		case .everyDay: return "Every Day"
		case .everyWeek: return "Every Week"
		case .everyMonth: return "Every Month"
		case .everyYear: return "Every Year"
		case .custom: return "Custom"
		}
	}
}

struct RepeatOption: Equatable {
	var interval: RepeatInterval
	var date: Date
}

public struct ChooseRepeatState: Equatable {
	var chosenRepeat: RepeatOption?
	var isRepeatActive: Bool = false
}

public enum ChooseRepeatAction {
	case onBackBtn
	case onRepeat(RepeatInterval?)
}

struct ChooseRepeat: View {

	public let store: Store<ChooseRepeatState, ChooseRepeatAction>
	@ObservedObject var viewStore: ViewStore<ChooseRepeatState, ChooseRepeatAction>
	
	init(store: Store<ChooseRepeatState, ChooseRepeatAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		List {
			ForEach(RepeatInterval.allCases) { item in
				TextAndCheckMark(item.title,
								 item == viewStore.state.chosenRepeat?.interval)
					.onTapGesture {
						viewStore.send(.onRepeat(item))
					}
			}
			TextAndCheckMark("No repeat", viewStore.state.chosenRepeat == nil)
				.onTapGesture {
					viewStore.send(.onRepeat(nil))
				}
		}
	}
}
