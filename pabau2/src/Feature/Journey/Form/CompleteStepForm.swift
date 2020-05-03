import SwiftUI
import Util
import ComposableArchitecture

struct CompleteStepForm: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	var body: some View {
		VStack(spacing: 32) {
			Image("ico-journey-complete")
				.frame(width: 163, height: 247)
			Text(Texts.journeyCompleteTitle)
				.font(.semibold22)
			Text(Texts.journeyCompleteDesc)
				.font(.regular16)
			NavigationLink.init(destination:
				HandBackDevice(store: store)
				.navigationBarTitle("")
				.navigationBarHidden(true),
													isActive: .constant(true),
													label: {
														Text("Complete")
															.frame(minWidth: 0, maxWidth: .infinity)
															.frame(height: 50)
															.foregroundColor(Color.white)
															.background(Color.accentColor)
															.cornerRadius(10)
															.font(Font.system(size: 16.0, weight: .bold))
															.frame(width: 290)
			})
		}.padding(32)
	}
}
