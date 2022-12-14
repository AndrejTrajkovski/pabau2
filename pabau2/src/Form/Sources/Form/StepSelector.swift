import Util
import SwiftUI
import Model
import ComposableArchitecture

struct StepSelector: View {
	let cellWidth: CGFloat = 120
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8

	struct State: Equatable {
		let maxVisibleCells = 5
		let stepForms: [StepFormInfo]
		let selectedIndex: Int
		let numberOfVisibleSteps: Int
		let shouldShowLeftArrow: Bool
		let shouldShowRightArrow: Bool
	}

	let store: Store<CheckInState, CheckInAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInAction>

	init (store: Store<CheckInState, CheckInAction>) {
		self.store = store
		self.viewStore = ViewStore(
			store.scope(state: State.init(state:), action: { $0 }))
	}

	var body: some View {
		HStack(alignment: .top, spacing: 24) {
			if viewStore.state.shouldShowLeftArrow { previousArrow() }
			scrollView()
			if viewStore.state.shouldShowRightArrow { nextArrow() }
		}
	}

	fileprivate func scrollView() -> some View {
		ScrollViewReader { _ in
			ScrollView(.horizontal) {
				HStack(spacing: spacing) {
					ForEach(viewStore.state.stepForms.indices, id: \.self) { idx in
                        stepView(for: viewStore.state.stepForms[idx], viewStore.selectedIndex == idx)
							.frame(width: cellWidth, height: cellHeight)
							.onTapGesture {
								self.viewStore.send(.didSelectFlatFormIndex(idx))
							}
					}
				}
//				.onReceive(viewStore.publisher.selectedIndex,
//							perform: { idx in
//								withAnimation {
//									scrollProxy.scrollTo(idx, anchor: .center)
//								}
//							})
			}.frame(width: ((cellWidth + spacing) * CGFloat(viewStore.state.numberOfVisibleSteps)),
					height: cellHeight)
		}
	}

    func stepView(for viewModel: StepFormInfo, _ isSelected: Bool) -> some View {
		VStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(color(status: viewModel.status))
				.frame(width: 30, height: 30)
			Text(viewModel.title.uppercased())
				.fixedSize(horizontal: false, vertical: true)
				.multilineTextAlignment(.center)
				.lineLimit(nil)
				.font(.medium10)
				.foregroundColor(Color(hex: "909090"))
        }
        .padding(10)
        .border(isSelected ? Color.lightBlueGrey : Color.clear, width: isSelected ? 1 : 0)
	}

	fileprivate func color(status: StepStatus) -> Color {
		switch status {
		case .completed:
			return Color.blue
		case .pending:
			return Color(hex: "C7C7CC")
		case .skipped:
			return Color.yellow
		}
	}
	
	fileprivate func previousArrow() -> some View {
		Image(systemName: "chevron.left")
			.font(.regular30).foregroundColor(Color(hex: "909090"))
			.onTapGesture {
				self.viewStore.send(.didSelectPrevStep)
			}
	}

	fileprivate func nextArrow() -> some View {
		Image(systemName: "chevron.right")
			.font(.regular30).foregroundColor(Color(hex: "909090"))
			.onTapGesture {
				self.viewStore.send(.didSelectNextStep)
			}
	}
}

extension StepSelector.State {
	init(state: CheckInState) {
//		let stepForms = zip(state.forms, state.forms.indices).map {
//			StepFormInfo(isComplete: $0.0.isComplete,
//								title: $0.0.form.title)
//		}
		let stepForms = state.stepForms
		let shouldShowArrows = stepForms.count > maxVisibleCells
		self.selectedIndex = state.selectedIdx
		self.numberOfVisibleSteps = min(stepForms.count, maxVisibleCells)
		self.shouldShowLeftArrow = shouldShowArrows && (state.selectedIdx != 0)
		self.shouldShowRightArrow = shouldShowArrows && (state.selectedIdx != stepForms.count - 1)
		self.stepForms = stepForms
	}
}
