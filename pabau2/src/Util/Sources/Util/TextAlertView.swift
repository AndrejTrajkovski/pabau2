import Foundation
import SwiftUI
import UIKit

extension UIAlertController {
    convenience init(alert: TextAlertView) {
        self.init(title: alert.title, message: nil, preferredStyle: .alert)
        addTextField { $0.placeholder = alert.placeholder }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel, handler: { (_) in
            alert.action(.dismiss)
        }))
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default, handler: { _ in
            alert.action(.add(textField?.text ?? ""))
        }))
    }
}

/// AlertView with an textfield for entering text
///
public struct TextAlertView {
    public var title: String
    public var placeholder: String
    public var accept: String
    public var cancel: String
    public var action: (AlertActionType) -> Void
    
    public init(title: String,
                placeholder: String? = nil,
                accept: String? = nil,
                cancel: String? = nil,
                action: @escaping (AlertActionType) -> Void) {
        self.title = title
        self.placeholder = placeholder ?? ""
        self.accept = accept ?? "Add"
        self.cancel = cancel ?? "Cancel"
        self.action = action
    }
    
    public enum AlertActionType {
        case dismiss
        case add(String)
    }
}

extension View {
    public func alert(isPresented: Binding<Bool>, _ alert: TextAlertView) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextAlertView
    let content: Content
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }
    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0)
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}
