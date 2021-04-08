import Model
import SwiftUI
import Util

struct JourneyCell: View {
	let appointment: Appointment
	let color: Color
	let time: String
	let imageUrl: String?
	let name: String
	let services: String
	let status: String?
	let employee: String
	let paidStatus: String
	let stepsComplete: String
	let stepsTotal: String
	
	init(appointment: Appointment) {
		self.appointment = appointment
		self.color = Color.init(hex: appointment.serviceColor ?? "#000000")
		self.time = DateFormatter.HHmm.string(from: appointment.start_date)
		self.imageUrl = appointment.clientPhoto ?? ""
		self.name = appointment.clientName ?? ""
		self.services = appointment.service
		self.status = appointment.status?.name
		self.employee = appointment.employeeName
		self.paidStatus = ""
		self.stepsComplete = appointment.stepsComplete?.description ?? ""
		self.stepsTotal = appointment.stepsTotal?.description ?? ""
	}
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				JourneyColorRect(color: color)
				Spacer()
				Group {
					Text(time).font(Font.semibold11)
					Spacer()
					JourneyAvatarView(appointment: appointment, font: .regular18, bgColor: .accentColor)
						.frame(width: 55, height: 55)
					VStack(alignment: .leading, spacing: 4) {
						Text(name).font(Font.semibold14)
						Text(services).font(Font.regular12)
						Text(status ?? "").font(.medium9).foregroundColor(.deepSkyBlue)
					}.frame(maxWidth: 158, alignment: .leading)
				}
				Spacer()
				IconAndText(Image(systemName: "person"), employee)
					.frame(maxWidth: 110, alignment: .leading)
				Spacer()
				IconAndText(Image(systemName: "bag"), paidStatus)
					.frame(maxWidth: 110, alignment: .leading)
				Spacer()
				StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
				Spacer()
			}
			Divider().frame(height: 1)
		}
		.frame(minWidth: 0, maxWidth: .infinity, idealHeight: 97)
	}
}

struct IconAndText: View {
	let text: String
	let image: Image
	let textColor: Color
	init(_ image: Image,
		 _ text: String,
		 _ textColor: Color = .black) {
		self.image = image
		self.text = text
		self.textColor = textColor
	}
	var body: some View {
		HStack {
			image
				.resizable()
				.scaledToFit()
				.foregroundColor(.blue2)
				.frame(width: 20, height: 20)
			Text(text)
				.font(Font.semibold11)
				.foregroundColor(textColor)
		}
	}
}

struct StepsStatusView: View {
	let stepsComplete: String
	let stepsTotal: String
	var body: some View {
		NumberEclipse(text: stepsComplete + "/" + stepsTotal)
	}
}

struct JourneyColorRect: View {
	public let color: Color
	var body: some View {
		Rectangle()
			.foregroundColor(color)
			.frame(width: 8.0)
	}
}
