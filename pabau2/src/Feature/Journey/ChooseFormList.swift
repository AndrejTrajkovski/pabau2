import SwiftUI
import Model
import Util
import ComposableArchitecture

public struct ChooseFormState: Equatable {
	var selectedJourney: Journey?
	var selectedPathway: Pathway?
	var selectedTemplatesIds: [Int]
	var templates: [FormTemplate]
	var isCheckedIn: Bool
	var templatesLoadingState: LoadingState = .initial
}

public enum ChooseFormAction {
	case addTemplateId(Int)
	case removeTemplateId(Int)
	case checkIn
	case gotResponse(Result<[FormTemplate], RequestError>)
	case onAppear
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
		state.isCheckedIn = true
	case .gotResponse(let result):
		switch result {
		case .success(let templates):
			state.templates = templates
			state.selectedTemplatesIds = []
			state.templatesLoadingState = .gotSuccess
		case .failure:
			state.templatesLoadingState = .gotError
		}
	case .onAppear:
		return [environment.apiClient.getTemplates(.consent)
			.map(ChooseFormAction.gotResponse)
			.eraseToEffect()]
	}
	return []
}

struct ChooseFormList: View {
	let store: Store<ChooseFormState, ChooseFormAction>
	@ObservedObject var viewStore: ViewStore<ViewState, ChooseFormAction>
	@State var searchText: String = ""
	init (store: Store<ChooseFormState, ChooseFormAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: ChooseFormList.ViewState.init,
						 action: { $0 })
			.view
		UITableView.appearance().separatorStyle = .none
	}

	struct ViewState: Equatable {
		let templates: [FormTemplate]
		var selectedTemplatesIds: [Int]
		init(state: ChooseFormState) {
			self.templates = state.templates
			self.selectedTemplatesIds = state.selectedTemplatesIds
		}
		var notSelectedTemplates: [FormTemplate] {
			templates.filter { !selectedTemplatesIds.contains($0.id) }
		}
		var selectedTemplates: [FormTemplate] {
			templates.filter { selectedTemplatesIds.contains($0.id) }
		}
	}

	var body: some View {
		chooseFormCells
			.journeyBase(self.store.scope(value: { $0.selectedJourney },
																		action: { $0 }),
									 .long)
			.onAppear {
				self.viewStore.send(.onAppear)
		}
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
						self.viewStore.send(.removeTemplateId($0.id))
					})
					ChoosePathwayButton(btnTxt: "Check-In", style: .blue, action: {
						withAnimation(Animation.linear(duration: 1)) {
							self.viewStore.send(.checkIn)
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
						self.viewStore.send(.addTemplateId($0.id))
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
