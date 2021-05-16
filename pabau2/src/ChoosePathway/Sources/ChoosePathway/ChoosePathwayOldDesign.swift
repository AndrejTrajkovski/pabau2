//struct ChoosePathwayListContent: View {
//    let bottomLeading: Image
//    let numberOfSteps: Int
//    let title: String
//    let subtitle: String
//    let bulletPoints: [String]
//    let btnTxt: String
//    let style: ListFrameStyle
//    let btnAction: () -> Void
//
//    init(
//        _ style: ListFrameStyle,
//        _ bottomLeading: Image,
//        _ numberOfSteps: Int,
//        _ title: String,
//        _ subtitle: String,
//        _ bulletPoints: [String],
//        _ btnTxt: String,
//        _ btnAction: @escaping () -> Void) {
//        self.bottomLeading = bottomLeading
//        self.numberOfSteps = numberOfSteps
//        self.title = title
//        self.subtitle = subtitle
//        self.bulletPoints = bulletPoints
//        self.btnTxt = btnTxt
//        self.btnAction = btnAction
//        self.style = style
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            PathwayCellHeader(bottomLeading, numberOfSteps)
//            Text(title).font(.semibold20).foregroundColor(.black42)
//            Text(subtitle).font(.medium15)
//            PathwayBulletList(bulletPoints: bulletPoints, bgColor: style.bgColor)
//            Spacer()
//            if style == .blue {
//                PrimaryButton(btnTxt, btnAction)
//            } else {
//                SecondaryButton(btnTxt, btnAction)
//            }
//        }
//    }
//}

//struct PathwayBulletList: View {
//    let bulletPoints: [String]
//    let bgColor: Color
//    var body: some View {
//        List {
//            ForEach(bulletPoints, id: \.self) { bulletPoint in
//                HStack {
//                    Circle()
//                        .fill(Color.grey216)
//                        .frame(width: 6.6, height: 6.6)
//                    Text(bulletPoint)
//                        .font(.regular16)
//                }
//                .listRowInsets(EdgeInsets())
//                .listRowBackground(self.bgColor)
//            }
//        }
//    }
//}

//struct PathwayCellHeader: View {
//    let image: Image
//    let numberOfSteps: Int
//    init(_ image: Image, _ numberOfSteps: Int) {
//        self.image = image
//        self.numberOfSteps = numberOfSteps
//    }
//    var body: some View {
//        ZStack {
//            image.font(Font.regular45).foregroundColor(.blue2)
//                .frame(minWidth: 0, maxWidth: .infinity,
//                             minHeight: 0, maxHeight: .infinity,
//                             alignment: .leading)
//            Spacer()
//            HStack {
//                Image(systemName: "list.bullet").foregroundColor(.blue2)
//                Text(String("\(numberOfSteps)")).font(.semibold17)
//            }.frame(minWidth: 0, maxWidth: .infinity,
//                            minHeight: 0, maxHeight: .infinity,
//                            alignment: .topTrailing)
//        }
//        .frame(height: 54)
//    }
//}
