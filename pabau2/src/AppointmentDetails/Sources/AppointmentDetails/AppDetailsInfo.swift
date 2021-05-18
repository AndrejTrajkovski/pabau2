import SwiftUI
import Model
import ComposableArchitecture

struct AppDetailsInfo: View {

    @ObservedObject var viewStore: ViewStore<ViewState, Never>

    init (store: Store<AppDetailsState, AppDetailsAction>) {
        self.viewStore = ViewStore(store.scope(state: ViewState.init(state:)).actionless)
    }

    struct ViewState: Equatable {
        let patientName: String
        let serviceName: String
        let dateString: String
        let employeeName: String
        let roomName: String
        let serviceColor: String
    }

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color(hex: viewStore.serviceColor))
                .frame(width: 12)
                .frame(maxHeight: .infinity)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(viewStore.patientName).font(.medium24)
                        Text(viewStore.serviceName)
                            .font(.regular18)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .frame(width: 21, height: 21)
                        Text(viewStore.dateString).font(.regular18)
                    }
                    Spacer()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "person")
                            .foregroundColor(.blue)
                        Text(viewStore.employeeName).font(.medium15)
                    }
                    HStack(spacing: 4) {
                        Image("ico-room")
                        Text(viewStore.roomName).font(.regular15)
                    }
                    Spacer()
                }.padding([.leading, .trailing], 16)
            }.padding([.top, .bottom], 16)
        }.background(Color.init(hex: "D8D8D8", alpha: 0.12))
        .frame(maxHeight: 191)
        .border(Color(hex: "979797", alpha: 0.12), width: 1)
    }
}

extension AppDetailsInfo.ViewState {

    init(state: AppDetailsState) {
        self.patientName = state.app.clientName ?? ""
        self.serviceName = state.app.service
        self.dateString = state.app.start_date.toString(.time(.short))
        self.employeeName = state.app.employeeName
        self.roomName = state.app.roomName ?? ""
        self.serviceColor = state.app.serviceColor ?? "00000000"
    }
}
