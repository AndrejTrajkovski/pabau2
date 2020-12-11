import SwiftUI
import Util

struct MessagePostView: View {
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    VStack(spacing: 15) {
                        Image("ico-success")
                            .clipShape(Circle())
                        
                        VStack {
                            Text("Succesfully saved the image.")
                                .font(Font.bold17)
                            Text("Your images has been saved locally")
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



extension UIView {

    func asImage() -> UIImage {
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: image!.cgImage!)
    }
}
