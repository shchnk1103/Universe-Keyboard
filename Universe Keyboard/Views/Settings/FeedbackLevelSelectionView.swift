import KeyboardCore
import SwiftUI

struct FeedbackLevelSelectionView: View {
    @Binding var selection: Int
    let onSelect: (KeyboardFeedbackLevel) -> Void

    var body: some View {
        ForEach(KeyboardFeedbackLevel.allCases) { level in
            Button {
                guard selection != level.rawValue else { return }
                selection = level.rawValue
                onSelect(level)
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(level.title)
                            .foregroundStyle(.primary)
                        Text(level.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if selection == level.rawValue {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.tint)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
