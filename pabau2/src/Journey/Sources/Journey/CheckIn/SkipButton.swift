import SwiftUI
import ComposableArchitecture
import Model
import Util

struct SkipStepButton: View {
    let store: Store<StepState, StepAction>
    
    var body: some View {
        WithViewStore(store.scope(state: { $0.canSkip })) { viewStore in
            SkipButton(canSkip: viewStore.state,
                       onSkip: { viewStore.send(.skipStep) }
            )
        }
    }
}

struct SkipButton: View {
    
    let canSkip: Bool
    let onSkip: () -> Void
    
    var body: some View {
        Button(
            action: onSkip,
            label: {
                Text("Skip")
                    .font(Font.system(size: 16.0, weight: .bold))
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        )
        .buttonStyle(SkipButtonStyle(isDisabled: !canSkip))
        .disabled(!canSkip)
        .shadow(color: Color.bigBtnShadow1,
                radius: 4.0,
                y: 5
        )
        .cornerRadius(4)
    }
}
