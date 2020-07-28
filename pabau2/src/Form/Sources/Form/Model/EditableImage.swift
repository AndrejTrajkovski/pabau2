import PencilKit

protocol PhotoVariant: Identifiable {
	var drawings: [PKDrawing] { get set }
}
