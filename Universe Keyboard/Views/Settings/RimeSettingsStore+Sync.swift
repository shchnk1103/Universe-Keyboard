import KeyboardCore

extension RimeSettingsStore {
    /// 跨平台包中的稳定字段名。字段名一旦发布不可随 Swift 属性重命名而变化。
    func portableSyncValues() -> [String: RimeSyncScalar] {
        var values: [String: RimeSyncScalar] = [
            "rime.activeSchema": .string(activeSchemaID),
            "rime.pageSize": .int(Int(pageSize)),
            "rime.simplified": .bool(simplified),
            "rime.fuzzy.enabled": .bool(fuzzyEnabled),
            "rime.fuzzy.zhZ": .bool(fuzzyZhZEnabled),
            "rime.fuzzy.chC": .bool(fuzzyChCEnabled),
            "rime.fuzzy.shS": .bool(fuzzyShSEnabled),
            "rime.fuzzy.nL": .bool(fuzzyNLEnabled),
            "rime.advanced.enabled": .bool(advancedInputMasterEnabled),
            "rime.learning.lunaPinyin": .bool(lunaPinyinUserDictionaryEnabled),
            "rime.learning.rimeIce": .bool(rimeIceUserDictionaryEnabled),
        ]

        for feature in RimeAdvancedInputFeature.allCases {
            values["rime.advanced.feature.\(feature.rawValue)"] = .bool(
                isAdvancedInputFeatureEnabled(feature)
            )
        }
        return values
    }

    /// 在主 App 中应用已验证的远端设置，并沿用现有部署入口。
    /// 未识别字段会被同步层保留，但不会错误写入 UserDefaults。
    func applyPortableSyncValues(_ values: [String: RimeSyncScalar]) async {
        if let value = values["rime.pageSize"]?.intValue {
            pageSize = Double(min(max(value, 5), 20))
        }
        if let value = values["rime.simplified"]?.boolValue { simplified = value }
        if let value = values["rime.fuzzy.enabled"]?.boolValue { fuzzyEnabled = value }
        if let value = values["rime.fuzzy.zhZ"]?.boolValue { fuzzyZhZEnabled = value }
        if let value = values["rime.fuzzy.chC"]?.boolValue { fuzzyChCEnabled = value }
        if let value = values["rime.fuzzy.shS"]?.boolValue { fuzzyShSEnabled = value }
        if let value = values["rime.fuzzy.nL"]?.boolValue { fuzzyNLEnabled = value }
        if let value = values["rime.advanced.enabled"]?.boolValue { advancedInputMasterEnabled = value }
        if let value = values["rime.learning.lunaPinyin"]?.boolValue {
            lunaPinyinUserDictionaryEnabled = value
        }
        if let value = values["rime.learning.rimeIce"]?.boolValue {
            rimeIceUserDictionaryEnabled = value
        }

        for feature in RimeAdvancedInputFeature.allCases {
            let key = "rime.advanced.feature.\(feature.rawValue)"
            if let value = values[key]?.boolValue {
                advancedInputFeatureEnabled[feature] = value
            }
        }

        savePreferences()
        saveFuzzyPinyinSettings()
        saveAdvancedInputSettings()
        saveUserDictionarySettings()

        if let schemaID = values["rime.activeSchema"]?.stringValue,
           schemaID != activeSchemaID,
           schemas.contains(where: { $0.schemaID == schemaID && $0.installed })
        {
            await switchToSchema(schemaID)
        } else {
            await triggerPendingDeploymentIfNeeded()
        }
    }
}
