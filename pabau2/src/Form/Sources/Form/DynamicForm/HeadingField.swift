import SwiftUI
import ComposableArchitecture
import Model

struct AttributedOrTextField: View {
	let store: Store<AttributedOrText, Never>
	var body: some View {
        SwitchStore(store) {
            CaseLet(state: /AttributedOrText.text, action: { $0 },
                    then: { (localStore: Store<String, Never>) in
                        Text(ViewStore(localStore).state)
                       }
            )
            CaseLet(state: /AttributedOrText.attributed, action: { $0 },
                    then: { (localStore: Store<NSAttributedString, Never>) in
                        AttributedStringLabel(text: ViewStore(localStore).state)
                       }
            )
        }
	}
}

struct AttributedStringLabel: View {
	let text: NSAttributedString

	@State private var height: CGFloat = .zero

	var body: some View {
		InternalLabelView(text: text, dynamicHeight: $height)
			.frame(minHeight: height)
	}

	struct InternalLabelView: UIViewRepresentable {
		let text: NSAttributedString
		@Binding var dynamicHeight: CGFloat

		func makeUIView(context: Context) -> UILabel {
			let label = UILabel()
			label.numberOfLines = 0
			label.lineBreakMode = .byWordWrapping
			label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
			label.attributedText = text
			label.font = UIFont.init(name: "HelveticaNeue-Light", size: 17)
			DispatchQueue.main.async {
				dynamicHeight = label.sizeThatFits(CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
			}
			return label
		}

		func updateUIView(_ uiView: UILabel, context: Context) {
		}
	}
}
//
//struct UIKLabel: UIViewRepresentable {
//
//	typealias TheUIView = UILabel
//	fileprivate var configuration = { (view: TheUIView) in }
//
//	func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView {
//		let view = TheUIView()
//		configuration(view)
//		return view
//	}
//	func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
//		DispatchQueue.main.async {
//			configuration(uiView)
//		}
//	}
//}
