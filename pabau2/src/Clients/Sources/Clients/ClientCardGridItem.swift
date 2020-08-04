import SwiftUI
import Util
import Model

struct ClientCardGridItemView: View {
//	let item: ClientCardGridItem
	let title: String
	let iconName: String
	let number: Int?
	var body: some View {
		GeometryReader { geo in
			VStack(spacing: 8) {
				Image(systemName: self.iconName)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.foregroundColor(.accentColor)
					.frame(height: 50)
				if self.number != nil {
					NumberEclipse(text: String(self.number!))
				}
				Text(self.title).font(Font.medium16)
			}
			.padding(16)
			.frame(width: geo.size.width, height: geo.size.width)
		}.border(Color(hex: "D8D8D8"), width: 0.5)
	}
}

public enum ClientCardGridItem: Equatable, CaseIterable {
	case details
	case appointments
	case photos
	case financials
	case treatmentNotes
	case prescriptions
	case documents
	case communications
	case consents
	case alerts
	case notes

	var title: String {
		switch self {
		case .details: return Texts.details
		case .appointments: return Texts.appointments
		case .photos: return Texts.photos
		case .financials: return Texts.financials
		case .treatmentNotes: return Texts.treatmentNotes
		case .prescriptions: return Texts.prescriptions
		case .documents: return Texts.documents
		case .communications: return Texts.communications
		case .consents: return Texts.consents
		case .alerts: return Texts.alerts
		case .notes: return Texts.notes
		}
	}

	var iconName: String {
		switch self {
		case .details: return "person"
		case .appointments: return "calendar"
		case .photos: return "photo.on.rectangle"
		case .financials: return "sterlingsign.circle"
		case .treatmentNotes: return "doc.text"
		case .prescriptions: return "doc.append"
		case .documents: return "tray.2"
		case .communications: return "message"
		case .consents: return "signature"
		case .alerts: return "exclamationmark.triangle"
		case .notes: return "square.and.pencil"
		}
	}
}
