import SwiftUI
import ComposableArchitecture
import Util

let validPasscodes: [[String]] = [
	["1", "2", "3", "4"],
	["5", "5", "5", "5"],
	["0", "0", "0", "0"],
	["2", "2", "5", "6"]
]

public struct PasscodeState: Equatable {
	var runningDigits: [String]
	var unlocked: Bool
	var isDoctorSummaryActive: Bool
	var wrongAttempts: Int
}

public enum PasscodeAction {
	case touchDigit(String)
	case deleteLast
}

let passcodeReducer = Reducer<PasscodeState, PasscodeAction, Any> { state, action, _ in
	switch action {
	case .touchDigit(let digit):
		if state.runningDigits.count < 4 {
			state.runningDigits.append(digit)
		}
		if state.runningDigits.count == 4 {
			if validPasscodes.contains(state.runningDigits) {
				state.unlocked = true
			} else {
				state.runningDigits.removeAll()
				withAnimation(.default) {
					state.wrongAttempts += 1
				}
			}
		}
	case .deleteLast:
		if !state.runningDigits.isEmpty { state.runningDigits.removeLast() }
	}
	return .none
}

struct Passcode: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	
	var body: some View {
		WithViewStore(self.store.scope(state: { $0.passcode },
																	 action: { .passcode($0)})) { viewStore in
			VStack(spacing: 32) {
				Image("ico-journey-locked").resizable().frame(width: 24, height: 36)
				Text(Texts.enterPass).font(.semibold20)
				HStack(spacing: 16) {
					ForEach(0..<4) { idx in
						DotView(isFilled: viewStore.state.runningDigits.count > idx)
					}
				}
				.modifier(Shake(animatableData: CGFloat(viewStore.state.wrongAttempts)))
				Digits(onTouch: { viewStore.send(.touchDigit($0)) })
				HStack {
					Text("Cancel")
					Spacer()
					Text("Delete").onTapGesture {
						viewStore.send(.deleteLast)
					}
				}
				.font(.regular16)
				NavigationLink.emptyHidden(viewStore.state.unlocked,
																	 ChooseTreatmentNote(store:
																		self.store.scope(
																			state: { $0 },
																			action: { $0 }))
																		.navigationBarHidden(false)
																		.navigationBarTitle("Choose Tretment Note", displayMode: .inline)
																		.navigationBarBackButtonHidden(true)
				)
			}
			.foregroundColor(.white)
			.fixedSize(horizontal: true, vertical: false)
			.gradientView()
		}
	}
}

struct DotView: View {
	let isFilled: Bool
	var body: some View {
		Circle()
		.overlay(
				Circle()
			 .stroke(Color.white, lineWidth: 1)
			).foregroundColor(isFilled ? Color.white : .clear)
		.frame(width: 13, height: 13)
	}
}

struct Digits: View {
	let onTouch: (String) -> Void
	var body: some View {
		VStack {
			ThreeDigits(digits: ["1", "2", "3"], onTouch: onTouch)
			ThreeDigits(digits: ["4", "5", "6"], onTouch: onTouch)
			ThreeDigits(digits: ["7", "8", "9"], onTouch: onTouch)
			DigitButton(digit: "0", onTouch: onTouch)
		}
	}
}

struct ThreeDigits: View {
	let digits: [String]
	let onTouch: (String) -> Void
	var body: some View {
		HStack(spacing: 16) {
			DigitButton(digit: digits[0], onTouch: onTouch)
			DigitButton(digit: digits[1], onTouch: onTouch)
			DigitButton(digit: digits[2], onTouch: onTouch)
		}
	}
}

struct DigitButton: View {
	let digit: String
	let onTouch: (String) -> Void
	var body: some View {
		ZStack {
			Circle().fill(Color.white.opacity(0.2))
			Text(digit)
				.foregroundColor(.white)
				.font(.regular36)
		}.frame(width: 75, height: 75)
			.onTapGesture {
				self.onTouch(self.digit)
		}
	}
}

struct Shake: GeometryEffect {
	var amount: CGFloat = 10
	var shakesPerUnit = 3
	var animatableData: CGFloat
	
	func effectValue(size: CGSize) -> ProjectionTransform {
		ProjectionTransform(CGAffineTransform(translationX:
			amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
																					y: 0))
	}
}
