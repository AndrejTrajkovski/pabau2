import SwiftUI
import UIKit

//struct TextView: UIViewRepresentable {
//
//	@State var text: String
//
//	func makeUIView(context: Context) -> UITextView {
//		let view = UITextView()
//		view.isScrollEnabled = false
//		view.isEditable = true
//		view.isUserInteractionEnabled = true
//		view.contentInset = UIEdgeInsets(top: 5,
//																		 left: 10, bottom: 5, right: 5)
//		view.delegate = context.coordinator
//
//		return view
//	}
//
//	func updateUIView(_ uiView: UITextView, context: Context) {
//		uiView.text = text
//	}
//
//	func makeCoordinator() -> TextView.Coordinator {
//		Coordinator(self)
//	}
//
//	class Coordinator: NSObject, UITextViewDelegate {
//		var control: TextView
//
//		init(_ control: TextView) {
//			self.control = control
//		}
//
//		func textViewDidChange(_ textView: UITextView) {
//			control.text = textView.text
//		}
//	}
//}

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
		textView.isScrollEnabled = false
		textView.isEditable = true
		textView.isUserInteractionEnabled = true
		textView.text = initialText
		textView.layer.cornerRadius = 8.0
		textView.layer.masksToBounds = true
		textView.layer.borderWidth = 1.0
		return textView
	}

	public func updateUIView(_ uiView: UITextView, context: Context) {
//		uiView.text = initialText
	}

	public class Coordinator : NSObject, UITextViewDelegate {
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
//
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
