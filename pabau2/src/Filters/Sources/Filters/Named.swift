import Model

public protocol Named {
	var name: String { get }
}
extension Location: Named { }
extension Room: Named {}
extension Employee: Named {}
