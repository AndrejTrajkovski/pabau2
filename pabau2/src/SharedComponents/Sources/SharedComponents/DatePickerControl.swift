import SwiftUI
import Util

public struct DatePickerControl: View {
	
	public init(_ title: String, _ date: Binding<Date?>, mode: UIDatePicker.Mode = .date) {
		self.title = title
		self.mode = mode
		self._date = date
	}
	
	let title: String
	let mode: UIDatePicker.Mode
	@Binding var date: Date?
	
	public var body: some View {
		TitleAndLowerContent(title) {
			DatePickerTextField(date: $date, mode: mode)
		}
	}
}
