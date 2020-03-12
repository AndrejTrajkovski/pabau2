import SwiftUI
import Util

struct LoginTitle: View {
	var body: some View {
		VStack(alignment: .leading) {
			Text(Texts.helloAgain)
				.foregroundColor(.deepSkyBlue)
				.font(.medium45)
			Text(Texts.welcomeBack)
				.foregroundColor(.blackTwo)
				.font(.semibold45)
		}
	}
}
