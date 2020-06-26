import SwiftUI
import ComposableArchitecture

struct ActiveInjectableState: Equatable {
	var photoInjections: [Injection]
	var chosenIncrement: Double
	var chosenInjectable: Injectable
}

enum ActiveInjectableAction: Equatable{
	case increment
	case decrement
}

struct ActiveInjectable: View {
	let store: Store<ActiveInjectableState, ActiveInjectableAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				ActiveInjectableTop(store: self.store.scope(state: { $0 },
																										action: { $0 }))
				Spacer()
				HStack {
					Button(action: { viewStore.send(.decrement) },
								 label: { Image(systemName: "minus.rectangle.fill") })
					Text("").font(.regular17)
					Button(action: { viewStore.send(.increment )},
								 label: { Image(systemName: "plus.rectangle.fill") })
				}
			}
		}
	}
}

struct ActiveInjectableTop: View {
	let store: Store<ActiveInjectableState, ActiveInjectableAction>
	
	struct State: Equatable {
		let color: Color
		let injTitle: String
		let desc: String
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				HStack {
					Circle()
						.fill(viewStore.state.color)
						.frame(width: 10, height: 10)
					Text(viewStore.state.injTitle).font(.medium16)
				}
				Text(viewStore.state.desc)
			}
		}
	}
}

extension ActiveInjectableTop.State {
  init(state: ActiveInjectableState) {
		self.color = state.chosenInjectable.color
		self.injTitle = state.chosenInjectable.title
		let total = state.photoInjections.filter {
			$0.injectable == state.chosenInjectable
		}.reduce(into: TotalInjAndUnits.init(), { res, element in
			res.totalUnits += element.units
			res.totalInj += 1
		})
		self.desc = "Selection: \(total.totalInj) injections - \(total.totalUnits)"
	}
}
