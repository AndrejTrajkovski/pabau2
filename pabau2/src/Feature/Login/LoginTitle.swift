import SwiftUI
import Util

struct LoginTitle: View {
	var body: some View {
		VStack(alignment: .leading) {
			Text(Texts.helloAgain)
				.foregroundColor(.deepSkyBlue)
				.font(.bigMediumFont)
			Text(Texts.welcomeBack)
				.foregroundColor(.blackTwo)
				.font(.bigSemibolFont)
		}
	}
}
