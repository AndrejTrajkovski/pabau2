import SwiftUI
import Util
import Model

struct ClientCardGridItemView: View {
	let title: String
	let iconName: String
	let number: Int?

	var body: some View {
		GeometryReaderPatch { _ in
            if Constants.isPad {
                iPadItemView
            } else {
                iPhoneItemView
            }
		}.border(Color(hex: "D8D8D8"), width: 0.5)
	}

    private var iPadItemView: some View {
        VStack(spacing: 8) {
            iconItemView
            if let number = self.number {
                NumberEclipse(text: String(number))
            }
            textItemView

        }
        .padding(16)
    }

    private var iPhoneItemView: some View {
        HStack(spacing: 20) {
            VStack(spacing: 5) {
                iconItemView
            }.padding(.leading, 16)
            textItemView
            Spacer()
            if let number = self.number {
                NumberEclipse(text: String(number)).padding(.trailing, 16)
            }
        }
    }

    private var iconItemView: some View {
        Image(systemName: self.iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.accentColor)
            .frame(width: 50, height: Constants.isPad ? 50 : 25)
    }

    private var textItemView: some View {
        Text(self.title).font(.clientCardGridItemTitle)
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

	func count(model: ClientItemsCount?) -> Int? {
		guard let model = model else { return nil }
		switch self {
		case .details: return nil
		case .appointments: return model.appointments
		case .photos: return model.photos
		case .financials: return model.financials
		case .treatmentNotes: return model.treatmentNotes
		case .prescriptions: return model.presriptions
		case .documents: return model.documents
		case .communications: return model.communications
		case .consents: return model.consents
		case .alerts: return model.alerts
		case .notes: return model.notes
		}
	}
}
