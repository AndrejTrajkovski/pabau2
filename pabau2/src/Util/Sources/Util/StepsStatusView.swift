import SwiftUI

public struct StepsStatusView: View {
	public init(stepsComplete: String, stepsTotal: String) {
		self.stepsComplete = stepsComplete
		self.stepsTotal = stepsTotal
	}
	
	let stepsComplete: String
	let stepsTotal: String
	public var body: some View {
		NumberEclipse(text: stepsComplete + "/" + stepsTotal)
	}
}
