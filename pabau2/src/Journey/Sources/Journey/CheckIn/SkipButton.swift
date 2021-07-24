import SwiftUI
import ComposableArchitecture
import Model
import Util

public struct SkipButton: View {
    
    let canSkip: Bool
    let onSkip: () -> Void
    
    public var body: some View {
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
