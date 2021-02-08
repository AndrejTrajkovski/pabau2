import SwiftUI

public struct DatePickerTextField: UIViewRepresentable {
    @Binding var date: Date?

    var didChange: () -> Void = { }

    private var minimumDate: Date? = Date()
    private var maximumDate: Date?
    private let datePickerMode: UIDatePicker.Mode
    private var placeholder: String? = "Select a date"

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()

    private var font: UIFont?
    private var textColor: UIColor?
    private var textContentType: UITextContentType?
    private var keyboardType: UIKeyboardType = .default
    private var isUserInteractionEnabled: Bool = true

	public init(date: Binding<Date?>,
				mode: UIDatePicker.Mode,
				font: UIFont = UIFont.systemFont(ofSize: 15, weight: .semibold),
				textColor: UIColor = .black,
				isUserInteractionEnabled: Bool = true,
				textContentType: UITextContentType? = nil,
				didChange: @escaping () -> Void = { }) {
        self._date = date
		self.font = font
		self.textColor = textColor
        self.didChange = didChange
        self.datePickerMode = mode
		self.isUserInteractionEnabled = isUserInteractionEnabled
		self.textContentType = textContentType

        dateFormatter.dateStyle = mode == .date ? .long : .none
        dateFormatter.timeStyle = mode == .date ? .none : .short
    }

    public func makeUIView(context: Context) -> UITextField {

        let textField = UITextField()
        textField.delegate = context.coordinator
		date.map { textField.text = dateFormatter.string(from: $0) }
        textField.font = font
        textField.textColor = textColor
		textField.borderStyle = .none

        if let contentType = textContentType {
            textField.textContentType = contentType
        }

        textField.keyboardType = keyboardType
        textField.isUserInteractionEnabled = isUserInteractionEnabled

        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = datePickerMode
        datePickerView.maximumDate = minimumDate
        datePickerView.maximumDate = maximumDate
        datePickerView.preferredDatePickerStyle = .wheels
        datePickerView.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleDatePicker(sender:)),
            for: .valueChanged)

        textField.inputView = datePickerView

        addDoneButtonToKeyboard(textField)
        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
		date.map { uiView.text = dateFormatter.string(from: $0) }
    }

    private func addDoneButtonToKeyboard(_ view: UITextField) {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: view,
            action: #selector(UITextField.resignFirstResponder))

        done.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)],
            for: .normal)

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        view.inputAccessoryView = doneToolbar
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(date: $date, didChange: didChange)
    }

    final public class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var date: Date?
        var didChange: () -> Void

        init(date: Binding<Date?>, didChange: @escaping () -> Void) {
            self._date = date
            self.didChange = didChange
        }

        @objc func handleDatePicker(sender: UIDatePicker) {
            date = sender.date
            didChange()
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return false
        }

        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}