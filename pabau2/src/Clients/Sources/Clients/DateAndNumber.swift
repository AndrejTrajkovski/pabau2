import SwiftUI
import Util

struct DateAndNumber: View {
	let date: Date
	let number: Int
	
	static let dateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy"
		return formatter
	}()
	
	var body: some View {
		HStack {
			NumberEclipse(text: String(number))
			Text(Self.dateFormat.string(from: date))
				.foregroundColor(.white)
				.font(.regular12)
				.padding(5)
				.frame(height: 20)
		}
		.background(RoundedCorners(color: Color.black.opacity(0.5),
															 tl: 25, tr: 25, bl: 25, br: 25))
	}
}
