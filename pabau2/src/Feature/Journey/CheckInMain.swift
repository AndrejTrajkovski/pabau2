import SwiftUI
import Model
import ComposableArchitecture
import CollectionUI

public struct CheckInMainState: Equatable {
	var isCheckedIn: Bool
	var journey: Journey?
	var pathway: Pathway?
	var consents: [FormTemplate]
}

public enum CheckInMainAction {
	case closeBtnTap
}

func checkInMainReducer(state: inout CheckInMainState,
												action: CheckInMainAction,
												environment: JourneyEnvironemnt) -> [Effect<CheckInMainAction>] {
	switch action {
	case .closeBtnTap:
		state.isCheckedIn = false
		state.pathway = nil
		state.journey = nil
	}
	return []
}

struct CheckInMain: View {
	let store: Store<CheckInMainState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInMainState, CheckInMainAction>
	@State var selectedStep: Int
	init(store: Store<CheckInMainState, CheckInMainAction>) {
		self.store = store
		let viewStore = self.store.view
		self.viewStore = viewStore
		self._selectedStep = State.init(initialValue: viewStore.value.pathway!.steps.first!.id)
	}

	var body: some View {
		VStack (alignment: .center, spacing: 0) {
			ZStack {
				Button.init(action: { self.viewStore.send(.closeBtnTap) }, label: {
					Image(systemName: "xmark")
						.font(Font.light30)
						.foregroundColor(.gray142)
						.frame(width: 30, height: 30)
				})
					.padding()
					.frame(minWidth: 0, maxWidth: .infinity,
								 minHeight: 0, maxHeight: .infinity,
								 alignment: .topLeading)
				Spacer()
				JourneyProfileView(style: .short,
													 viewState: .init(journey: self.viewStore.value.journey))
					.padding()
					.frame(minWidth: 0, maxWidth: .infinity,
								 minHeight: 0, maxHeight: .infinity,
								 alignment: .top)
				Spacer()
				RibbonView(completedNumberOfSteps: 1, totalNumberOfSteps: 4)
					.offset(x: -80, y: -60)
					.frame(minWidth: 0, maxWidth: .infinity,
								 minHeight: 0, maxHeight: .infinity,
								 alignment: .topTrailing)
			}.frame(height: 168.0)
			Group {
				if self.viewStore.value.pathway != nil {
					StepsCollectionView(steps: self.viewStore.value.pathway!.steps,
															selectionId: $selectedStep)
				} else {
					EmptyView()
				}
			}
		.frame(width: 600, alignment: .center)
			Spacer()
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}

struct RibbonView: View {
	let completedNumberOfSteps: Int
	let totalNumberOfSteps: Int

	private let lineWidth: CGFloat = 1
	var body: some View {
		ZStack(alignment: .bottom) {
			RoundedRectangle(cornerRadius: 36.5)
				.stroke(Color(hex: "979797"), lineWidth: lineWidth)
				.overlay(
					RoundedRectangle(cornerRadius: 36.5)
						.fill(Color.deepSkyBlue)
						.shadow(color: Color(hex: "007AFF"), radius: 1, x: 0, y: 5)
			)
				.padding(lineWidth)
			Text("\(completedNumberOfSteps)/\(totalNumberOfSteps)")
				.foregroundColor(.white)
				.font(.bold18)
				.alignmentGuide(.bottom, computeValue: { dim in dim[.bottom] + 24 })
		}
			.frame(width: 73, height: 168)
	}
}
