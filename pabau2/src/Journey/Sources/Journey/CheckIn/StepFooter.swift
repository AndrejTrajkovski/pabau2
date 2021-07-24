import Model
import SwiftUI
import ComposableArchitecture
import Form

struct StepFooter: View {
    let canSkip: Bool
    let onSkip: () -> Void
    let canComplete: Bool
    let onComplete
    
    var body: some View {
        HStack {
            SkipButton(store: store.scope { $0.canSkip })
            
        }
    }
}
