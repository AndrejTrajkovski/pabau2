import SwiftUI
import Model
import ComposableArchitecture

extension FormType {
	var imageName: String {
		switch self {
		case .treatment: return "doc.text"
		case .prescription: return "doc.append"
		case .consent: return "signature"
		case .history: return ""
		}
	}
}

struct TreatmentsList: ClientCardChild {
	let store: Store<ClientCardChildState<[FormData]>, GotClientListAction<[FormData]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			FormsList(formType: .treatment, state: viewStore.state.state)
		}
	}
}

struct ConsentsList: ClientCardChild {
	let store: Store<ClientCardChildState<[FormData]>, GotClientListAction<[FormData]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			FormsList(formType: .consent, state: viewStore.state.state)
		}
	}
}

struct PrescriptionsList: ClientCardChild {
	let store: Store<ClientCardChildState<[FormData]>, GotClientListAction<[FormData]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			FormsList(formType: .prescription, state: viewStore.state.state)
		}
	}
}

struct FormsList: View {
	let formType: FormType
	var state: [FormData]
	var body: some View {
		List {
			ForEach(state.indices, id: \.self) { idx in
				FormsListRow(form: self.state[idx])
			}
		}
	}
}

struct FormsListRow: View {
	let form: FormData
	var body: some View {
		ClientCardItemBaseRow(title: form.template.name,
													date: form.date,
													image: Image(systemName: form.template.formType.imageName)
		)
	}
}
