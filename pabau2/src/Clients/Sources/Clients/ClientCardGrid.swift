import SwiftUI

enum ClientCardGridAction: Equatable {
	case onSelect(ClientCardGridItem)
}

struct ClientCardGrid: View {
	var body: some View {
		GridStack(rows: 3, columns: 4) { row, col in
			ClientCardGridItemView(item:
				ClientCardGridItem(rawValue: (row * row) + col)
			)
		}
	}
}
