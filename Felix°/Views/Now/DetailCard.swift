import SwiftUI

/// A native grouped container for detail-sheet content.
struct DetailCard<Content: View>: View {
	private let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
		GroupBox {
			VStack(alignment: .leading, spacing: 12) {
				content
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}
