import ComposableArchitecture
import SwiftUI
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
    public var templates: [AftercareTemplate]
    public var selectedIds: Set<AftercareTemplate.ID> = []
    
    var rows: [AftercareOption] {
        get {
            self.templates.map {
                AftercareOption.init(template: $0,
                                     isSelected: selectedIds.contains($0.id))
            }
        }
        set {
            self.selectedIds = Set(newValue.filter(\.isSelected).map(\.id))
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
