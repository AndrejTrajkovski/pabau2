import Foundation
import SwiftUI
import Util

struct GridStack<Content: View>: View {
	let rows: Int
	let columns: Int
	let content: (Int, Int) -> Content
	init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
		self.rows = rows
		self.columns = columns
		self.content = content
	}
	var body: some View {
		GeometryReaderPatch { _ in
			VStack {
				ForEach(0..<self.rows, id: \.self) { row in
					HStack {
						ForEach(0..<self.columns, id: \.self) { column in
							self.content(row, column)
						}
					}
				}
			}
		}
	}
}
