import SwiftUI
import ComposableArchitecture
import Model

public struct CalendarSwiftUI<Section: Identifiable & Equatable>: UIViewControllerRepresentable {
	public init(store: Store<CalendarSectionViewState<Section>, SubsectionCalendarAction<Section>>) {
		self.store = store
	}
	
	let store: Store<CalendarSectionViewState<Section>, SubsectionCalendarAction<Section>>
	
	public func makeUIViewController(context: Context) -> SectionCalendarViewController<Section> {
		print("makeUIViewController")
		return SectionCalendarViewController<Section>(ViewStore(store))
	}

	public func updateUIViewController(_ uiViewController: SectionCalendarViewController<Section>, context: Context) {
	}
}
