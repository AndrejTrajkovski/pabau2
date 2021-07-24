import SwiftUI
import ComposableArchitecture
import Model

public struct HTMLFormPathway: View {
    
    let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
    public var body: some View {
        HTMLFormParent(store: store.scope(state: { $0.chosenForm! },
                                          action: { .chosenForm($0) }),
                       footer: {
                        
                       })
    }
}
