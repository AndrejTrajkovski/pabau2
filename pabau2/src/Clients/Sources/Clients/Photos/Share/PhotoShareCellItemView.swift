import SwiftUI
import ComposableArchitecture

struct PhotoShareCellItemView: View {
    //let store: <PhotoShareSelectItem, PhotoShareAction>
    let item: PhotoShareSelectItem
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("emily")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width / 2)
                        .clipped()
                    Image("emily")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width / 2)
                        .clipped()
                }
                HStack {
                    Spacer()
                        .frame(width: 15)
                    Image("logo-pabau")
                    Spacer()
                    Text("20 Days Difference")
                    Spacer()
                        .frame(width: 10)
                        
                }.background(Color.white)
                .frame(height: 60)
                
            }.navigationTitle("Select Photo")
        }
    }
}
