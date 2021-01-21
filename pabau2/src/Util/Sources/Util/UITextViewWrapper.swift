import SwiftUI
#if !os(macOS)
import UIKit

public struct MultilineTextView: UIViewRepresentable {

	var initialText: String
	let placeholder: String
	let onTextChange: (String) -> Void

	public init (initialText: String,
							 placeholder: String,
							 onTextChange: @escaping (String) -> Void) {
		self.initialText = initialText
		self.onTextChange = onTextChange
		self.placeholder = placeholder
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeUIView(context: Context) -> UITextView {
		let textView = UITextView()
		textView.delegate = context.coordinator
		textView.isScrollEnabled = true
		textView.isEditable = true
		textView.isUserInteractionEnabled = true
		textView.text = initialText
		textView.layer.cornerRadius = 8.0
		textView.layer.masksToBounds = true
		textView.layer.borderWidth = 1.0
		textView.layer.borderColor = UIColor.init(hex: "C0C0C0").cgColor
		textView.addDoneButton(title: "Done", target: textView, selector: #selector(UIView.endEditing(_:)))
		textView.text = initialText
		textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return textView
	}

	public func updateUIView(_ uiView: UITextView, context: Context) {
//		uiView.text = initialText
	}

	public class Coordinator: NSObject, UITextViewDelegate {
		var parent: MultilineTextView
		init(_ uiTextView: MultilineTextView) {
			self.parent = uiTextView
		}

//		public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//			let result = (textView.text as NSString?)?.replacingCharacters(in: range, with: text) ?? text
//			parent.onTextChange(result as String)
//			return true
//		}

//		public func textViewDidChange(_ textView: UITextView) {
//			parent.onTextChange(textView.text)
//		}

		public func textViewDidBeginEditing(_ textView: UITextView) {
			if textView.textColor == UIColor.lightGray {
				textView.text = nil
				textView.textColor = UIColor.black
			}
		}
		public func textViewDidEndEditing(_ textView: UITextView) {
			if textView.text.isEmpty {
				textView.text = parent.placeholder
				textView.textColor = UIColor.lightGray
			}
			parent.onTextChange(textView.text)
		}
	}
}

extension UITextView {
	func addDoneButton(title: String, target: Any, selector: Selector) {
		let toolBar = UIToolbar(frame: CGRect(x: 0.0,
											  y: 0.0,
											  width: UIScreen.main.bounds.size.width,
											  height: 44.0))//1
		let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
		let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
		toolBar.setItems([flexible, barButton], animated: false)//4
		self.inputAccessoryView = toolBar//5
	}
}
#endif
