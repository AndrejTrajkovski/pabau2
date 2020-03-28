import SwiftUI
import Model
import Util
import ComposableArchitecture

public struct ChooseFormState: Equatable {
	var isJourneyModalShown: Bool
	var journey: Journey?
	var templates: [FormTemplate]
	var selectedTemplatesIds: [Int]

	var notSelectedTemplates: [FormTemplate] {
		templates.filter { !selectedTemplatesIds.contains($0.id) }
	}
	var selectedTemplates: [FormTemplate] {
		templates.filter { selectedTemplatesIds.contains($0.id) }
	}
}

public enum ChooseFormAction {
	case addTemplateId(Int)
	case removeTemplateId(Int)
	case checkIn
}

func chooseFormListReducer(state: inout ChooseFormState,
													 action: ChooseFormAction,
													 environment: JourneyEnvironemnt) -> [Effect<ChooseFormAction>] {
	switch action {
	case .addTemplateId(let templateId):
		state.selectedTemplatesIds.append(templateId)
	case .removeTemplateId(let templateId):
		state.selectedTemplatesIds.removeAll(where: { $0 == templateId})
	case .checkIn:
		state.isJourneyModalShown = true
	}
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
		chooseFormCells
			.journeyBase(self.viewStore.value.journey)
	}

	var chooseFormCells: some View {
		HStack {
			PathwayCell(style: .blue) {
				VStack(alignment: .leading) {
					Text("Selected Consents")
						.font(.bold17)
					FormTemplateList(templates: self.viewStore.value.selectedTemplates,
													 bgColor: PathwayCellStyle.blue.bgColor,
													 templateRow: { template in
														SelectedTemplateRow(template: template)
					}, onSelect: {
						self.store.send(.removeTemplateId($0.id))
					})
					ChoosePathwayButton(btnTxt: "Check-In", style: .blue, action: {
						withAnimation(Animation.linear(duration: 1)) {
							self.store.send(.checkIn)
						}
					})
				}
			}
			PathwayCell(style: .white) {
				VStack {
					TextField("TODO: search: ", text: self.$searchText)
					FormTemplateList(templates: self.viewStore.value.notSelectedTemplates,
													 bgColor: PathwayCellStyle.white.bgColor,
													 templateRow: { template in
														NotSelectedTemplateRow(template: template)
					}, onSelect: {
						self.store.send(.addTemplateId($0.id))
					})
				}
			}
		}
	}
}

struct FormTemplateList<Row: View>: View {
	let templates: [FormTemplate]
	let templateRow: (FormTemplate) -> Row
	let onSelect: (FormTemplate) -> Void
	let bgColor: Color

	init (templates: [FormTemplate],
				bgColor: Color,
				@ViewBuilder templateRow: @escaping (FormTemplate) -> Row,
										 onSelect: @escaping (FormTemplate) -> Void
										 ) {
		self.templates = templates
		self.templateRow = templateRow
		self.onSelect = onSelect
		self.bgColor = bgColor
	}
	var body: some View {
		List {
			ForEach(templates) { template in
				self.templateRow(template)
					.listRowInsets(EdgeInsets())
					.listRowBackground(self.bgColor)
					.onTapGesture { self.onSelect(template) }
			}
		}
	}
}

struct NotSelectedTemplateRow: View {
	let template: FormTemplate
	var body: some View {
		TemplateRow.init(templateName: template.name,
										 image: Image(systemName: "plus")
		)
	}
}

struct SelectedTemplateRow: View {
	let template: FormTemplate
	var body: some View {
		TemplateRow.init(templateName: template.name,
										 image: Image(systemName: "checkmark.circle.fill")
		)
	}
}

struct TemplateRow: View {
	let templateName: String
	let image: Image
	var body: some View {
		HStack {
			Text(templateName)
				.font(Font.regular17)
			Spacer()
			image
				.foregroundColor(Color.blue2)
		}
	}
}
