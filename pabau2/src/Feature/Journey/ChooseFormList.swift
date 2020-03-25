import SwiftUI
import Model
import Util
import ComposableArchitecture

public struct ChooseFormState: Equatable {
	let journey: Journey
	let templates: [FormTemplate] = [
		FormTemplate(id: 1, name: "Consent - Hair Extension", formType: .consent),
		FormTemplate(id: 2, name: "Consent - Botox", formType: .consent),
		FormTemplate(id: 3, name: "Consent - Fillers", formType: .consent),
		FormTemplate(id: 4, name: "Consent - Pedicure", formType: .consent),
		FormTemplate(id: 5, name: "Consent - Manicure", formType: .consent),
		FormTemplate(id: 6, name: "Consent - Skin Treatment", formType: .consent),
		FormTemplate(id: 7, name: "Consent - Lipo", formType: .consent)
	]
	let selectedTemplatesIds: [Int] = [1, 2, 3]
	
	var notSelectedTemplates: [FormTemplate] {
		templates.filter { !selectedTemplatesIds.contains($0.id) }
	}
	var selectedTemplates: [FormTemplate] {
		templates.filter { selectedTemplatesIds.contains($0.id) }
	}
}

public enum ChooseFormAction {
	
}

func chooseFormListReducer(state: ChooseFormState,
													 action: ChooseFormAction,
													 environment: JourneyEnvironemnt) -> [Effect<ChooseFormAction>] {
	return []
}

struct ChooseFormList: View {
	let store: Store<ChooseFormState, ChooseFormAction>
	@ObservedObject var viewStore: ViewStore<ChooseFormState>
	init (store: Store<ChooseFormState, ChooseFormAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	
	@State var searchText: String = ""
	
	var body: some View {
		JourneyBaseView(journey: self.viewStore.value.journey) {
			HStack {
				PathwayCell(style: .blue) {
					VStack {
						FormTemplateList(templates: self.viewStore.value.selectedTemplates,
														 templateRow: { template in
															SelectedTemplateRow(template: template)
						})
						ChoosePathwayButton(btnTxt: "Check-In", style: .blue, action: {
							
						})
					}
				}
				PathwayCell(style: .white) {
					TextField("search", text: self.$searchText)
					VStack {
						FormTemplateList(templates: self.viewStore.value.notSelectedTemplates,
														 templateRow: { template in
															NotSelectedTemplateRow(template: template)
						})
					}
				}
			}
		}
	}
}

struct FormTemplateList<Row: View>: View {
	let templates: [FormTemplate]
	let templateRow: (FormTemplate) -> Row
	init (templates: [FormTemplate],
				@ViewBuilder templateRow: @escaping (FormTemplate) -> Row) {
		self.templates = templates
		self.templateRow = templateRow
	}
	var body: some View {
		Form {
			List {
				Section(header: Text("Selected Consents")) {
					ForEach(templates) { template in
						self.templateRow(template)
					}
				}
			}
		}
//		.background(Color.employeeBg)
	}
}

struct NotSelectedTemplateRow: View {
	let template: FormTemplate
	var body: some View {
		TemplateRow.init(templateName: template.name,
										 image: Image(systemName: "plus"))
	}
}

struct SelectedTemplateRow: View {
	let template: FormTemplate
	var body: some View {
		TemplateRow.init(templateName: template.name,
										 image: Image(systemName: "checkmark.circle.fill"))
	}
}

struct TemplateRow: View {
	let templateName: String
	let image: Image
	var body: some View {
		HStack {
			Text(templateName)
				.font(Font.regular17)
			image
				.foregroundColor(Color.blue2)
		}
	}
}
