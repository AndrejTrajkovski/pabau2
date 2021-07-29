import SwiftUI
import Model
import ComposableArchitecture
import SharedComponents
import Model
import Util

struct AftercareCell: View {
    
    let store: Store<AftercareOption, ToggleAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Image(systemName: viewStore.template.template_type == .sms ? "message.circle" : "envelope.circle")
                        .resizable()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.accentColor)
                    Text(viewStore.state.template.template_name).font(.body)
                    Toggle(isOn: viewStore.binding( get: { $0.isSelected },
                                                    send: { .setTo($0)}), label: { EmptyView() })
                }.padding([.leading, .trailing])
                Divider()
            }
        }
    }
}

public let aftercareOptionReducer: Reducer<AftercareOption, ToggleAction, Any> = (
    switchCellReducer.pullback(
        state: \AftercareOption.isSelected,
        action: /ToggleAction.self,
        environment: { $0 })
)

public struct AftercareOption: Identifiable, Equatable {
    public init(template: AftercareTemplate, isSelected: Bool = false) {
        self.template = template
        self.isSelected = isSelected
    }
    
    let template: AftercareTemplate
    var isSelected: Bool = false
    public var id: AftercareTemplate.ID { return template.id }
}
