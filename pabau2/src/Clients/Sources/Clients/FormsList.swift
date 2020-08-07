import SwiftUI
import Model

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
	var state: [FormData]
	var body: some View {
		FormsList(formType: .treatment, state: state)
	}
}

struct ConsentsList: ClientCardChild {
	var state: [FormData]
	var body: some View {
		FormsList(formType: .consent, state: state)
	}
}

struct PrescriptionsList: ClientCardChild {
	var state: [FormData]
	var body: some View {
		FormsList(formType: .prescription, state: state)
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
