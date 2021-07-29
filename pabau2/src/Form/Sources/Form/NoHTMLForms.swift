import ComposableArchitecture
import SwiftUI
import Model

struct NoForm: View {
    
    var body: some View {
        VStack {
            Text("There is no form associated to the service, please go to calendar and correct the service in order for the form to load. Skip this step instead if you will not choose any Medical Form.")
            Spacer()
        }
    }
}
