import Model
import SwiftUI
import Util
import SharedComponents

struct ListCell: View {
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
		self.stepsComplete = appointment.pathways.first?.stepsComplete.description ?? ""
		self.stepsTotal = appointment.pathways.first?.stepsTotal.description ?? ""
	}

	var body: some View {
		VStack(spacing: 0) {
            if Constants.isPad {
                ipadContentView
            } else {
                iphoneContentView
            }
            
			Divider().frame(height: 1)
		}
		.frame(minWidth: 0, maxWidth: .infinity)
		.frame(height: 97)
	}
    
    var ipadContentView: some View {
        HStack {
            JourneyColorRect(color: color)
            Spacer()
            Group {
                Text(time).font(Font.semibold11)
                Spacer()
                ListCellAvatarView(
                    appointment: appointment,
                    font: .regular18,
                    bgColor: .accentColor
                ).frame(width: 55, height: 55)
                VStack(alignment: .leading, spacing: 4) {
                    Text(name).font(Font.semibold14)
                    Text(services).font(Font.regular12)
                    Text(status ?? "").font(.medium9).foregroundColor(.deepSkyBlue)
                }.frame(maxWidth: 170, alignment: .leading)
            }
            Spacer()
            IconAndText(Image(systemName: "person"), employee)
                .frame(maxWidth: 130, alignment: .leading)
            Spacer()
            IconAndText(Image(systemName: "bag"), paidStatus)
                .frame(maxWidth: 110, alignment: .leading)
            Spacer()
            StepsStatusView(stepsComplete: stepsComplete, stepsTotal: stepsTotal)
            Spacer()
        }
    }
    
    var iphoneContentView: some View {
        HStack {
            JourneyColorRect(color: color)
            Text(time).font(Font.semibold11)
            ListCellAvatarView(
                appointment: appointment,
                font: .regular18,
                bgColor: .accentColor
            ).frame(width: 55, height: 55)
            VStack(alignment: .leading, spacing: 5) {
                Spacer()
                Text(name).font(Font.semibold14)
                Text(services).font(Font.regular12)
                Text(status ?? "").font(.medium9).foregroundColor(.deepSkyBlue)
                    .isHidden(status == nil, remove: status == nil)
                HStack {
                    IconAndText(Image(systemName: "person"), employee)
                        .isHidden(employee.isEmpty, remove: employee.isEmpty)
                        .frame(alignment: .leading)
                    Spacer()
                    IconAndText(Image(systemName: "bag"), paidStatus)
                        .isHidden(employee.isEmpty, remove: employee.isEmpty)
                        .frame(alignment: .leading)
                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 16))
                Spacer()
            }
            StepsStatusView(
                stepsComplete: stepsComplete,
                stepsTotal: stepsTotal
            )
            .padding(.trailing, 16)
        }
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
