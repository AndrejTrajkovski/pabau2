import SwiftUI
import ComposableArchitecture


struct PhotoShareCellItem: View {
    let item: PhotoShareSelectItem
    
    var body: some View {
        switch item.type {
        case .rating: return PhotoShareCellItemView(item: item)
        case .title: return PhotoShareCellItemView(item: item)
        case .subtitle: return PhotoShareCellItemView(item: item)
        case .review:  return PhotoShareCellItemView(item: item)
        default:
            return PhotoShareCellItemView(item: item)
        }
    }
}

struct PhotoShareCellItemView: View {
    let item: PhotoShareSelectItem
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ShareThumbnailImageSideBySideView(item: item)
                ShareThumbnailBottom(item: item)
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
                    //Image(item.photo.basePhoto)
                      //  .resizable()
//                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width / 2)
                        .clipped()
                    TimelinePhotoCell(photo: item.comparedPhoto)
                        //.resizable()
                        //.aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width / 2)
                        .clipped()
                }
            }
        }
    }
}

struct ShareThumbnailBottom: View {
    let item: PhotoShareSelectItem
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 15)
            Image("logo-pabau")
            Spacer()
                switch item.type {
                case .rating: ShareRattingBottom()
                case .subtitle: ShareSubtitleBottom()
                default: ShareTitleBottom()
                }
            Spacer()
                .frame(width: 10)
                
        }.background(Color.white)
        .frame(height: 60)
    }
}

struct ShareTitleBottom: View {
    var body: some View {
        Text("20 Days Difference")
    }
}

struct ShareRattingBottom: View {
    var body: some View {
        Text("Ratting")
    }
}

struct ShareSubtitleBottom: View {
    var body: some View {
        VStack {
            Text("Concept Facelift Results")
            Text("www.conceptfacelit.com")
        }
    }
}
