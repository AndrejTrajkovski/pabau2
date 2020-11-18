import SwiftUI
import Util

struct AppointmentDetails: View {
	let patientName: String
	let serviceName: String
	let dateString: String
	let employeeName: String
	let roomName: String
	let imageUrl: String?
	let statusColor: String
	let statusDesc: String
	let serviceColor: String
	
	var body: some View {
		VStack(spacing: 0) {
			AppDetailsHeader(imageUrl: imageUrl, name: patientName, statusColor: statusColor, statusDesc: statusDesc)
			Spacer().frame(height: 32)
			AppDetailsInfo(patientName: patientName, serviceName: serviceName, dateString: dateString, employeeName: employeeName, roomName: roomName, serviceColor: serviceColor)
			AppDetailsItems()
			PrimaryButton(Texts.addService,
						  isDisabled: false,
						  { })
			Spacer().frame(maxHeight: .infinity)
		}.padding(60)
	}
}

struct AppDetailsInfo: View {
	let patientName: String
	let serviceName: String
	let dateString: String
	let employeeName: String
	let roomName: String
	let serviceColor: String
	
	var body: some View {
		HStack {
			HStack {
				Rectangle()
					.fill(Color(hex: serviceColor))
					.frame(width: 12)
				HStack {
					VStack(alignment: .leading, spacing: 4){
						VStack(alignment: .leading, spacing: 0) {
							Text(patientName).font(.medium24)
							Text(serviceName)
								.font(.regular18)
						}
						HStack(spacing: 4) {
							Image(systemName: "clock")
								.foregroundColor(.blue)
								.frame(width: 21, height: 21)
							Text(dateString).font(.regular18)
						}
						Spacer()
					}
				Spacer()
				VStack(alignment: .trailing) {
					HStack(spacing: 4) {
						Image(systemName: "person")
							.foregroundColor(.blue)
						Text(employeeName).font(.medium15)
					}
					HStack(spacing: 4) {
						Image("ico-room")
						Text(roomName).font(.regular15)
					}
					Spacer()
				}
				}.padding(16)
			}
		}.background(Color.init(hex: "D8D8D8", alpha: 0.12))
		.frame(maxHeight: 191)
		.border(Color(hex: "979797", alpha: 0.12), width: 1)
	}
}

struct AppDetailsHeader: View {
	let imageUrl: String?
	let name: String
	let statusColor: String
	let statusDesc: String
	var body: some View {
		VStack {
			if let imageU = imageUrl {
				Image(imageU)
					.resizable()
					.scaledToFill()
					.clipShape(Circle())
					.frame(width: 84, height: 84)
			} else {
				Image(systemName: "person")
					.resizable()
			}
			Text(name).font(.semibold24)
			HStack {
				Circle().fill(Color.init(hex: statusColor))
					.frame(width: 12, height: 12)
				Text(statusDesc).font(.regular16)
			}
		}
	}
}

public enum ItemAction: Equatable {
	case onPayment
	case onCancel
	case onStatus
	case onRepeat
	case onDocuments
	case onReschedule
}

struct AppDetailsItems: View {
	
	let columns = [
		GridItem(.adaptive(minimum: 200), spacing: 0),
	]
	
	let items = [
		("briefcase", Texts.payment, ItemAction.onPayment),
		("minus.circle", Texts.cancel, ItemAction.onCancel),
		("pencil.and.ellipsis.rectangle", Texts.status, ItemAction.onStatus),
		("arrow.2.circlepath", Texts.repeat, ItemAction.onRepeat),
		("doc.text", Texts.documents, ItemAction.onDocuments),
		("arrowshape.turn.up.right", Texts.reschedule, ItemAction.onReschedule)
	]
	var body: some View {
		ScrollView {
			LazyVGrid(columns: columns, spacing: 0) {
				ForEach(items.indices) { idx in
					AppDetailsItem(onTap: {
						items[idx].2
					}, image: items[idx].0, title: items[idx].1)
				}
			}
		}
	}
}

struct AppDetailsItem: View {
	let onTap: () -> Void
	let image: String
	let title: String
	var body: some View {
		Button (action: onTap){
			VStack(spacing: 8) {
				Image(systemName: image)
					.font(.medium38)
					.foregroundColor(.blue)
				Text(title)
					.foregroundColor(.black)
					.font(.regular17)
			}
		}.frame(maxWidth: .infinity, minHeight: 100)
		.padding(16)
		.border(Color(hex: "979797", alpha: 0.12), width: 1)
	}
}

struct AddBookout_Previews: PreviewProvider {
	static var previews: some View {
		AppointmentDetails(patientName: "Bill Anderson", serviceName: "Hydrafacial", dateString: "16:30", employeeName: "Dr Martin Shrekell", roomName: "402", imageUrl: "dummy4", statusColor: "0067D9", statusDesc: "Waiting", serviceColor: "108A44")
	}
}
