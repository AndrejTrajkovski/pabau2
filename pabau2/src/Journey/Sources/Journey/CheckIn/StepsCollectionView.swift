import Util
import SwiftUI
import Model
import ComposableArchitecture
import Form

public enum StepsViewAction {
	case didSelectFlatFormIndex(Int)
	case didSelectNextStep
	case didSelectPrevStep
}

let stepsViewReducer = Reducer<Forms, StepsViewAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didSelectFlatFormIndex(let idx):
		state.flatSelectedIndex = idx
	case .didSelectNextStep:
		state.next()
	case .didSelectPrevStep:
		state.previous()
	}
	return .none
}

struct StepsCollectionView: View {
	let cellWidth: CGFloat = 100
	let cellHeight: CGFloat = 80
	let spacing: CGFloat = 8
	struct State: Equatable {
		let maxVisibleCells = 5
		let formVms: [FormVM]
		let selectedIndex: Int
		let numberOfVisibleSteps: Int
		let shouldShowLeftArrow: Bool
		let shouldShowRightArrow: Bool
	}

	let store: Store<Forms, StepsViewAction>
	@ObservedObject var viewStore: ViewStore<State, StepsViewAction>
	init (store: Store<Forms, StepsViewAction>) {
		self.store = store
		self.viewStore = ViewStore(
			store.scope( state: State.init(state:), action: { $0 }))
	}
	
	var body: some View {
		HStack(alignment: .top, spacing: 24) {
			if viewStore.state.shouldShowLeftArrow { previousArrow() }
			scrollView()
			if viewStore.state.shouldShowRightArrow { nextArrow() }
		}
	}
	
	fileprivate func scrollView() -> some View {
		ScrollViewReader { scrollProxy in
			ScrollView(.horizontal) {
				HStack(spacing: spacing) {
					ForEach(viewStore.state.formVms.indices, id: \.self) { idx in
						stepView(for: viewStore.state.formVms[idx])
							.frame(width: cellWidth, height: cellHeight)
							.onTapGesture {
								self.viewStore.send(.didSelectFlatFormIndex(idx))
								withAnimation {
									scrollProxy.scrollTo(idx, anchor: .center)
								}
							}
					}
				}
			}.frame(width: ((cellWidth + spacing) * CGFloat(viewStore.state.numberOfVisibleSteps)),
					height: cellHeight)
		}
	}
	
	func stepView(for viewModel: FormVM) -> some View {
		VStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(viewModel.isComplete ? .blue : Color(hex: "C7C7CC"))
				.frame(width: 30, height: 30)
			Text(viewModel.title.uppercased())
				.fixedSize(horizontal: false, vertical: true)
				.multilineTextAlignment(.center)
				.lineLimit(nil)
				.font(.medium10)
				.foregroundColor(Color(hex: "909090"))
		}
	}
	
	fileprivate func previousArrow() -> some View  {
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

extension StepsCollectionView.State {
	init(state: Forms) {
		let forms = state
		let selIdx = forms.flatSelectedIndex
		let flatForms = forms.flat
		let formVms = zip(flatForms, flatForms.indices).map { Self.formVm(form: $0, selection: selIdx)}
		let shouldShowArrows = formVms.count > maxVisibleCells
		self.formVms = formVms
		self.selectedIndex = selIdx
		self.numberOfVisibleSteps = min(formVms.count, maxVisibleCells)
		self.shouldShowLeftArrow = shouldShowArrows && (selIdx != 0)
		self.shouldShowRightArrow = shouldShowArrows && (selIdx != formVms.count - 1)
	}

	static func formVm(form: (MetaFormAndStatus, Int), selection: Int) -> FormVM {
		FormVM(id: form.1,
			   isComplete: form.0.isComplete,
			   title: form.0.form.title)
	}
}

struct FormVM: Identifiable, Equatable {
	let id: Int
	let isComplete: Bool
	let title: String
}
