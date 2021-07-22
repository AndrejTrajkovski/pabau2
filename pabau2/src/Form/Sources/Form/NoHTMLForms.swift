import ComposableArchitecture
import SwiftUI
import Model

public struct NoHTMLFormsState: Equatable, Identifiable {
    public var id: Step.ID { stepId }
    var status: StepStatus
    let stepId: Step.ID
    let pathwayId: Pathway.ID
    let stepType: StepType
}

//enum NotHTMLFormsAction: Equatable {
//    case skipStep
//}

struct NoForm: View {
    
    let store: Store<NoHTMLFormsState, Never>
    
    var body: some View {
        VStack {
            Text("There is no form associated to the service, please go to calendar and correct the service in order for the form to load. Skip this step instead if you will not choose any Medical Form.")
            Spacer()
        }
    }
}
