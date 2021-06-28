import SwiftUI
import ComposableArchitecture
import Util

struct Passcode: View {
	
	let store: Store<PasscodeContainerState, PasscodeAction>
	
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 32) {
				Image("ico-journey-locked").resizable().frame(width: 24, height: 36)
				Text(Texts.enterPass).font(.semibold20)
				HStack(spacing: 16) {
					ForEach(0..<4) { idx in
						DotView(isFilled: viewStore.state.passcode.runningDigits.count > idx)
					}
				}
				.modifier(Shake(animatableData:
									CGFloat(viewStore.state.passcode.wrongAttempts)))
				Digits(onTouch: { viewStore.send(.touchDigit($0)) })
				HStack {
					Text("Cancel")
					Spacer()
					Text("Delete").onTapGesture {
						viewStore.send(.deleteLast)
					}
				}
				.font(.regular16)
			}
			.foregroundColor(.white)
			.fixedSize(horizontal: true, vertical: false)
			.gradientView()
		}
	}
}
