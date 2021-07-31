import SwiftUI
import ComposableArchitecture
import Model

public struct HTMLFormPathway: View {
    
    let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
    public var body: some View {
        IfLetStore(store.scope(state: { $0.chosenForm }, action: { .chosenForm($0)}),
                   then: { formStore in HTMLFormParent.init(store: formStore, footer: { }) },
                   else: Text("problem")
        )
    }
}
