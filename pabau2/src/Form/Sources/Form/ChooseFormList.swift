import SwiftUI
import Model
import Util
import ComposableArchitecture

public struct ChooseFormState: Equatable {
	public var templates: IdentifiedArrayOf<FormTemplate>
	public var templatesLoadingState: LoadingState = .initial
	public var selectedTemplatesIds: [FormTemplate.ID]

	public init(
		templates: IdentifiedArrayOf<FormTemplate>,
		templatesLoadingState: LoadingState = .initial,
		selectedTemplatesIds: [FormTemplate.ID]
	) {
		self.templates = templates
		self.templatesLoadingState = templatesLoadingState
		self.selectedTemplatesIds = selectedTemplatesIds
	}
}

public enum ChooseFormAction {
	case addTemplateId(Int)
	case removeTemplateId(Int)
	case proceed//Check-In or Proceed
	case gotResponse(Result<[FormTemplate], RequestError>)
	case onAppear(FormType)
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
		return .none
	case .gotResponse(let result):
		switch result {
		case .success(let templates):
			state.templates = IdentifiedArray(templates)
			state.templatesLoadingState = .gotSuccess
		case .failure:
			state.templatesLoadingState = .gotError
		}
	case .onAppear(let formType):
		state.templatesLoadingState = .loading
		return
			state.templates.isEmpty ?
				environment.formAPI.getTemplates(formType)
				.map(ChooseFormAction.gotResponse)
					.eraseToEffect()
				: .none
	}
	return .none
}

public struct ChooseFormList: View {
	let mode: ChooseFormMode
	let store: Store<ChooseFormState, ChooseFormAction>
	@ObservedObject var viewStore: ViewStore<ViewState, ChooseFormAction>
	@State var searchText: String = ""
	public init (store: Store<ChooseFormState, ChooseFormAction>,
				mode: ChooseFormMode) {
		self.mode = mode
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: { ChooseFormList.ViewState.init($0) } ,
						 action: { $0 }))
		UITableView.appearance().separatorStyle = .none
	}

	struct ViewState: Equatable {
		let templates: IdentifiedArrayOf<FormTemplate>
		var selectedTemplatesIds: [Int]
		init(_ state: ChooseFormState) {
			self.templates = state.templates
			self.selectedTemplatesIds = state.selectedTemplatesIds
		}

		var notSelectedTemplates: [FormTemplate] {
			templates.elements
				.filter { !selectedTemplatesIds.contains($0.id) }
				.map { $0 }
				.sorted(by: \.name)
		}

		var selectedTemplates: [FormTemplate] {
			selectedTemplatesIds.compactMap {
				templates[id: $0]
			}
		}
	}

	public var body: some View {
		chooseFormCells
			.onAppear {
				print("on Appear \(self.mode)")
				self.viewStore.send(.onAppear(self.mode.formType))
		}
		.navigationBarTitle(self.mode.navigationTitle)
	}

	var chooseFormCells: some View {
		HStack {
			ListFrame(style: .blue) {
				VStack(alignment: .leading) {
					Text(Texts.selected + " " + (self.mode == .treatmentNotes ? Texts.treatmentNotes : Texts.consents ))
						.font(.bold17)
					FormTemplateList(templates: self.viewStore.state.selectedTemplates,
													 bgColor: ListFrameStyle.blue.bgColor,
													 templateRow: { template in
														SelectedTemplateRow(template: template)
					}, onSelect: {
						self.viewStore.send(.removeTemplateId($0.id))
					})
					PrimaryButton(self.mode.btnTitle) {
						withAnimation(Animation.linear(duration: 1)) {
							self.viewStore.send(.proceed)
						}
					}.frame(minWidth: 0, maxWidth: .infinity)
				}
			}
			ListFrame(style: .white) {
				VStack {
					TextField("TODO: search: ", text: self.$searchText)
					FormTemplateList(templates: self.viewStore.state.notSelectedTemplates,
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

public enum ChooseFormMode {
	case consentsCheckIn
	case consentsPreCheckIn
	case treatmentNotes

	var navigationTitle: String {
		switch self {
		case .consentsCheckIn, .consentsPreCheckIn:
			return Texts.chooseConsent
		case .treatmentNotes:
			return Texts.chooseTreatmentNote
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
		}
	}

	var formType: FormType {
		switch self {
		case .consentsPreCheckIn, .consentsCheckIn:
			return .consent
		case .treatmentNotes:
			return .treatment
		}
	}
}
