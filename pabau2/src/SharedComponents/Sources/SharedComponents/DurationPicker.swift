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
    
    public static let allDay: [Duration] = DurationDailyGenerator().allDay()
}

struct DurationDailyGenerator {
    private var minuteInterval = 15
    private let formatter = DateComponentsFormatter()

    public init(_ minuteInterval: Int = 15) {
        self.minuteInterval = minuteInterval
    }
    
    internal func allDay() -> [Duration] {
        var durations: [Duration] = []
        let itemsPerDay = (60 / minuteInterval) * 24
        
        for i in 1..<itemsPerDay {
            let duration: Duration = Duration(name: getName(minute: (i * minuteInterval)),
                                              id: i,
                                              duration: TimeInterval(i * minuteInterval),
                                              nameInCircle: getCircleName(minute: i * minuteInterval))
            durations.append(duration)
        }
        
        return durations
    }
    
    private func getName(minute: Int) -> String {
        let hour = minute / 60
        let min = minute % 60
        return String(format: "%02d:%02d", hour, min)
    }
    
    private func getCircleName(minute: Int) -> String {
        let hour = minute / 60
        let min = minute % 60
        
        return hour < 1 ? String(format: "%02dm", min) : String(format: "%2dh%02dm", hour, min)
    }
}
