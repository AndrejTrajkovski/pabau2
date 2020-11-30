import SwiftUI
import ComposableArchitecture
import Form
import Util

struct PhotoDetailView: View {
    
    let store: Store<PhotoCompareState, PhotoCompareAction>
    
    @ObservedObject var viewStore: ViewStore<PhotoCompareState, PhotoCompareAction>
    init(store: Store<PhotoCompareState, PhotoCompareAction>) {
        self.store = store
        viewStore = ViewStore(store)
        
    }
    
    var body: some View {
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
