import Foundation
import SwiftUI
import Util

struct DateLabel: View {
	let date: Date
	var body: some View {
		HStack {
			DayMonthYear(date: date)
			HourMinutes(date: date)
		}
	}
}

struct DayMonthYear: View {
    let date: Date
    var foregroundColorImage: Color = .accentColor

	static let dateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy"
		return formatter
	}()
	var body: some View {
		HStack {
			Image(systemName: "calendar")
                .foregroundColor(foregroundColorImage)
			Text(Self.dateFormat.string(from: date))
				.font(.regular15)
				.foregroundColor(.clientCardNeutral)
		}
	}
}

struct HourMinutes: View {
	let date: Date
	static let dateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "hh:mm"
		return formatter
	}()
	var body: some View {
		HStack {
			Image(systemName: "clock")
				.foregroundColor(.accentColor)
			Text(Self.dateFormat.string(from: date))
				.font(.regular15)
				.foregroundColor(.clientCardNeutral)
		}
	}
}

struct TimeIntervalSinceView: View {

    let creationDate: Date
    private let currentDate = Date()

    var body: some View {
        calculateTimeDifference()
    }

    func calculateTimeDifference() -> some View {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour]
        dateComponentsFormatter.unitsStyle = .full
        let timeDifference = dateComponentsFormatter.string(from: creationDate,
                                                            to: currentDate)?.components(separatedBy: ",").first
        if let timeLeft = timeDifference {
            if timeLeft.contains("hour") {
                return Text("Today")
            }
            return Text(timeLeft + " ago")
        }
        return Text("Unknown time ago")
    }

}
