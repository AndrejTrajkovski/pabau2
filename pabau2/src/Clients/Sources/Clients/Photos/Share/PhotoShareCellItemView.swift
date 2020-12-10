import SwiftUI
import ComposableArchitecture


//struct PhotoShareCellItem: View {
//    let item: PhotoShareSelectItem
//    
//    var body: some View {
//        
//        switch item.type {
//        case .rating: return PhotoShareCellItemView(item: item)
//        case .title: return PhotoShareCellItemView(item: item)
//        case .subtitle: return PhotoShareCellItemView(item: item)
//        case .review:  return PhotoShareCellItemView(item: item)
//        default:
//            return PhotoShareCellItemView(item: item)
//        }
//    }
//}

struct PhotoShareCellItemView: View {
    let item: PhotoShareSelectItem
    
    var body: some View {
        GeometryReader { geo in
            
            if item.type == .review {
                VStack {
                    ShareThumbnailImageSideBySideView(item: item)
                    Spacer().frame(height: 60)
                }
                ZStack {
                    VStack {
                        Spacer()
                        ShareThumbnailBottom(item: item)
                    }
                }
            } else {
                VStack {
                    ShareThumbnailImageSideBySideView(item: item)
                    ShareThumbnailBottom(item: item)
                }
            }
        }
    }
}

struct ShareThumbnailImageSideBySideView: View {
    let item: PhotoShareSelectItem
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TimelinePhotoCell(photo: item.photo)
                        .frame(width: geo.size.width / 2)
                        .clipped()
                        .overlay(ZStack {
                            if item.type == .subtitle {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("BEFORE").foregroundColor(.white).font(Font.semibold17).padding(8).background(Color.turquoiseBlue)
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                }
                            }
                        })
                    
                    TimelinePhotoCell(photo: item.comparedPhoto)
                        //.resizable()
                        //.aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width / 2)
                        .clipped()
                        .overlay(Color.black.opacity(0.3))
                        .overlay(ZStack {
                            if item.type == .subtitle {
                                VStack(alignment: .trailing) {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("AFTER").foregroundColor(.white).font(Font.semibold17).padding(8).background(Color.turquoiseBlue)
                                    }
                                }
                            }
                        })
                }
            }
        }
    }
}

struct ShareThumbnailBottom: View {
    let item: PhotoShareSelectItem
    var body: some View {
        
        if item.type == .review {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    ShareReviewBottom().frame(width: geo.size.width + 2, height: 120).background(Color.clear)
                }
            }
        } else {
            HStack {
                Spacer()
                    .frame(width: 15)
                Image("logo-pabau")
                Spacer()
                    switch item.type {
                    case .rating: ShareRatingBottom(rating: 4)
                    case .subtitle: ShareSubtitleBottom()
                    case .review: ShareReviewBottom()
                    case .title(let title): ShareTitleBottom(title: title)
                    }
                Spacer()
                    .frame(width: 10)
                    
            }
            .frame(height: 60)
            .background(Color.gray249)
        }
    }
}

struct ShareTitleBottom: View {
    
    let title: String
    
    var body: some View {
        Text(title).font(Font.semibold16)
    }
}

struct ShareRatingBottom: View {
    
    @State var rating: Int
    
    var body: some View {
        ShareStarRating(rating: $rating)
    }
}

struct ShareSubtitleBottom: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Concept Facelift Results").font(Font.semibold16).foregroundColor(Color.black42)
            Text("www.conceptfacelit.com").font(Font.medium12).foregroundColor(Color.black42)
        }
    }
}

struct ShareReviewBottom: View {
    
    var body: some View {
        HStack(spacing: 0) {
            
            VStack {
                Spacer()
                ZStack {
                    Spacer()
                    Image("logo-pabau").padding().background(Color.gray249)
                }.frame(height: 68).background(Color.gray249)
                
            }
            
            VStack(alignment: .leading) {
                Group {
                    Image("ico-quote")
                    Text("I have been going to this place for 2 number of years, and I like what they do to my face")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(Font.semibold14)
                        .lineSpacing(3)
                        .offset(x: 0, y: -28)
                }.padding()
                
            }.background(Color.gray249)
        }
    }
}

struct ShareStarRating: View {
    
    @Binding var rating: Int
    
    var label = ""
    var maximumRating = 5
    
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    
    var body: some View {
        HStack {
            if !label.isEmpty {
                Text(label)
            }
            
            ForEach(1..<maximumRating + 1) { number in
                self.image(for: number)
                    .foregroundColor(number > rating ? offColor : onColor)
                    .onTapGesture {
                        self.rating = number
                    }
            }
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}
