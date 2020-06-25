import SwiftUI

struct InjectablesCanvas : View {
	@State var injections: [Injection] = [
		Injection(injectable: JourneyMocks.injectables()[0],
							units: 0.2,
							position: CGPoint(x: 150, y: 150)),
		Injection(injectable: JourneyMocks.injectables()[1],
							units: 0.1,
							position: CGPoint(x: 50, y: 50)),
		Injection(injectable: JourneyMocks.injectables()[2],
							units: 0.3,
							position: CGPoint(x: 30, y: 90))
	]
	
	@State var activeInjectable: Injectable = JourneyMocks.injectables()[0]
	@State var chosenIncrement: Double = 0.25
	@State var activeInjection: Injection?
	
	var body: some View {
		return ZStack(alignment: .topLeading) {
			TappableView { location in
				let newInj = Injection(injectable: self.activeInjectable,
															 units: self.activeInjectable.increment,
															 position: location)
				self.injections.append(newInj)
				self.activeInjection = newInj
			}
			.background(Color.clear)
			ForEach(self.injections.indices, id: \.self) { idx in
				InjectableMarker(isActive: self.injections[idx] == self.activeInjection,
												 injection: self.injections[idx],
												 onSelect: {
													if self.activeInjection == $0 {
														self.injections[idx].units += self.chosenIncrement
														self.activeInjection = self.injections[idx]
													} else {
														self.activeInjection = $0
													}
				})
					.offset(CGSize(width: self.injections[idx].position.x,
												 height: self.injections[idx].position.y))
			}
		}
	}
}

struct TappableView:UIViewRepresentable {
	var tappedCallback: ((CGPoint) -> Void)
	
	func makeUIView(context: UIViewRepresentableContext<TappableView>) -> UIView {
		let view = UIView(frame: .zero)
		let gesture = UITapGestureRecognizer(target: context.coordinator,
																				 action: #selector(Coordinator.tapped))
		view.addGestureRecognizer(gesture)
		return view
	}
	
	class Coordinator: NSObject {
		var tappedCallback: ((CGPoint) -> Void)
		init(tappedCallback: @escaping ((CGPoint) -> Void)) {
			self.tappedCallback = tappedCallback
		}
		@objc func tapped(gesture:UITapGestureRecognizer) {
			let point = gesture.location(in: gesture.view)
			self.tappedCallback(point)
		}
	}
	
	func makeCoordinator() -> TappableView.Coordinator {
		return Coordinator(tappedCallback:self.tappedCallback)
	}
	
	func updateUIView(_ uiView: UIView,
										context: UIViewRepresentableContext<TappableView>) {
	}
}

struct InjectableMarker: View {
	let isActive: Bool
	let injection: Injection
	let onSelect: (Injection) -> Void
	var body: some View {
		ZStack {
			Group {
				if isActive {
					Color.black
				} else {
					injection.injectable.color
				}
			}
			Text(String(injection.units))
				.foregroundColor(.white)
				.font(.bold10)
		}.frame(width: 50, height: 50, alignment: .center)
			.onTapGesture {
				self.onSelect(self.injection)
		}
	}
}
