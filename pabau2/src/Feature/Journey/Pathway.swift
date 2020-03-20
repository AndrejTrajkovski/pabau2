
import SwiftUI
import Model

public struct ChoosePathway: View {
	let journey: Journey
	public var body: some View {
		VStack(spacing: 8) {
			makeProfileView(journey: journey)
				.padding()
			HStack {
				PathwayCell.init(
					Image(systemName: "arrow.right"),
					7,
					"Standard Pathway",
					"Provides a basic standard pathway, defined for the company.",
					["Check Details", "Medical History", "Consent", "Image Upload",
					"Treatment Notes", "Prescription", "Aftercare"]
				)
				PathwayCell.init(
					Image("ico-journey-consulting"),
					4,
					"Consultation Pathway",
					"Provides a consultation pathway, to hear out the person's needs.",
					["Check Details", "Medical History", "Image Upload", "Aftercare"]
				)
			}
		}
	}
}

public struct PathwayCell: View {
	public init(
		_ bottomLeading: Image,
		_ numberOfSteps: Int,
		_ title: String,
		_ subtitle: String,
		_ bulletPoints: [String]) {
		self.bottomLeading = bottomLeading
		self.numberOfSteps = numberOfSteps
		self.title = title
		self.subtitle = subtitle
		self.bulletPoints = bulletPoints
	}
	let bottomLeading: Image
	let numberOfSteps: Int
	let title: String
	let subtitle: String
	let bulletPoints: [String]
	public var body: some View {
		VStack {
			PathwayCellHeader(bottomLeading, numberOfSteps)
			Text(title).font(.semibold20).foregroundColor(.black42)
			Text(subtitle).font(.medium15)
			PathwayBulletList(bulletPoints: bulletPoints)
			Spacer()
		}.padding(32)
	}
}

struct PathwayBulletList: View {
	let bulletPoints: [String]
	var body: some View {
		List {
			ForEach(bulletPoints, id: \.self) { bulletPoint in
				HStack {
					Circle()
						.fill(Color.grey216)
						.frame(width: 6.6, height: 6.6)
					Text(bulletPoint)
						.font(.regular16)
				}.listRowInsets(EdgeInsets())
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
