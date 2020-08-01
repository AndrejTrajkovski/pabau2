import SwiftUI
import Util

struct ClientCardGridItemView: View {
	let item: ClientCardGridItem
	var body: some View {
		VStack {
			Image(systemName: item.iconName)
			Text(item.title).font(Font.medium16)
		}
	}
}

public enum ClientCardGridItem: Int, Equatable {
	case details = 0
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
