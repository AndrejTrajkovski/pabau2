import ComposableArchitecture
import SwiftUI
import Model
import Util

struct MultipleHTMLForms: View {
    
    let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
    var body: some View {
        IfLetStore(store.scope(state: { $0.choosingForm }, action: { .choosingForm($0) }),
                   then: ChooseForm.init(store:),
                   else: {
                    chosenForm
                   }
        )
    }
    
    var chosenForm: some View {
        IfLetStore(store.scope(state: { $0.chosenForm }, action: { .chosenForm($0)}),
                   then: HTMLFormParent.init(store:),
                   else: { ChooseFormButton.init(store: store.stateless) }
        )
    }
}

public enum ChoosingFormAction: Equatable {
    case cancelChoosingForm
    case chooseForm(id: HTMLForm.ID, action: ChooseHTMLFormAction)
    case confirmChoice
}

struct ChooseFormButton: View {
    let store: Store<Void, HTMLFormStepContainerAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryButton.init("Choose a different form.") {
                viewStore.send(.switchToChoosingForm )
            }
        }
    }
}

public struct ChoosingFormState: Equatable {
    let possibleFormTemplates: IdentifiedArrayOf<FormTemplateInfo>
    var tempChosenFormId: FormTemplateInfo.ID?
    
    var selectFormRows: IdentifiedArrayOf<SelectFormRowState> {
        get {
            let mapped = possibleFormTemplates.map { SelectFormRowState.init(isSelected: $0.id == tempChosenFormId , form: $0) }
            return IdentifiedArrayOf<SelectFormRowState>.init(uniqueElements: mapped)
        }
        set {
            self.tempChosenFormId = newValue.first(where: { $0.isSelected == true })?.id
        }
    }
}

public enum ChooseHTMLFormAction: Equatable {
    case choose
}

struct ChooseForm: View {
    let store: Store<ChoosingFormState, ChoosingFormAction>
    
    var body: some View {
        VStack {
            Text("The service booked relates to multiple forms. Please pick the one to use.")
            ScrollView {
                LazyVStack {
                    ForEachStore(store.scope(state: { $0.selectFormRows },
                                             action: ChoosingFormAction.chooseForm(id:action:)),
                                 content: SelectFormRow.init(store:))
                }
                ConfirmChoice(store: store.stateless)
            }
            Spacer()
        }
    }
}

struct ConfirmChoice: View {
    let store: Store<Void, ChoosingFormAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryButton.init("Select form") {
                viewStore.send(.confirmChoice )
            }
        }
    }
}

struct SelectFormRowState: Equatable, Identifiable {
    var id: FormTemplateInfo.ID { form.id }
    let isSelected: Bool
    let form: FormTemplateInfo
}

struct SelectFormRow: View {
    
    let store: Store<SelectFormRowState, ChooseHTMLFormAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            SelectRow(title: viewStore.state.form.name,
                      isSelected: viewStore.state.isSelected)
                .onTapGesture {
                    viewStore.send(.choose)
                }
        }
    }
}
