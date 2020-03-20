import SwiftUI
import Model
import Util

public struct ChoosePathway: View {
	let journey: Journey
	public var body: some View {
		VStack(spacing: 8) {
			makeProfileView(journey: journey)
				.padding()
			HStack {
				PathwayCell.init(
					.blue,
					Image(systemName: "arrow.right"),
					7,
					"Standard Pathway",
					"Provides a basic standard pathway, defined for the company.",
					["Check Details", "Medical History", "Consent", "Image Upload",
					 "Treatment Notes", "Prescription", "Aftercare"],
					"Pathway"
				)
				PathwayCell.init(
					.white,
					Image("ico-journey-consulting"),
					4,
					"Consultation Pathway",
					"Provides a consultation pathway, to hear out the person's needs.",
					["Check Details", "Medical History", "Image Upload", "Aftercare"],
					"Consultation"
				)
			}
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

struct PathwayCell: View {
	init(
		_ style: PathwayCellStyle,
		_ bottomLeading: Image,
		_ numberOfSteps: Int,
		_ title: String,
		_ subtitle: String,
		_ bulletPoints: [String],
		_ btnTxt: String) {
		self.style = style
		self.bottomLeading = bottomLeading
		self.numberOfSteps = numberOfSteps
		self.title = title
		self.subtitle = subtitle
		self.bulletPoints = bulletPoints
		self.btnTxt = btnTxt
	}
	let bottomLeading: Image
	let numberOfSteps: Int
	let title: String
	let subtitle: String
	let bulletPoints: [String]
	let btnTxt: String
	let style: PathwayCellStyle
//	let btnAction: () -> Void
	public var body: some View {
		VStack(spacing: 0) {
			Rectangle().fill(style.btnColor).frame(height: 8)
			VStack(alignment: .leading, spacing: 16) {
				PathwayCellHeader(bottomLeading, numberOfSteps)
				Text(title).font(.semibold20).foregroundColor(.black42)
				Text(subtitle).font(.medium15)
				PathwayBulletList(bulletPoints: bulletPoints, bgColor: style.bgColor)
				Spacer()
				Group {
					if self.style == .blue {
						BigButton.init(text: btnTxt,
													 btnTapAction: {
														
						}).shadow(color: style.btnShadowColor,
											radius: style.btnShadowBlur,
											y: 2)
							.background(style.btnColor)
					} else {
						Button.init(action: {}
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
			.padding(32)
			.background(style.bgColor)
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
