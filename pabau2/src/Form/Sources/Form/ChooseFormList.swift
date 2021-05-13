import SwiftUI
import Model
import Util
import ComposableArchitecture
import SharedComponents

public struct ChooseFormState: Equatable {
	let mode: ChooseFormMode
	public var templates: IdentifiedArrayOf<FormTemplateInfo>
	public var templatesLoadingState: LoadingState = .initial
	public var selectedTemplatesIds: [HTMLForm.ID]
	public var searchText: String = ""

	public init(
		templates: IdentifiedArrayOf<FormTemplateInfo>,
		templatesLoadingState: LoadingState = .initial,
		selectedTemplatesIds: [HTMLForm.ID],
		mode: ChooseFormMode
	) {
		self.templates = templates
		self.templatesLoadingState = templatesLoadingState
		self.selectedTemplatesIds = selectedTemplatesIds
		self.mode = mode
	}

	public func selectedTemplates() -> [FormTemplateInfo] {
		selectedTemplatesIds.compactMap { templates[id: $0] }
	}
}

public enum ChooseFormAction: Equatable {
	case addTemplateId(HTMLForm.ID)
	case removeTemplateId(HTMLForm.ID)
	case proceed//Check-In or Proceed
	case gotResponse(Result<[FormTemplateInfo], RequestError>)
	case onAppear
	case onSearch(String)
}

public let chooseFormListReducer = Reducer<ChooseFormState, ChooseFormAction, FormEnvironment> { state, action, environment in
	switch action {
	case .addTemplateId(let templateId):
		if !state.selectedTemplatesIds.contains(templateId) {
			state.selectedTemplatesIds.append(templateId)
		}
	case .removeTemplateId(let templateId):
		state.selectedTemplatesIds.removeAll(where: { $0 == templateId })
	case .proceed:
		//		updateWithKeepingOld(forms: &state.forms,
		//												 finalSelectedTemplatesIds: state.selectedTemplatesIds,
		//												 allTemplates: state.templates)
		break
	case .gotResponse(let result):
		switch result {
		case .success(let templates):
			state.templates = IdentifiedArray(templates)
			state.templatesLoadingState = .gotSuccess
		case .failure(let error):
			state.templatesLoadingState = .gotError(error)
		}
	case .onAppear:
		state.templatesLoadingState = .loading
		return
			state.templates.isEmpty ?
			environment.repository.getTemplates(state.mode.formType)
			.receive(on: DispatchQueue.main)
			.catchToEffect()
			.map(ChooseFormAction.gotResponse)
			.eraseToEffect()
			: .none
	case .onSearch(let text):
		state.searchText = text
	}
	return .none
}

public struct ChooseFormList: View {
	let store: Store<ChooseFormState, ChooseFormAction>
	@ObservedObject var viewStore: ViewStore<ViewState, ChooseFormAction>

	public init (
		store: Store<ChooseFormState, ChooseFormAction>
	) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: ViewState.init))
		UITableView.appearance().separatorStyle = .none
	}

	struct ViewState: Equatable {
		let templates: IdentifiedArrayOf<FormTemplateInfo>
		let selectedTemplatesIds: [HTMLForm.ID]
		let searchText: String
		let isSearching: Bool
		let notSelectedTemplates: [FormTemplateInfo]
		let navigationTitle: String
		let formTypeName: String
		let primaryBtnTitle: String
		init(_ state: ChooseFormState) {
			self.templates = state.templates
			self.selectedTemplatesIds = state.selectedTemplatesIds
			self.searchText = state.searchText

			self.isSearching = !state.searchText.isEmpty
			self.notSelectedTemplates = state.templates.elements
				.filter { !state.selectedTemplatesIds.contains($0.id) }
				.map { $0 }
				.sorted(by: \.name)
			self.navigationTitle = state.mode.navigationTitle
			self.formTypeName = state.mode == .treatmentNotes ? Texts.treatmentNotes : Texts.consents
			self.primaryBtnTitle = state.mode.btnTitle
		}

		var selectedTemplates: [FormTemplateInfo] {
			selectedTemplatesIds.compactMap {
				templates[id: $0]
			}
		}
	}

	public var body: some View {
		chooseFormCells
			.onAppear {
				self.viewStore.send(.onAppear)
			}
			.navigationBarTitle(viewStore.state.navigationTitle)
	}

	var chooseFormCells: some View {
		HStack {
			ListFrame(style: .blue) {
				VStack(alignment: .leading) {
					Text(Texts.selected + " " + viewStore.state.formTypeName)
						.font(.bold17)
					FormTemplateList(
						templates: self.viewStore.state.selectedTemplates,
						bgColor: ListFrameStyle.blue.bgColor,
						templateRow: { template in
							SelectedTemplateRow(template: template)
						}, onSelect: {
							self.viewStore.send(.removeTemplateId($0.id))
						})
					PrimaryButton(viewStore.primaryBtnTitle) {
						withAnimation(Animation.linear(duration: 1)) {
							self.viewStore.send(.proceed)
						}
					}.frame(minWidth: 0, maxWidth: .infinity)
				}
			}
			ListFrame(style: .white) {
				VStack {
					SearchView(
						placeholder: "Search",
						text: viewStore.binding(
							get: \.searchText,
							send: ChooseFormAction.onSearch
						)
					)
					FormTemplateList(
						templates: self.viewStore.state.notSelectedTemplates,
						bgColor: ListFrameStyle.white.bgColor,
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
	let templates: [FormTemplateInfo]
	let templateRow: (FormTemplateInfo) -> Row
	let onSelect: (FormTemplateInfo) -> Void
	let bgColor: Color

	init (templates: [FormTemplateInfo],
		  bgColor: Color,
		  @ViewBuilder templateRow: @escaping (FormTemplateInfo) -> Row,
		  onSelect: @escaping (FormTemplateInfo) -> Void
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
	let template: FormTemplateInfo
	var body: some View {
		TemplateRow.init(templateName: template.name,
						 image: Image(systemName: "plus")
		)
	}
}

struct SelectedTemplateRow: View {
	let template: FormTemplateInfo
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
		VStack (spacing: 0) {
			HStack {
				Text(templateName)
					.font(Font.regular17)
				Spacer()
				image
					.foregroundColor(Color.blue2)
			}.frame(height: 44)
			Divider().frame(height: 1)
		}.frame(height: 45)
	}
}

public enum ChooseFormMode: Equatable {
	case consentsCheckIn
	case consentsPreCheckIn
	case treatmentNotes
	case clientCard(FormType)

	var navigationTitle: String {
		switch self {
		case .consentsCheckIn, .consentsPreCheckIn:
			return Texts.chooseConsent
		case .treatmentNotes:
			return Texts.chooseTreatmentNote
		case .clientCard(let formType):
			return "Choose " + formType.rawValue.capitalized
		}
	}

	var btnTitle: String {
		switch self {
		case .consentsCheckIn:
			return Texts.toPatientMode
		case .consentsPreCheckIn:
			return Texts.checkIn
		case .treatmentNotes:
			return Texts.proceed
		case .clientCard:
			return Texts.proceed
		}
	}

	var formType: FormType {
		switch self {
		case .consentsPreCheckIn, .consentsCheckIn:
			return .consent
		case .treatmentNotes:
			return .treatment
		case .clientCard(let formType):
			return formType
		}
	}
}
