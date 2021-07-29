import SwiftUI
import Util
import ComposableArchitecture

struct HandBackDevice: View {
	let store: Store<CheckInLoadedState, CheckInLoadedAction>
    @ObservedObject var viewStore: ViewStore<State, CheckInLoadedAction>
    
    init(store: Store<CheckInLoadedState, CheckInLoadedAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)))
    }
    
    struct State: Equatable {
        var isEnterPasscodeActive: Bool
        init(state: CheckInLoadedState) {
            self.isEnterPasscodeActive = state.passcodeForDoctorMode != nil
        }
    }
    
    var body: some View {
        VStack {
            JourneyTransitionView(title: Texts.handBackTitle,
                                  description: Texts.handBackDesc,
                                  content: {
                                    Image("gfx-illustration-handback")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 250, height: 250)
                                        .offset(x: -30)
                                  })
                .gradientView().onTapGesture {
                    viewStore.send(.didTouchHandbackDevice)
                }
            NavigationLink.emptyHidden(viewStore.state.isEnterPasscodeActive,
                                       PasscodeBeforeDoctorMode(store: store)
                                        .navigationBarHidden(true)
                                        .navigationBarTitle("")
                                       //have to enable nav bar on choose treatment
            )
        }
	}
}
