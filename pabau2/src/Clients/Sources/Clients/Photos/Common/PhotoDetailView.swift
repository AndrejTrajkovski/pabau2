import SwiftUI
import ComposableArchitecture
import Form
import Util

struct PhotoDetailView: View {
    
    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    var body: some View {
        
        return WithViewStore(self.store) { viewStore in
            ZStack {
                if let photo = viewStore.selectedPhoto {
                    PhotoCell(photo: photo)
                }
                VStack {
                    Spacer()
                    Text("Today")
                        .font(.regular32)
                        .foregroundColor(.white)
                    if let date = viewStore.date {
                        //DateAndNumber(date: date, number: viewStore.photos.count)
                        ZStack {
                            DayMonthYear(date: date)
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
    }
}
