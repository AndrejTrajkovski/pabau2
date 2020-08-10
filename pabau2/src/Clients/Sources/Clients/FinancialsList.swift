import SwiftUI
import Model
import Util
import ComposableArchitecture

extension ClientCardChildState: ClientCardChildParentState {
	var childState: ClientCardChildState<T> {
		get {
			self
		}
		set {
			self = newValue
		}
	}
}

extension GotClientListAction: ClientCardChildParentAction {
	var action: GotClientListAction<T>? {
		get {
			self
		}
		set {
			newValue.map { self = $0 }
		}
	}
}

struct FinancialsList: ClientCardChild {
	let store: Store<ClientCardChildState<[Financial]>, GotClientListAction<[Financial]>>
	var body: some View {
		WithViewStore(store) { viewStore in
			List {
				ForEach(viewStore.state.state.indices, id: \.self) { idx in
					FinancialRow(financial: viewStore.state.state[idx])
						.background(idx % 2 == 0 ? Color.clear : Color(hex: "F9F9F9"))
				}
			}
		}
	}
}

private struct FinancialRow: View {
	let financial: Financial
	var body: some View {
		VStack {
			InvoiceRow(text1: Texts.invoice,
								 invoice: financial.number,
								 date: financial.date)
			FinancialsTextRow(text1: Texts.location, text2: financial.locationName)
			FinancialsTextRow(text1: Texts.employee, text2: financial.employeeName)
			FinancialsTextRow(text1: Texts.issuedTo, text2: financial.issuedTo)
			FinancialsTextRow(text1: Texts.method, text2: financial.method)
			FinancialsTextRow(text1: Texts.amount, text2: String(financial.amount))
		}
	}
}

private struct FinancialsRow<Content: View>: View {
	let title: String
	let content: () -> Content
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Text(title).font(.semibold17)
				Spacer()
				content()
			}
			Divider()
		}.frame(height: 44.0)
	}
}

private struct InvoiceRow: View {
	let text1: String
	let invoice: String
	let date: Date
	var body: some View {
		FinancialsRow(title: text1,
									content: {
										HStack {
											DateLabel(date: self.date)
											InvoiceLabel(invoiceNumber: self.invoice)
										}
		})
	}
}

private struct FinancialsTextRow: View {
	let text1: String
	let text2: String
	var body: some View {
		FinancialsRow(title: text1,
									content: {
										Text(self.text2)
											.foregroundColor(.clientCardNeutral)
		})
	}
}

private struct InvoiceLabel: View {
	let invoiceNumber: String
	var body: some View {
		HStack {
			Image(systemName: "paperclip")
				.foregroundColor(.accentColor)
			Text(invoiceNumber)
				.font(.regular15)
				.foregroundColor(.clientCardNeutral)
		}
	}
}
