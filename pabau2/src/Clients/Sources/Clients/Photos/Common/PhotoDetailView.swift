import SwiftUI
import ComposableArchitecture
import Form
import Util

struct PhotoDetailView: View {
    
    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    var body: some View {
        
        return WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    if let photo = viewStore.selectedPhoto {
                        ScrollView {
                            TimelinePhotoCell(photo: photo)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
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
}
