import SwiftUI
import Util
import ComposableArchitecture

struct HandBackDevice: View {

	let store: Store<CheckInContainerState, CheckInMainAction>
	@State var isPasscodeActive = false

	var body: some View {
		VStack {
			JourneyTransitionView(title: Texts.handBackTitle,
														description: Texts.handBackDesc,
														circleContent: {
															Image.init(systemName: "slowmo")
																.font(.regular100)
			})
				.gradientView().onTapGesture {
					self.isPasscodeActive = true
			}
			NavigationLink.emptyHidden(self.isPasscodeActive,
																 Passcode(store: self.store)
																	//have to enable nav bar on choose treatment
																	.navigationBarHidden(false)
			)
		}
	}
}
