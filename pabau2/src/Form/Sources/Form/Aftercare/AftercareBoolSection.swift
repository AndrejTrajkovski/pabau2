import ComposableArchitecture
import SwiftUI
import ASCollectionView
import Util
import SharedComponents
import Model

public let aftercareBoolSectionReducer: Reducer<AftercareBoolSectionState, AftercareBoolAction, Any> = aftercareOptionReducer.forEach(
    state: \AftercareBoolSectionState.rows,
    action: /AftercareBoolAction.rows,
    environment: { $0 }
)

public enum AftercareBoolAction: Equatable {
    case rows(idx: Int, action: ToggleAction)
}

public struct AftercareBoolSectionState: Equatable {
    let templates: [AftercareTemplate]
    var selectedId: AftercareTemplate.ID? = nil
    
    var rows: [AftercareOption] {
        get {
            self.templates.map {
                AftercareOption.init(template: $0, isSelected: selectedId == $0.id)
            }
        }
        set {
            self.selectedId = newValue.first(where: { $0.isSelected == true})?.id
        }
    }
}

struct AftercareBoolSection: View {
    
    let title: String
    let desc: String
    let store: Store<AftercareBoolSectionState, AftercareBoolAction>
    
    var body: some View {
        Section(header: AftercareBoolHeader(title: title, desc: desc)) {
            ForEachStore(store.scope(state: { $0.rows }, action: AftercareBoolAction.rows(idx:action:)),
                         content: AftercareCell.init(store:)
            )
        }
    }
}

struct AftercareBoolHeader: View {

	let title: String
	let desc: String
	var body: some View {
		VStack(alignment: .leading, spacing: 24) {
			Text(title)
				.font(.bold24)
			Text(desc).font(.regular18)
				.multilineTextAlignment(.leading)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
	}
}
