import SwiftUI
import Model
import Util
import ComposableArchitecture

let choosePathwayContainerReducer = combine(choosePathwayReducer)

func choosePathwayReducer(state: inout ChoosePathwayState?,
													action: ChoosePathwayAction,
													environment: JourneyEnvironemnt) -> [Effect<ChoosePathwayAction>] {
	switch action {
	case .didChooseConsultation:
		state?.isChooseConsentShown = true
	case .didChooseStandard:
		state?.isChooseConsentShown = true
	}
	return []
}

public enum ChoosePathwayAction {
	case didChooseStandard
	case didChooseConsultation
}

public struct ChoosePathwayState: Equatable {
	var journey: Journey
	var isChooseConsentShown: Bool
}

public struct ChoosePathway: View {
	let store: Store<ChoosePathwayState, ChoosePathwayAction>
	@ObservedObject var viewStore: ViewStore<ChoosePathwayState>
	init(store: Store<ChoosePathwayState, ChoosePathwayAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	public var body: some View {
		JourneyBaseView(journey: self.viewStore.value.journey) {
			HStack {
				PathwayCell(style: .blue) {
					ChoosePathwayListContent.init(.blue,
																				Image(systemName: "arrow.right"),
																				7,
																				"Standard Pathway",
																				"Provides a basic standard pathway, defined for the company.",
																				["Check Details", "Medical History", "Consent", "Image Upload",
																				 "Treatment Notes", "Prescription", "Aftercare"],
																				"Pathway") {
																				self.store.send(.didChooseStandard)
					}
				}
				PathwayCell(style: .white) {
					ChoosePathwayListContent.init(.white,
																				Image("ico-journey-consulting"),
																				4,
																				"Consultation Pathway",
																				"Provides a consultation pathway, to hear out the person's needs.",
																				["Check Details", "Medical History", "Image Upload", "Aftercare"],
																				"Consultation") {
																					self.store.send(.didChooseConsultation)
					}
				}
			}
			NavigationLink.emptyHidden(self.viewStore.value.isChooseConsentShown,
																 ChooseFormList(journey: self.viewStore.value.journey))
		}
	}
}

enum PathwayCellStyle {
	case blue
	case white
	
	var bgColor: Color {
		switch self {
		case .blue:
			return .gray249
		case .white:
			return .white
		}
	}

	var btnColor: Color {
		switch self {
		case .blue:
			return .blue2
		case .white:
			return .white
		}
	}

	var btnShadowColor: Color {
		switch self {
		case .blue:
			return .bigBtnShadow1
		case .white:
			return .bigBtnShadow2
		}
	}
	
	var btnShadowBlur: CGFloat {
		switch self {
		case .blue:
			return 4.0
		case .white:
			return 8.0
		}
	}
}

struct ChoosePathwayListContent: View {
	let bottomLeading: Image
	let numberOfSteps: Int
	let title: String
	let subtitle: String
	let bulletPoints: [String]
	let btnTxt: String
	let style: PathwayCellStyle
	let btnAction: () -> Void

	init(
		_ style: PathwayCellStyle,
		_ bottomLeading: Image,
		_ numberOfSteps: Int,
		_ title: String,
		_ subtitle: String,
		_ bulletPoints: [String],
		_ btnTxt: String,
		_ btnAction: @escaping () -> Void) {
		self.bottomLeading = bottomLeading
		self.numberOfSteps = numberOfSteps
		self.title = title
		self.subtitle = subtitle
		self.bulletPoints = bulletPoints
		self.btnTxt = btnTxt
		self.btnAction = btnAction
		self.style = style
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			PathwayCellHeader(bottomLeading, numberOfSteps)
			Text(title).font(.semibold20).foregroundColor(.black42)
			Text(subtitle).font(.medium15)
			PathwayBulletList(bulletPoints: bulletPoints, bgColor: style.bgColor)
			Spacer()
			ChoosePathwayButton(btnTxt: btnTxt, style: style, action: btnAction)
		}
	}
}

struct PathwayCell<Content: View>: View {
	init(style: PathwayCellStyle,
			 @ViewBuilder _ content: @escaping () -> Content) {
		self.style = style
		self.content = content
	}

	let style: PathwayCellStyle
	let content: () -> Content
	
	public var body: some View {
		VStack(spacing: 0) {
			Rectangle().fill(style.btnColor).frame(height: 8)
			content()
			.padding(32)
			.background(style.bgColor)
		}
	}
}

struct ChoosePathwayButton: View {
	let btnTxt: String
	let style: PathwayCellStyle
	let action: () -> Void
	var body: some View {
		Group {
			if self.style == .blue {
				BigButton.init(text: btnTxt,
											 btnTapAction: action)
					.shadow(color: style.btnShadowColor,
									radius: style.btnShadowBlur,
									y: 2)
					.background(style.btnColor)
			} else {
				Button.init(action: action
					, label: {
						Text(btnTxt)
							.font(Font.system(size: 16.0, weight: .bold))
							.frame(minWidth: 0, maxWidth: .infinity)
				}).buttonStyle(PathwayWhiteButtonStyle())
					.shadow(color: style.btnShadowColor,
									radius: style.btnShadowBlur,
									y: 2)
					.background(style.btnColor)
			}
		}
	}
}

struct PathwayWhiteButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.foregroundColor(Color.black)
			.background(Color.white)
	}
}

struct PathwayBulletList: View {
	let bulletPoints: [String]
	let bgColor: Color
	var body: some View {
		List {
			ForEach(bulletPoints, id: \.self) { bulletPoint in
				HStack {
					Circle()
						.fill(Color.grey216)
						.frame(width: 6.6, height: 6.6)
					Text(bulletPoint)
						.font(.regular16)
					}
					.listRowInsets(EdgeInsets())
					.listRowBackground(self.bgColor)
			}
		}
	}
}

struct PathwayCellHeader: View {
	let image: Image
	let numberOfSteps: Int
	init(_ image: Image, _ numberOfSteps: Int) {
		self.image = image
		self.numberOfSteps = numberOfSteps
	}
	var body: some View {
		ZStack {
			image.font(Font.regular45).foregroundColor(.blue2)
				.frame(minWidth: 0, maxWidth: .infinity,
				minHeight: 0, maxHeight: .infinity,
				alignment: .leading)
			Spacer()
			HStack {
				Image(systemName: "list.bullet").foregroundColor(.blue2)
				Text(String("\(numberOfSteps)")).font(.semibold17)
			}.frame(minWidth: 0, maxWidth: .infinity,
							minHeight: 0, maxHeight: .infinity,
							alignment: .topTrailing)
		}
		.frame(height: 54)
	}
}
