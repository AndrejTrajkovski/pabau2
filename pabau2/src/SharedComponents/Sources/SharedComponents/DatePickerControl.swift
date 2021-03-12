import SwiftUI
import Util

public struct DatePickerControl: View {

	public init(
        _ title: String,
        _ date: Binding<Date?>,
        _ configurator: Binding<ViewConfigurator?>? = nil,
        mode: UIDatePicker.Mode = .date,
		borderStyle: UITextField.BorderStyle = .none
    ) {
		self.title = title
		self.mode = mode
		self._date = date
        self._configurator = configurator ?? .constant(nil)
		self.borderStyle = borderStyle
	}

	let title: String
	let mode: UIDatePicker.Mode
	@Binding var date: Date?
    @Binding var configurator: ViewConfigurator?
	let borderStyle: UITextField.BorderStyle
	
	public var body: some View {
        TitleAndLowerContent(title, $configurator) {
			DatePickerTextField(date: $date, mode: mode, borderStyle: borderStyle)
		}
	}
}
