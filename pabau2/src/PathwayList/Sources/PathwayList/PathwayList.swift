import SwiftUI
import ComposableArchitecture
import Model
import Util

public enum PathwayListAction: Equatable {
	case rows(id: PathwayInfo.ID, action: PathwayInfoRowAction)
	case addNew
}

public struct PathwayList: View {
	
	public init(store: Store<Appointment, PathwayListAction>) {
		self.store = store
	}
	
	let store: Store<Appointment, PathwayListAction>
	
	public var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				ScrollView {
					LazyVStack {
						ForEachStore(store.scope(state: { $0.pathways },
												 action: PathwayListAction.rows(id:action:)),
									 content: PathwayInfoRow.init(store:))
					}
				}
				PrimaryButton(Texts.startPathway){
					viewStore.send(.addNew )
					
				}
					.fixedSize()
					.padding()
			}
			//			.journeyBase(viewStore.state, .long)
		}
	}
}
