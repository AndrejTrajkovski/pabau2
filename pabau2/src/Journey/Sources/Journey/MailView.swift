import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    @Binding var isShowing: Bool
    var result: (Result<MFMailComposeResult, Error>?) -> Void
    let file: Data
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var isShowing: Bool
        var result: (Result<MFMailComposeResult, Error>?) -> Void
        
        init(isShowing: Binding<Bool>,
             result: @escaping (Result<MFMailComposeResult, Error>?) -> Void) {
            _isShowing = isShowing
            self.result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                isShowing = false
            }
            guard error == nil else {
                self.result(.failure(error!))
                return
            }
            self.result(.success(result))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject("Report")
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["iossupport@pabau.com"])
        vc.addAttachmentData(file, mimeType: "text/plain", fileName: "log.txt")
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        
    }
}
