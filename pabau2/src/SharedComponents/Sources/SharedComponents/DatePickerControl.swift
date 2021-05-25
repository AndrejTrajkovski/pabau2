import SwiftUI
import Util

public struct DatePickerControl: View {

	public init(
        _ title: String,
        _ date: Binding<Date?>,
        _ error: Binding<String?>,
        mode: UIDatePicker.Mode = .date,
		borderStyle: UITextField.BorderStyle = .none
    ) {
		self.title = title
		self.mode = mode
		self._date = date
        self._error = error
		self.borderStyle = borderStyle
	}

	let title: String
	let mode: UIDatePicker.Mode
	@Binding var date: Date?
    @Binding var error: String?
	let borderStyle: UITextField.BorderStyle
	
	public var body: some View {
        TitleAndLowerContent(title, $error) {
			DatePickerTextField(date: $date, mode: mode, borderStyle: borderStyle)
		}
	}
}
