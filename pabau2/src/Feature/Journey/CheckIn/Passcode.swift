import SwiftUI
import ComposableArchitecture
import Util

let validPasscodes: [[String]] = [
	["1", "2", "3", "4"],
	["5", "5", "5", "5"],
	["0", "0", "0", "0"],
	["2", "2", "5", "6"]
]

struct PasscodeState {
	var runningDigits: [String] = []
	var unlocked: Bool = false
}

enum PasscodeAction {
	case touchDigit(String)
	case deleteLast
}

struct Passcode: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	let viewStore: ViewStore<ViewState, CheckInMainAction>
	struct ViewState: Equatable {
		let isDoctorSummaryActive: Bool
	}
	init(store: Store<CheckInContainerState, CheckInMainAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: { _ in ViewState.init(isDoctorSummaryActive: store.view.value.isDoctorSummaryActive)},
			action: { $0 }).view
	}
	
	@State var passcodeState = PasscodeState()
	//animation does not work if wrong attempts is in passcodeState
	@State var wrongAttempts: Int = 0
	var body: some View {
		VStack(spacing: 32) {
			Image("ico-journey-locked").resizable().frame(width: 24, height: 36)
			Text(Texts.enterPass).font(.semibold20)
			HStack(spacing: 16) {
				ForEach(0..<4) { idx in
					DotView(isFilled: self.passcodeState.runningDigits.count > idx)
				}
			}
			.modifier(Shake(animatableData: CGFloat(wrongAttempts)))
			Digits(onTouch: onTouch(digit:))
			HStack {
				Text("Cancel")
				Spacer()
				Text("Delete").onTapGesture {
					self.passcodeReducer(&self.passcodeState, .deleteLast)
				}
			}
			.font(.regular16)
			NavigationLink.emptyHidden(self.passcodeState.unlocked,
				ChooseTreatmentNote(store:
					self.store.scope(
						value: { $0 },
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

	func onTouch(digit: String) {
		passcodeReducer(&self.passcodeState,
										.touchDigit(digit))
	}

	func passcodeReducer(_ state: inout PasscodeState, _ action: PasscodeAction) {
		switch action {
		case .touchDigit(let digit):
			handleTouch(digit: digit, state: &state)
		case .deleteLast:
			if !state.runningDigits.isEmpty { state.runningDigits.removeLast() }
		}
	}

	func handleTouch(digit: String, state: inout PasscodeState) {
		if state.runningDigits.count < 4 {
			state.runningDigits.append(digit)
		}
		if state.runningDigits.count == 4 {
			handleFourDigits(state: &state)
		}
	}

	func handleFourDigits(state: inout PasscodeState) {
		if validPasscodes.contains(state.runningDigits) {
			state.unlocked = true
		} else {
			state.runningDigits.removeAll()
			withAnimation(.default) {
				self.wrongAttempts += 1
			}
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
