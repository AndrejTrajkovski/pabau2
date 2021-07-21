import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util
import SharedComponents

struct CheckInPatientContainer: View {
    let store: Store<CheckInLoadedState, CheckInLoadedAction>
    
	var body: some View {
        WithViewStore(store.scope(state: { $0.isHandBackDeviceActive })) { viewStore in
            CheckInPathway(store: store.scope(state: { $0.patientCheckIn }, action: { .patient($0) }))
            handBackDeviceLink(viewStore.state)
        }
	}

	func handBackDeviceLink(_ active: Bool) -> some View {
		NavigationLink.emptyHidden(active,
								   HandBackDevice(store: self.store)
								   .navigationBarTitle("")
								   .navigationBarHidden(true)
		)
	}
}
