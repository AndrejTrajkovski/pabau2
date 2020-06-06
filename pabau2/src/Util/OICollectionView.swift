import SwiftUI

//from
//https://github.com/objcio/S01E168-building-a-collection-view-part-2/blob/master/FlowLayoutST/ContentView.swift

//https://talk.objc.io/episodes/S01E168-building-a-collection-view-part-2

public struct FlowLayout {
	let spacing: UIOffset
	let containerSize: CGSize

	init(containerSize: CGSize, spacing: UIOffset = UIOffset(horizontal: 10, vertical: 10)) {
		self.spacing = spacing
		self.containerSize = containerSize
	}

	var currentX = 0 as CGFloat
	var currentY = 0 as CGFloat
	var lineHeight = 0 as CGFloat

	mutating func add(element size: CGSize) -> CGRect {
		if currentX + size.width > containerSize.width {
			currentX = 0
			currentY += lineHeight + spacing.vertical
			lineHeight = 0
		}
		defer {
			lineHeight = max(lineHeight, size.height)
			currentX += size.width + spacing.horizontal
		}
		return CGRect(origin: CGPoint(x: currentX, y: currentY), size: size)
	}
	
	var size: CGSize {
		return CGSize(width: containerSize.width, height: currentY + lineHeight)
	}
}

public func flowLayout<Elements>(for elements: Elements, containerSize: CGSize, sizes: [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize] where Elements: RandomAccessCollection, Elements.Element: Identifiable {
	var state = FlowLayout(containerSize: containerSize)
	var result: [Elements.Element.ID: CGSize] = [:]
	for element in elements {
		let rect = state.add(element: sizes[element.id] ?? .zero)
		result[element.id] = CGSize(width: rect.origin.x, height: rect.origin.y)
	}
	return result
}

public func singleLineLayout<Elements>(for elements: Elements, containerSize: CGSize, sizes: [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize] where Elements: RandomAccessCollection, Elements.Element: Identifiable {
	var result: [Elements.Element.ID: CGSize] = [:]
	var offset = CGSize.zero
	for element in elements {
		result[element.id] = offset
		let size = sizes[element.id] ?? CGSize.zero
		offset.width += size.width + 10
	}
	return result
}

public struct OICollectionView<Elements, Content>: View where Elements: RandomAccessCollection, Content: View, Elements.Element: Identifiable {
	public init (
		data: Elements,
		layout: @escaping (Elements, CGSize, [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize],
		content: @escaping (Elements.Element) -> Content
	) {
		self.data = data
		self.layout = layout
		self.content = content
	}

	var data: Elements
	var layout: (Elements, CGSize, [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize]
	var content: (Elements.Element) -> Content
	@State private var sizes: [Elements.Element.ID: CGSize] = [:]

	private func bodyHelper(containerSize: CGSize, offsets: [Elements.Element.ID: CGSize]) -> some View {
		ZStack(alignment: .topLeading) {
			ForEach(data) {
				PropagateSize(content: self.content($0), id: $0.id)
					.offset(offsets[$0.id] ?? CGSize.zero)
					.animation(.default)
			}
			Color.clear
				.frame(width: containerSize.width, height: containerSize.height)
				.fixedSize()
		}.onPreferenceChange(CollectionViewSizeKey.self) {
			self.sizes = $0
		}.background(Color.red)
	}

	public var body: some View {
		GeometryReader { proxy in
			self.bodyHelper(containerSize: proxy.size, offsets: self.layout(self.data, proxy.size, self.sizes))
		}
	}
}

struct CollectionViewSizeKey<ID: Hashable>: PreferenceKey {
	typealias Value = [ID: CGSize]

	static var defaultValue: [ID: CGSize] { [:] }
	static func reduce(value: inout [ID:CGSize], nextValue: () -> [ID:CGSize]) {
		value.merge(nextValue(), uniquingKeysWith: { $1 })
	}
}

struct PropagateSize<V: View, ID: Hashable>: View {
	var content: V
	var id: ID
	var body: some View {
		content.background(GeometryReader { proxy in
			Color.clear.preference(key: CollectionViewSizeKey<ID>.self, value: [self.id: proxy.size])
		})
	}
}

