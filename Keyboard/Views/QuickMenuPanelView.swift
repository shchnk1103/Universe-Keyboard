import KeyboardCore
import UIKit

// MARK: - Quick menu presentation model (PB-016 PR-2)
//
// Pure view + row model + frozen state semantics (r3 §3.2/§4.1/§4.2/§5.1).
// No controller or business state lives here; `KeyboardViewController+QuickMenu.swift`
// owns the mutable machine and wiring.

/// The four-state quick-menu presentation machine (r3 §3.2/§4.2).
/// `nonisolated`: pure value semantics, usable from any isolation domain
/// (the controller wiring, the panel, and unit tests alike).
nonisolated enum QuickMenuPresentationState: Equatable {
    case idle
    case menuOpening
    case closing
    case layoutSwitching

    /// A panel (or its teardown) is currently up over the covered keys.
    var isPanelPresented: Bool {
        switch self {
        case .idle, .layoutSwitching: return false
        case .menuOpening, .closing: return true
        }
    }

    /// `forceDismissQuickMenu` behavior table (r3 §4.2). `.idle` with a
    /// completed teardown is the ONLY no-op; opening/closing force a
    /// synchronous teardown; `layoutSwitching` only tears the panel down and
    /// the in-flight layout transaction releases through §3.2 paths #4–#6.
    var forceDismissOutcome: QuickMenuForceDismissOutcome {
        switch self {
        case .idle: return .none
        case .menuOpening, .closing, .layoutSwitching: return .teardownPanel
        }
    }
}

nonisolated enum QuickMenuForceDismissOutcome: Equatable {
    case none
    case teardownPanel
}

/// Pure entry-visibility recompute (r3 §4.1): reads the quick-menu state plus
/// the mutually exclusive chrome states. The number-pad shortcut strip's
/// early-return branch is covered because the single hook runs before it.
nonisolated enum QuickMenuEntryVisibility {
    static func isVisible(
        quickMenuState: QuickMenuPresentationState,
        isCandidateExpanded: Bool,
        isPinyinPathExpanded: Bool,
        isNumberPadShortcutStripActive: Bool,
        isRecoveryBlocked: Bool
    ) -> Bool {
        guard !isCandidateExpanded, !isPinyinPathExpanded, !isNumberPadShortcutStripActive,
            !isRecoveryBlocked
        else { return false }
        // While the menu is open the entry stays visible: tapping it again is
        // dismiss path #1. During closing/layoutSwitching the entry is down.
        switch quickMenuState {
        case .idle, .menuOpening: return true
        case .closing, .layoutSwitching: return false
        }
    }
}

/// The frozen minimal set: exactly four rows (design r1 §3.2).
nonisolated enum QuickMenuRow: CaseIterable, Equatable, Sendable {
    case layoutToggle
    case simplification
    case keyClick
    case haptic

    var title: String {
        switch self {
        case .layoutToggle: return "切换布局"
        case .simplification: return "简繁切换"
        case .keyClick: return "按键音"
        case .haptic: return "触感反馈"
        }
    }

    var accessibilityIdentifierValue: String {
        switch self {
        case .layoutToggle: return "quickMenu.row.layoutToggle"
        case .simplification: return "quickMenu.row.simplification"
        case .keyClick: return "quickMenu.row.keyClick"
        case .haptic: return "quickMenu.row.haptic"
        }
    }
}

/// One menu row's display state. `isEnabled == false` renders the row
/// untappable and unread as a value (capability-gated rows fail closed).
nonisolated struct QuickMenuRowModel: Equatable, Sendable {
    let row: QuickMenuRow
    let title: String
    let valueText: String?
    let isEnabled: Bool
}

