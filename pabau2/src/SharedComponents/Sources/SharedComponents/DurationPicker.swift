import Foundation
import SwiftUI
import Util
import ComposableArchitecture

public struct Duration: SingleChoiceElement {

	public init(name: String, id: Int, duration: TimeInterval, nameInCircle: String) {
		self.name = name
		self.id = id
		self.duration = duration
		self.nameInCircle = nameInCircle
	}

	public var name: String
	public var id: Int
	public var duration: TimeInterval
	public var nameInCircle: String
}

public struct DurationPicker: View {
	let store: Store<SingleChoiceState<Duration>, SingleChoiceActions<Duration>>

	public init (store: Store<SingleChoiceState<Duration>, SingleChoiceActions<Duration>>) {
		self.store = store
	}

    public var body: some View {
        SingleChoicePicker(
            store: store,
            cell: {
                DurationPickerItem(duration: $0.item)
            }
        )
    }
}

struct DurationPickerItem: View {
	let duration: Duration
	var body: some View {
		Circle()
			.fill(Color(hex: "007AFF"))
			.overlay(
				ZStack {
					Text(duration.nameInCircle)
						.foregroundColor(.white)
						.font(.medium14)
				}
			).frame(width: 44, height: 44)
	}
}

extension Duration {
	public static let all = [
		Duration(name: "00:15", id: 1, duration: 15, nameInCircle: "15m"),
		Duration(name: "00:30 ", id: 2, duration: 30, nameInCircle: "30m"),
		Duration(name: "00:45", id: 3, duration: 45, nameInCircle: "45m"),
		Duration(name: "01:00", id: 4, duration: 60, nameInCircle: "1h"),
		Duration(name: "02:00", id: 5, duration: 120, nameInCircle: "2h")
	]
}
