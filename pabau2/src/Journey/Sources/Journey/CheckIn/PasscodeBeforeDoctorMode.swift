import SwiftUI
import ComposableArchitecture
import Util

let validPasscodes: [[String]] = [
	["1", "2", "3", "4"],
	["5", "5", "5", "5"],
	["0", "0", "0", "0"],
	["2", "2", "5", "6"]
]

public struct PasscodeContainerState: Equatable {
	var passcode: PasscodeState
	var isDoctorCheckInMainActive: Bool
}

public struct PasscodeState: Equatable {
	var runningDigits: [String] = []
	var unlocked: Bool = false
	var wrongAttempts: Int = 0
}

public enum PasscodeAction: Equatable {
	case touchDigit(String)
	case deleteLast
    case onCancel
}

let passcodeOptReducer: Reducer<PasscodeState?, PasscodeAction, Any> = .combine(
    
    passcodeReducer.optional().pullback(
        state: \PasscodeState.self,
        action: /PasscodeAction.self,
        environment: { $0 }
    ),
    
    Reducer.init { state, action, _ in
        
        if case PasscodeAction.onCancel = action {
            state = nil
        }
        
        return .none
    }
)

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
    case .onCancel:
        break
    }
	return .none
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

struct PasscodeBeforeDoctorMode: View {
    let store: Store<CheckInLoadedState, CheckInLoadedAction>
    @ObservedObject var viewStore: ViewStore<State, Never>
    
    init(store: Store<CheckInLoadedState, CheckInLoadedAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: State.init(state:)).actionless)
    }
    
    struct State: Equatable {
        let isDoctorCheckInActive: Bool
        init(state: CheckInLoadedState) {
            self.isDoctorCheckInActive = (state.passcodeForDoctorMode?.unlocked ?? false) == true
        }
    }
    
    var body: some View {
        passcode
        doctorCheckInNavigationLink
    }
    
    var passcode: some View {
        IfLetStore(store.scope(state: { $0.passcodeForDoctorMode },
                               action: { .passcodeForDoctorMode($0) }),
                   then: Passcode.init(store:))
    }
    
    var doctorCheckInNavigationLink: some View {
        NavigationLink.emptyHidden(viewStore.state.isDoctorCheckInActive,
                                   doctorCheckIn
        )
    }
    
    var doctorCheckIn: some View {
        IfLetStore(store.scope(state: { $0.doctorCheckIn },
                               action: { .doctor($0) }),
                   then: CheckInPathway.init(store:))
    }
}
