//
//  DisplayView.swift
//
//

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
                viewStore.send(.onDisplay)
            }, label: {
                Text("Tap me")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            .toast(isPresented: viewStore.binding(
                    get: { $0.isPresented },
                    send: ToastAction.onDisplay)) {
                ToastView("Loading...")
                    .toastViewStyle(IndefiniteProgressToastViewStyle())
            }
            
        }
    }
}
