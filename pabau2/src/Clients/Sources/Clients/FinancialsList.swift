import SwiftUI
import Model
import Util

struct FinancialsList: ClientCardChild {
	var state: [Financial]
	var body: some View {
		List {
			ForEach(self.state.indices, id: \.self) { idx in
				FinancialRow(financial: self.state[idx])
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
			Divider()
		}
	}
}

private struct FinancialsRow<Content: View>: View {
	let title: String
	let content: () -> Content
	var body: some View {
		HStack {
			Text(title).font(.semibold17)
			Spacer()
			content()
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
