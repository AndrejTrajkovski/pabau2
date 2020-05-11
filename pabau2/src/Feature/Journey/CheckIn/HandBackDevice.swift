import SwiftUI
import Util
import ComposableArchitecture

struct HandBackDevice: View {

	let store: Store<CheckInContainerState, CheckInContainerAction>

	var body: some View {
		WithViewStore(store.scope(
			state: { $0.isEnterPasscodeActive },
			action: { $0 })) { viewStore in
				VStack {
					JourneyTransitionView(title: Texts.handBackTitle,
																description: Texts.handBackDesc,
																circleContent: {
																	Image.init(systemName: "slowmo")
																		.font(.regular100)
					})
						.gradientView().onTapGesture {
							viewStore.send(.didTouchHandbackDevice)
					}
					NavigationLink.emptyHidden(viewStore.state,
																		 Passcode(store: self.store)
																			//have to enable nav bar on choose treatment
																			.navigationBarHidden(false)
					)
				}
		}
	}
}
