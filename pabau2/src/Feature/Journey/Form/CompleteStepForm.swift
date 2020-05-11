import SwiftUI
import Util
import ComposableArchitecture

struct CompleteStepForm: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 32) {
				Image("ico-journey-complete")
					.frame(width: 163, height: 247)
				Text(Texts.journeyCompleteTitle)
					.font(.semibold22)
				Text(Texts.journeyCompleteDesc)
					.font(.regular16)
				NavigationLink.init(destination:
					HandBackDevice(store: self.store)
						.navigationBarTitle("")
						.navigationBarHidden(true),
														isActive: viewStore.binding(
														  get: { $0.isHandBackDeviceActive },
															send: (.patient(.complete))
														),
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
}
