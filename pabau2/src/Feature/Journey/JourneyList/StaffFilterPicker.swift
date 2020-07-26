import SwiftUI
import Util

struct StaffFilterPicker: View {
	@State private var filter: ChooseServiceFilter = .onlyMe
	var body: some View {
		VStack {
			Picker(selection: $filter, label: Text("Filter")) {
				ForEach(ChooseServiceFilter.allCases, id: \.self) { (filter: ChooseServiceFilter) in
					Text(String(filter.description)).tag(filter.rawValue)
				}
			}.pickerStyle(SegmentedPickerStyle())
		}.padding()
	}
}
