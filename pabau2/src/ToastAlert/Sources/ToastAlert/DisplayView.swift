import SwiftUI
import ToastUI
import ComposableArchitecture

struct DisplayView: View {
    
    let store: Store<ToastState, ToastAction>
    public init(store: Store<ToastState, ToastAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Button(action: {
                
            }, label: {
                Text("Tap me")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
			.toast(isPresented: .constant(viewStore.isPresented),
				   onDismiss: { viewStore.send(.dismiss) }) {
                ToastView("Loading...")
                    .toastViewStyle(IndefiniteProgressToastViewStyle())
            }
            
        }
    }
}
