import KeyboardCore
import SwiftUI

struct DiagnosticsFilterBar: View {
    let options: [(String, Logger.Category?)]
    let selectedCategory: Logger.Category?
    let onSelect: (Logger.Category?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.0) { label, category in
                    Button {
                        onSelect(category)
                    } label: {
                        Text(label)
                            .font(.caption)
                            .fontWeight(selectedCategory == category ? .semibold : .regular)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                selectedCategory == category
                                    ? Color.primary.opacity(0.14)
                                    : Color(.systemGray5)
                            )
                            .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.bar)

        Divider()
    }
}
