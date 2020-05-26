import SwiftUI
import ComposableArchitecture

struct CheckInPatient: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store.scope(state: { $0.isHandBackDeviceActive },
															action: { $0 })) { viewStore in
			VStack {
				CheckInMain(store:
					self.store.scope(state: { $0.patientCheckIn },
													 action: { .patient($0) }
				))
					.navigationBarTitle("")
					.navigationBarHidden(true)
				NavigationLink.emptyHidden(viewStore.state,
																	 HandBackDevice(
																		store: self.store.scope(
																			state: { $0 }, action: { $0 }
																		)
																	)
																		.navigationBarTitle("")
																		.navigationBarHidden(true)
				)
			}
		}
	}
}
