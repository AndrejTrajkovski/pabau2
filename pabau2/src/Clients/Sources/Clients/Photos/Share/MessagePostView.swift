import SwiftUI
import Util

struct MessagePostView: View {
    
    var param: MessageSuccessInfo = MessageSuccessInfo()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    VStack(spacing: 15) {
                        Image("ico-success")
                            .clipShape(Circle())
                        VStack {
                            Text(param.title)
                                .font(Font.bold17)
                            Text(param.subtitle)
                                .font(Font.regular17)
                        }
                    }
                }
                .frame(width: geo.size.width * 0.5,
                       height: geo.size.height * 0.3,
                       alignment: .center)
                .background(Color.white)
                .mask(RoundedRectangle(cornerRadius: 8,
                                       style: .continuous))
                
            }
            .frame(width: geo.size.width,
                   height: geo.size.height,
                   alignment: .center)
            .offset(x: 0, y: 60)
            .edgesIgnoringSafeArea(.all)
            .background(Color.black.opacity(0.5))
            
        }
    }
}

