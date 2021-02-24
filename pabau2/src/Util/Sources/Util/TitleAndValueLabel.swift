import SwiftUI

public struct TitleAndValueLabel: View {
    @Binding var configurator: ViewConfigurator?

	let labelTxt: String
	let valueText: String
    var textColor: Color?

	public init(
        _ labelTxt: String,
		_ valueText: String,
        _ textColor: Color? = nil,
        _ configurator: Binding<ViewConfigurator?>? = nil
    ) {
		self.labelTxt = labelTxt
		self.valueText = valueText
        self.textColor = textColor
        self._configurator = configurator ?? .constant(nil)
	}
	public var body: some View {
		TitleAndLowerContent(labelTxt, $configurator) {
			Text(self.valueText)
				.foregroundColor(textColor ?? Color.textFieldAndTextLabel)
				.font(.semibold15)
		}
	}
}

public struct ViewConfigurator: Equatable {
    public static func == (lhs: ViewConfigurator, rhs: ViewConfigurator) -> Bool {
        lhs.state == rhs.state && lhs.errorString == rhs.errorString
    }

    public enum State {
        case normal
        case error
    }

    public var state: State
    public var errorString: String = "Error"

    public init(state: State = .normal, errorString: String = "Error") {
        self.state = state
        self.errorString = errorString
    }
}

public struct TitleAndLowerContent<Content: View>: View {
	public init(
        _ labelTxt: String,
        _ configurator: Binding<ViewConfigurator?>? = nil,
        @ViewBuilder _ lowerContent: @escaping () -> Content
    ) {
		self.labelTxt = labelTxt
		self.lowerContent = lowerContent

        self._configurator = configurator ?? .constant(nil)
	}

	let labelTxt: String
	let lowerContent: () -> Content
    @Binding var configurator: ViewConfigurator?

	public var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(labelTxt)
				.foregroundColor(Color.textFieldAndTextLabel.opacity(0.5))
				.font(.semibold12)
			lowerContent()
            Divider()
                .background(configurator?.state == .error ? Color.red : Color.textFieldBottomLine)
            Text(configurator?.errorString ?? "")
                .font(.bold13)
                .foregroundColor(.red)
                .isHidden(configurator == nil || configurator?.state == .normal)
		}
	}
}
