import SwiftUI
import Util

struct PatientDetailsForm: View {
	let vms: [[TextAndTextViewVM]] = [
		[
			TextAndTextViewVM(.constant("Mr"), Texts.salutation),
			TextAndTextViewVM(.constant("Jonathan"), Texts.firstName),
			TextAndTextViewVM(.constant("Davis"), Texts.lastName)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.dob),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.phone),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.cellPhone)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.email),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.addressLine1),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.addressLine2)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.postCode),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.city),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.county)
		],
		[
			TextAndTextViewVM(.constant("October 18th 1991"), Texts.country),
			TextAndTextViewVM(.constant("+ 389 70 999 111"), Texts.howDidUHear)
		]
	]
	
	var body: some View {
		print("Patient details body")
		return VStack {
			ThreeTextColumns(self.vms[0], isFirstFixSized: true)
			ThreeTextColumns(self.vms[1])
			ThreeTextColumns(self.vms[2])
			ThreeTextColumns(self.vms[3])
			ThreeTextColumns(self.vms[4])
		}
	}
}

struct TextAndTextViewVM {
	let value: Binding<String>
	let title: String
	init(_ value: Binding<String>, _ title: String) {
		self.value = value
		self.title = title
	}
}

struct ThreeTextColumns: View {
	let vms: [TextAndTextViewVM]
	let isFirstFixSized: Bool
	
	init(_ vms: [TextAndTextViewVM], isFirstFixSized: Bool = false) {
		self.vms = vms
		self.isFirstFixSized = isFirstFixSized
	}

	var body: some View {
		HStack {
			TextAndTextField(self.vms[0].title,
											 self.vms[0].value)
				.fixedSize(horizontal: isFirstFixSized, vertical: false)
			Spacer()
			TextAndTextField(self.vms[1].title,
											 self.vms[1].value)
			Spacer()
			if self.vms.count == 3 {
				TextAndTextField(self.vms[2].title,
												 self.vms[2].value)
			} else {
				Spacer()
					.fixedSize(horizontal: false, vertical: true)
			}
		}
	}
}
