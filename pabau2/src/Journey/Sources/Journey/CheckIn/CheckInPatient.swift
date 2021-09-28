import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util
import SharedComponents

struct CheckInPatientContainer: View {
    
    let store: Store<CheckInLoadedState, CheckInLoadedAction>
    @ObservedObject var viewStore: ViewStore<State, Never>
    
    init(store: Store<CheckInLoadedState, CheckInLoadedAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)).actionless)
    }
    
    struct State: Equatable {
        let isHandBackDeviceActive: Bool
        init(state: CheckInLoadedState) {
            self.isHandBackDeviceActive = state.isHandBackDeviceActive
        }
    }
    
    var body: some View {
        Group {
            if viewStore.isHandBackDeviceActive {
                NavigationLink.emptyHidden(true,
                                           HandBackDevice(store: self.store)
                                            .navigationBarTitle("")
                                            .navigationBarHidden(true)
                )
            } else {
                CheckInPathway(store: store.scope(state: { $0.patientCheckIn },
                                                  action: { .patient($0) }))
            }
        }
    }
}
