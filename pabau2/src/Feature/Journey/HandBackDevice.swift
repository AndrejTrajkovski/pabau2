import SwiftUI
import Util
struct HandBackDevice: View {

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
				Passcode()
				.navigationBarTitle("")
				.navigationBarHidden(true)
			)
		}
	}
}
