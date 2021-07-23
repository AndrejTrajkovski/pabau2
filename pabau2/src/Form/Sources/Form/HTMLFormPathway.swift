import SwiftUI
import ComposableArchitecture
import Model

public struct HTMLFormPathway: View {
    
    let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
    public var body: some View {
        IfLetStore(store.scope(state: { $0.chosenForm },
                               action: { .chosenForm($0) }),
                   then: {
                    HTMLFormParent(store: $0,
                                   skipButton: {
                                    SkipButton(store: store.scope(state: { $0.canSkip },
                                                                  action: { .skipStep($0)}))
                                   })
                   }
        )
    }
}
