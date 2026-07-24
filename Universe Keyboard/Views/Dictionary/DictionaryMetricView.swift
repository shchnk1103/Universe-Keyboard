import SwiftUI

/// Dictionary overview metric; thin wrapper over shared `MetricCell`.
struct DictionaryMetricView: View {
    let value: String
    let label: String

    var body: some View {
        MetricCell(value: value, label: label)
    }
}
