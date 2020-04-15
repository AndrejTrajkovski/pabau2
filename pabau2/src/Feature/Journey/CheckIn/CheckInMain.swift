import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case closeBtnTap
}

func checkInMainReducer(state: inout CheckInContainerState,
												action: CheckInMainAction,
												environment: JourneyEnvironemnt) -> [Effect<CheckInMainAction>] {
	switch action {
	case .closeBtnTap:
		return []
//		state.isCheckedIn = false
//		state.pathway = nil
//		state.journey = nil
	}
	return []
}

struct CheckInMain: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, CheckInMainAction>
	@State var selectedStep: Int

	init(store: Store<CheckInContainerState, CheckInMainAction>) {
		self.store = store
		let viewStore = self.store.view
		self.viewStore = viewStore
		self._selectedStep = State.init(initialValue: viewStore.value.pathway.steps.first!.id)
	}

	var body: some View {
		print("check in main body")
		return VStack (alignment: .center, spacing: 0) {
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
			StepsCollectionView(steps: self.viewStore.value.pathway.steps,
													selectionId: $selectedStep)
				.frame(width: 600, alignment: .center)
			Spacer()
//			List {
//				ForEach(self.viewStore.value.listServices, id: \.self.first?.categoryId) { (group: [Service]) in
//					Section(header:
//						ServicesHeader(name: group.first?.categoryName ?? "No name")
//					) {
//						ForEach(group, id: \.self) { (service: Service) in
//							ServiceRow(service: service).onTapGesture {
//								self.viewStore.send(.didSelectServiceId(service.id))
//							}
//						}
//					}.background(Color.white)
//				}
//			}
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}