/// T/S capability resolution (r3 §2.1): ice owns `traditionalization` with
/// states ["简","繁"]; luna owns `simplification` with states ["繁","简"].
/// Everything else (incl. ambiguous schemas) resolves to `nil` → row disabled.
nonisolated struct QuickMenuSimplificationCapability: Equatable, Sendable {
    let optionName: String
    /// `true` when the engine option value `true` means traditional output.
    let engineValueMeansTraditional: Bool

    static func resolve(schemaID: String) -> QuickMenuSimplificationCapability? {
        switch RimeSchemeCapabilityMatrix.normalizeRegisteredSchemaID(schemaID) {
        case "rime_ice":
            return QuickMenuSimplificationCapability(
                optionName: "traditionalization", engineValueMeansTraditional: true)
        case "luna_pinyin":
            return QuickMenuSimplificationCapability(optionName: "simplification", engineValueMeansTraditional: false)
        default:
            return nil
        }
    }

    /// Maps an engine option value onto the user-facing 繁/简 axis.
    func engineValueMeansTraditional(_ engineValue: Bool) -> Bool {
        engineValueMeansTraditional ? engineValue : !engineValue
    }
}

/// Three-state T/S rollback policy (r3 §5.1): `confirmed(value)` commits and
/// may write the preference back; a real `false` value is the legitimate
/// simplified result (case 2), not a failure; `sessionInvalid`/`bridgeError`
/// roll the row back and never write the preference.
nonisolated enum QuickMenuSimplificationResolution: Equatable, Sendable {
    case confirmed(engineValue: Bool)
    case rolledBack(previousEngineValue: Bool)

    var shouldWritePreferenceBack: Bool {
        if case .confirmed = self { return true }
        return false
    }

    var shouldRollBackRowValue: Bool {
        if case .rolledBack = self { return true }
        return false
    }

    static func resolve(
        outcome: RimeOptionResult,
        previousEngineValue: Bool
    ) -> QuickMenuSimplificationResolution {
        switch outcome {
        case .confirmed(let value):
            return .confirmed(engineValue: value)
        case .sessionInvalid, .bridgeError:
            return .rolledBack(previousEngineValue: previousEngineValue)
        }
    }
}

/// The 4-row quick menu panel: a plain, unconfigured-button stack (anti-material
/// rule: no card material fill, `UILabel`-style text, no `UIButton.Configuration`).
/// Instant presentation — no animation dependency (Reduce Motion safe).
@MainActor
final class QuickMenuPanelView: UIView {
    var onSelectRow: ((QuickMenuRow) -> Void)?
    var onDismissRequest: (() -> Void)?

    private var rowButtons: [QuickMenuRow: UIButton] = [:]
    private let stackView = UIStackView()

    init(models: [QuickMenuRowModel]) {
        super.init(frame: .zero)
        configureContainer()
        configureStackView()
        // `update` rebuilds and installs the row accessibility elements; the
        // container itself stays unfocusable (isAccessibilityElement = false).
        update(models: models)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureContainer() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true
        isAccessibilityElement = false
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
    }

    private func configureStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }

    /// Rebuilds the rows from the given models. The panel redraws from the
    /// settings snapshot on every open (no cached UI values, design r1 §3.2).
    func update(models: [QuickMenuRowModel]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowButtons.removeAll()
        var elements: [UIView] = []
        for model in models {
            let button = makeRowButton(model: model)
            rowButtons[model.row] = button
            stackView.addArrangedSubview(button)
            elements.append(button)
        }
        accessibilityElements = elements
    }

    private func makeRowButton(model: QuickMenuRowModel) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemGray.withAlphaComponent(0.001)
        button.setTitle(model.title, for: .normal)
        button.setTitleColor(model.isEnabled ? .label : .secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.isEnabled = model.isEnabled
        button.accessibilityIdentifier = model.row.accessibilityIdentifierValue
        button.accessibilityLabel = model.title
        // A disabled capability-gated row reads no state value (fail-closed).
        button.accessibilityValue = model.isEnabled ? model.valueText : nil
        button.accessibilityTraits = model.isEnabled ? [.button] : [.button, .notEnabled]
        button.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)

        // Row hit areas honor the frozen minimum touch size.
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(
                equalToConstant: max(44, KeyboardDesignTokens.CandidateBar.minimumTouchSize))
        ])
        return button
    }

    @objc private func rowTapped(_ sender: UIButton) {
        guard let row = rowButtons.first(where: { $0.value === sender })?.key else { return }
        onSelectRow?(row)
    }

    /// Dismiss path #3: VoiceOver escape routes to the controller dismiss.
    override func accessibilityPerformEscape() -> Bool {
        onDismissRequest?()
        return true
    }
}
