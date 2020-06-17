import SwiftUI
import Util
import ComposableArchitecture

struct HandBackDeviceState: Equatable {
	var isEnterPasscodeActive: Bool
	var isNavBarHidden: Bool
}

struct HandBackDevice: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store.scope(
			state: { $0.handback },
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
					NavigationLink.emptyHidden(viewStore.state.isEnterPasscodeActive,
																		 Passcode(store: self.store.scope(
																			state: { $0 }, action: { $0 }))
																			.navigationBarHidden(viewStore.state.isNavBarHidden)
																			.navigationBarTitle("")
																			//have to enable nav bar on choose treatment
					)
				}
		}
	}
}
