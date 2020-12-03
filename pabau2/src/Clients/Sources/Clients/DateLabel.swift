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
