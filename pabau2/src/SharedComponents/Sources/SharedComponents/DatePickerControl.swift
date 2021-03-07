import SwiftUI
import Util

public struct DatePickerControl: View {

	public init(
        _ title: String,
        _ date: Binding<Date?>,
        _ configurator: Binding<ViewConfigurator?>? = nil,
        mode: UIDatePicker.Mode = .date
    ) {
		self.title = title
		self.mode = mode
		self._date = date

        self._configurator = configurator ?? .constant(nil)
	}

	let title: String
	let mode: UIDatePicker.Mode
	@Binding var date: Date?
    @Binding var configurator: ViewConfigurator?

	public var body: some View {
        TitleAndLowerContent(title, $configurator) {
            DatePickerTextField(date: $date, mode: mode)
		}
	}
}
