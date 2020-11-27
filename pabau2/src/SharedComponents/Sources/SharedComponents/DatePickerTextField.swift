//
//  DatePickerTextField.swift
//  
//
//  Created by Yuriy Berdnikov on 27.11.2020.
//

import SwiftUI

public struct DatePickerTextField: UIViewRepresentable {
    @Binding var date: Date

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
    private var foregroundColor: UIColor?
    private var contentType: UITextContentType?
    private var keyboardType: UIKeyboardType = .default
    private var isUserInteractionEnabled: Bool = true

    public init(date: Binding<Date>, mode: UIDatePicker.Mode = .date, didChange: @escaping () -> Void = { }) {
        self._date = date
        self.didChange = didChange
        self.datePickerMode = mode

        dateFormatter.dateStyle = mode == .date ? .long : .none
        dateFormatter.timeStyle = mode == .date ? .none : .short
    }

    public func makeUIView(context: Context) -> UITextField {

        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.text = dateFormatter.string(from: date)
        textField.font = font
        textField.textColor = foregroundColor

        if let contentType = contentType {
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
        uiView.text = dateFormatter.string(from: date)
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
        @Binding var date: Date
        var didChange: () -> Void

        init(date: Binding<Date>, didChange: @escaping () -> Void) {
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

public extension DatePickerTextField {
    func minimumDate(_ date: Date?) -> some View {
        var view = self
        view.minimumDate = date
        return view
    }

    func maximumDate(_ date: Date?) -> some View {
        var view = self
        view.maximumDate = date
        return view
    }

    func placeholder(_ text: String?) -> some View {
        var view = self
        view.placeholder = text
        return view
    }

    func dateFormatter(_ formatter: DateFormatter) -> some View {
        var view = self
        view.dateFormatter = formatter
        return view
    }

    func font(_ font: UIFont?) -> some View {
        var view = self
        view.font = font
        return view
    }

    func foregroundColor(_ color: UIColor?) -> some View {
        var view = self
        view.foregroundColor = color
        return view
    }

    func textContentType(_ textContentType: UITextContentType?) -> some View {
        var view = self
        view.contentType = textContentType
        return view
    }

    func keyboardType(_ type: UIKeyboardType) -> some View {
        var view = self
        view.keyboardType = type
        return view
    }

    func disabled(_ disabled: Bool) -> some View {
        var view = self
        view.isUserInteractionEnabled = disabled
        return view
    }
}
