import SwiftUI
import ComposableArchitecture
import Util
import CasePaths
import Model

public enum AftercareAction: Equatable {
    case complete
    case gotCompleteResponse(Result<StepStatus, RequestError>)
    case gotAftercareAndRecallsResponse(Result<AftercareAndRecalls, RequestError>)
    case aftercares(AftercareBoolAction)
    case recalls(AftercareBoolAction)
    case profile(SingleSelectImagesAction)
    case share(SingleSelectImagesAction)
}

public let aftercareReducer: Reducer<AftercareState, AftercareAction, FormEnvironment> = (
    .combine(
        
        .init { state, action, env in
            
            switch action {
            case .gotAftercareAndRecallsResponse(let result):
                switch result {
                case .success(let success):
                    state.aftercares.templates = success.aftercare
                    state.recalls.templates = success.recalls
                case .failure:
                    break //step reducer
                }
            case .aftercares:
                break
            case .profile:
                break
            case .recalls:
                break
            case .share:
                break
            case .complete:
                break
            case .gotCompleteResponse(_):
                break
            }
            
            return .none
        },
        
        aftercareBoolSectionReducer.pullback(
            state: \AftercareState.aftercares,
            action: /AftercareAction.aftercares,
            environment: { $0 }
        ),
        aftercareBoolSectionReducer.pullback(
            state: \AftercareState.recalls,
            action: /AftercareAction.recalls,
            environment: { $0 }
        ),
        singleSelectImagesReducer.pullback(
            state: \AftercareState.profile,
            action: /AftercareAction.profile,
            environment: { $0 }
        ),
        singleSelectImagesReducer.pullback(
            state: \AftercareState.share,
            action: /AftercareAction.share,
            environment: { $0 })
    )
)

public struct AftercareForm: View {
    let store: Store<AftercareState, AftercareAction>
//    @ObservedObject var viewStore: ViewStore<AftercareState, AftercareAction>
    
    public init(store: Store<AftercareState, AftercareAction>) {
        self.store = store
//        self.viewStore = ViewStore(store)
    }
    
    private var imagesColumns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public var body: some View {
        ScrollView {
            LazyVGrid (
                columns: imagesColumns,
                alignment: .leading,
                spacing: 16,
                pinnedViews: [.sectionHeaders]
            ){
                AftercareImagesSection(title: Texts.setProfilePhoto,
                                       store: store.scope(state: { $0.profile },
                                                          action: { .profile($0)})
                )
                AftercareImagesSection(title: Texts.sharePhoto,
                                       store: store.scope(state: { $0.share },
                                                          action: { .share($0)})
                )
            }
            AftercareBoolSection(title: Texts.sendAftercareQ,
                                 desc: Texts.sendAftercareDesc,
                                 store: store.scope(state: { $0.aftercares },
                                                    action: { .aftercares($0 )}
                                 )
            )
            AftercareBoolSection(title: Texts.recallsQ,
                                 desc: Texts.recallsDesc,
                                 store: store.scope(state: { $0.recalls },
                                                    action: { .recalls($0 )}
                                 )
            )
        }
    }
}

struct AftercareTitle: View {
    let title: String
    init (_ title: String) {
        self.title = title
    }
    var body: some View {
        Text(title)
            .font(.bold24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}
