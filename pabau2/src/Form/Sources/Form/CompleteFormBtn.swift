import SwiftUI
import ComposableArchitecture
import Util
import Model

public struct CompleteButton: View {
    public init(canComplete: Bool, onComplete: @escaping () -> Void) {
        self.canComplete = canComplete
        self.onComplete = onComplete
    }
    
    let canComplete: Bool
    let onComplete: () -> Void
    
    public var body: some View {
        PrimaryButton(Texts.complete,
                      isDisabled: !canComplete,
                      onComplete)
	}
}
