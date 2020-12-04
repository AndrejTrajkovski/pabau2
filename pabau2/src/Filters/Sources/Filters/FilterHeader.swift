import SwiftUI
import Util
import Model

public struct CalendarHeader<S: Identifiable & Equatable & Named>: View {
	let onTap: () -> Void
	init(onTap: @escaping () -> Void) {
		self.onTap = onTap
	}
	
	public var body: some View {
		Group {
			if S.self is Employee.Type {
				EmployeeHeader(onTap: onTap)
			} else if S.self is Room.Type {
				RoomHeader(onTap: onTap)
			}
		}
		.background(Color.employeeBg)
	}
}

public struct RoomHeader: View {
	let onTap: () -> Void
	public var body: some View {
		FilterHeader(title: Texts.room.uppercased(),
					 image: { Image("ico-room") },
					 didTouchHeaderButton: onTap
		)
	}
}

public struct EmployeeHeader: View {
	let onTap: () -> Void
	public var body: some View {
		FilterHeader(title: Texts.employee.uppercased(),
					 image: { Image(systemName: "person").font(.system(size: 28)) },
					 didTouchHeaderButton: onTap
		)
	}
}

public struct FilterHeader<FilterImage: View>: View {
	let title: String
	let image: () -> FilterImage
	let didTouchHeaderButton: () -> Void
	public var body: some View {
		HStack {
			Button (action: {
				self.didTouchHeaderButton()
			}, label: { image() })
			Text(title)
				.foregroundColor(.black)
				.font(Font.semibold20)
			Spacer()
		}
		.padding()
		.listRowInsets(EdgeInsets(
							top: 0,
							leading: 0,
							bottom: 0,
							trailing: 0)
		)
		.background(Color.employeeBg)
	}
}
