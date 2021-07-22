import SwiftUI
import ComposableArchitecture
import Model
import Util

public struct SkipStepAction: Equatable { }

public struct SkipButton: View {
    
    public init(store: Store<Bool, SkipStepAction>) {
        self.store = store
    }
    
    let store: Store<Bool, SkipStepAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: { viewStore.send(SkipStepAction()) },
                label: {
                    Text("Skip")
                        .font(Font.system(size: 16.0, weight: .bold))
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            )
            .buttonStyle(SkipButtonStyle(isDisabled: !viewStore.state))
            .disabled(!viewStore.state)
            .shadow(color: Color.bigBtnShadow1,
                    radius: 4.0,
                    y: 5
            )
            .cornerRadius(4)
        }
    }
}
