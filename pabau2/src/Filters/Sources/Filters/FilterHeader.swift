import SwiftUI
import Util
import Model

public struct CalendarHeader<S: Identifiable & Equatable & Named>: View {
	
	let onTap: () -> Void
	let onReload: () -> Void
	
	init(onTap: @escaping () -> Void,
		 onReload: @escaping () -> Void) {
		self.onTap = onTap
		self.onReload = onReload
	}

	public var body: some View {
		Group {
			if S.self is Employee.Type {
				FilterHeader(title: Texts.employees.capitalized,
							 image: { Image(systemName: "person").font(.system(size: 28)) },
							 didTouchHeaderButton: onTap,
							 onReload: onReload
				)
			} else if S.self is Room.Type {
				FilterHeader(title: Texts.rooms.capitalized,
							 image: { Image("ico-room") },
							 didTouchHeaderButton: onTap,
							 onReload: onReload
				)
			}
		}
		.background(Color.employeeBg)
	}
}

//public struct RoomHeader: View {
//	let onTap: () -> Void
//	public var body: some View {
//		FilterHeader(title: Texts.room.uppercased(),
//					 image: { Image("ico-room") },
//					 didTouchHeaderButton: onTap
//		)
//	}
//}
//
//public struct EmployeeHeader: View {
//	let onTap: () -> Void
//	public var body: some View {
//		FilterHeader(title: Texts.employee.uppercased(),
//					 image: { Image(systemName: "person").font(.system(size: 28)) },
//					 didTouchHeaderButton: onTap
//		)
//	}
//}

public struct FilterHeader<FilterImage: View>: View {
	let title: String
	let image: () -> FilterImage
	let didTouchHeaderButton: () -> Void
	let onReload: () -> Void
	public var body: some View {
		HStack {
			Button (action: {
				self.didTouchHeaderButton()
			}, label: {
				HStack {
					image()
					Text(title)
						.foregroundColor(.black)
						.font(Font.semibold20)
				}
			})
			Spacer()
			Button(action: {
				onReload()
			}, label: {
				Image(systemName: "arrow.triangle.2.circlepath")
					.font(.system(size: 24))
			})
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
