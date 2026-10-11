import Foundation
import XCTest

@testable import KeyboardCore

final class DiagnosticsJournalV6WriterTests: XCTestCase {
    func testDefaultRuntimeKeepsV5AndRejectsWakeMarkers() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try await prepareRoot(at: rootURL)

        let processInstanceID = UUID()
        let runtime = DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            processInstanceID: processInstanceID,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            flushDelay: 5
        )

        XCTAssertEqual(DiagnosticEvent.schemaVersion, 5)
        XCTAssertFalse(runtime.recordKeyboardLifecycle(.viewDidAppear))
        XCTAssertFalse(runtime.recordRimeResume(.started))
        XCTAssertFalse(runtime.recordTextProxyOperation(operation: .insertText, phase: .entered))
        runtime.record(code: .keyboardLifecyclePhaseChanged, category: .display)
        runtime.record(code: .rimeResumePhaseChanged, category: .engine)
        runtime.record(code: .textProxyOperationPhaseChanged, category: .display)
        runtime.record(code: .presentationAppeared, category: .display)
        runtime.requestFlush()

        let mainAppRuntime = DiagnosticsJournalRuntime(
            origin: .mainApp,
            processInstanceID: UUID(),
            isMainAppWriter: true,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            writerVersion: .v6,
            flushDelay: 5
        )
        XCTAssertFalse(mainAppRuntime.recordKeyboardLifecycle(.viewDidAppear))
        XCTAssertFalse(mainAppRuntime.recordRimeResume(.started))
        XCTAssertFalse(
            mainAppRuntime.recordTextProxyOperation(operation: .insertText, phase: .entered)
        )

        let snapshot = try await waitForSnapshot(at: rootURL, expectedEventCount: 1)
        XCTAssertTrue(snapshot.completeness.isComplete)
        XCTAssertEqual(snapshot.events.map(\.code), [.presentationAppeared])
        XCTAssertEqual(snapshot.events.map(\.schemaVersion), [5])
    }

    func testV6RuntimeWritesMarkersAndPromotesExistingFamiliesWithoutTouchingHistory() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        let mainAppID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let historicalExtensionID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let historyTimestamp = Date(timeIntervalSince1970: 1_723_123_456)
        let mainWriter = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: mainAppID,
            isMainAppWriter: true
        )
        try await mainWriter.prepareRootIfOwnedByMainApp()
        try await mainWriter.append([
            makeEvent(
                sequence: 2,
                processInstanceID: mainAppID,
                timestamp: historyTimestamp
            )
        ])

        var v3Record = rawEventObject(
            version: 3,
            origin: .mainApp,
            processID: mainAppID,
            sequence: 1
        )
        v3Record["utcTimestamp"] = "2024-08-08T12:24:16Z"
        let mainSegment = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: rootURL.appendingPathComponent("g1/open"),
                includingPropertiesForKeys: nil
            ).first { $0.lastPathComponent.hasPrefix("main_app-") }
        )
        try appendRawRecord(v3Record, to: mainSegment)

        var v4Record = rawEventObject(
            version: 4,
            origin: .keyboardExtension,
            processID: historicalExtensionID,
            sequence: 4
        )
        v4Record["utcTimestamp"] = "2024-08-08T12:24:16Z"
        v4Record["code"] = DiagnosticEvent.Code.keyboardLifecyclePhaseChanged.rawValue
        v4Record["level"] = Logger.Level.debug.rawValue
        v4Record["category"] = Logger.Category.display.rawValue
        v4Record["keyboardLifecyclePayload"] = ["phase": "view_did_appear"]
        let extensionHistorySegment =
            rootURL
            .appendingPathComponent("g1/open", isDirectory: true)
            .appendingPathComponent(
                "keyboard_extension-\(historicalExtensionID.uuidString)-20240808T12-0.jsonl"
            )
        try appendRawRecord(v4Record, to: extensionHistorySegment)

        let originalMainBytes = try Data(contentsOf: mainSegment)
        let originalExtensionBytes = try Data(contentsOf: extensionHistorySegment)
        let runtimeID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let runtime = DiagnosticsJournalRuntime(
            origin: .keyboardExtension,
            processInstanceID: runtimeID,
            isMainAppWriter: false,
            rootURL: { rootURL },
            isCategoryEnabled: { _ in true },
            writerVersion: .v6,
            flushDelay: 5
        )

        // A suspended tail is counted and later emitted through the same v6 writer.
        runtime.suspendForExtensionLifecycle()
        runtime.record(code: .presentationAppeared, category: .display)
        runtime.resumeForExtensionLifecycle()
        runtime.record(
            code: .presentationFrame,
            category: .display,
            fields: [.count(.revision, 7)]
        )

        let typoPayload = DiagnosticEvent.TypoRecallQueryPayload(
            operationOrdinal: 3,
            stage: .stageTwo,
            readiness: .ready,
            resultState: .candidatesReturned,
            returnedCandidateBucket: .zero,
            disposition: .discardedAfterFacade,
            facadeElapsedMicroseconds: 7,
            durationState: .measured
        )
        runtime.record(
            code: .typoRecallQueryMeasured,
            category: .performance,
            fields: [.typoRecallQuery(typoPayload)]
        )

        let schemeContext = DiagnosticEvent.SchemeDeliveryContext(
            operationID: UUID(),
            artifact: .wanxiang1759CNB9BFCGitHub73F8,
            stagedIdentity: .wanxiang1759Plan1Post1
        )
        let schemePayload = DiagnosticEvent.SchemeDeliveryPayload.terminal(
            .init(context: schemeContext, result: .completed)
        )
        runtime.recordSchemeDelivery(schemePayload)

        let routePayload = DiagnosticEvent.RuntimeRoutePhaseEvent(
            operationID: UUID(),
            phase: .fallbackDeploy,
            result: .succeeded,
            schema: .lunaPinyin,
            layout: .twentySixKey,
            state: .ready,
            elapsedMilliseconds: 37
        )
        runtime.recordRuntimeRoute(routePayload)

        let syncContext = DiagnosticEvent.RimeSyncContext(
            operationID: UUID(),
            source: .backgroundAutomatic
        )
        let syncPayload = DiagnosticEvent.RimeSyncPayload.terminal(
            .init(context: syncContext, result: .completed)
        )
        runtime.recordRimeSync(syncPayload)

        let appearanceID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        XCTAssertTrue(
            runtime.recordKeyboardLifecycle(.viewDidAppear, appearanceID: appearanceID)
        )
        XCTAssertTrue(
            runtime.recordRimeResume(
                .started,
                sessionEpoch: .max,
                revision: 13,
                appearanceID: appearanceID
            )
        )
        XCTAssertTrue(
            runtime.recordRimeResume(
                .failed,
                failure: .schemaSelectionFailed,
                sessionEpoch: 8,
                revision: 14,
                appearanceID: appearanceID
            )
        )
        XCTAssertTrue(
            runtime.recordTextProxyOperation(
                operation: .insertText,
                phase: .returned,
                appearanceID: appearanceID,
                actionSequence: 91
            )
        )

        // Generic recording cannot create marker records, and typed RIME rejects a bad pair.
        runtime.record(code: .keyboardLifecyclePhaseChanged, category: .display)
        runtime.record(code: .rimeResumePhaseChanged, category: .engine)
        runtime.record(code: .textProxyOperationPhaseChanged, category: .display)
        XCTAssertFalse(runtime.recordRimeResume(.failed))
        XCTAssertFalse(runtime.recordRimeResume(.started, failure: .engineUnavailable))
        runtime.requestFlush()

        let snapshot = try await waitForSnapshot(at: rootURL, expectedV6EventCount: 10)
        XCTAssertTrue(snapshot.completeness.isComplete)
        XCTAssertEqual(Set(snapshot.events.map(\.schemaVersion)), Set([3, 4, 5, 6]))
        XCTAssertEqual(snapshot.events.filter { $0.schemaVersion == 6 }.count, 10)

        let newEvents = snapshot.events.filter {
            $0.schemaVersion == 6 && $0.processInstanceID == runtimeID
        }
        XCTAssertEqual(newEvents.count, 10)
        XCTAssertEqual(
            newEvents.map(\.localSequence).sorted(),
            Array(UInt64(2)...UInt64(11))
        )
        XCTAssertEqual(
            Set(newEvents.map(\.code)),
            Set([
                .journalResumed,
                .presentationFrame,
                .typoRecallQueryMeasured,
                .schemeDeliveryTerminal,
                .runtimeRoutePhaseChanged,
                .rimeSyncTerminal,
                .keyboardLifecyclePhaseChanged,
                .rimeResumePhaseChanged,
                .textProxyOperationPhaseChanged,
            ])
        )

        let healthEvent = try XCTUnwrap(newEvents.first { $0.code == .journalResumed })
        XCTAssertTrue(healthEvent.fields.contains(.count(.droppedEventCount, 1)))
        XCTAssertTrue(healthEvent.fields.contains(.reason(.suspended)))
        XCTAssertEqual(
            newEvents.first { $0.code == .typoRecallQueryMeasured }?.fields,
            [.typoRecallQuery(typoPayload)]
        )
        XCTAssertEqual(
            newEvents.first { $0.code == .schemeDeliveryTerminal }?.schemeDeliveryPayload,
            schemePayload
        )
        XCTAssertEqual(
            newEvents.first { $0.code == .runtimeRoutePhaseChanged }?.runtimeRoutePayload,
            routePayload
        )
        XCTAssertEqual(
            newEvents.first { $0.code == .rimeSyncTerminal }?.rimeSyncPayload,
            syncPayload
        )

        let lifecycle = try XCTUnwrap(newEvents.first { $0.code == .keyboardLifecyclePhaseChanged })
        XCTAssertEqual(lifecycle.origin, .keyboardExtension)
        XCTAssertEqual(lifecycle.level, .debug)
        XCTAssertEqual(lifecycle.category, .display)
        XCTAssertEqual(lifecycle.appearanceID, appearanceID)
        XCTAssertTrue(lifecycle.fields.isEmpty)
        XCTAssertEqual(lifecycle.keyboardLifecyclePayload?.phase, .viewDidAppear)

        let rimeEvents = newEvents.filter { $0.code == .rimeResumePhaseChanged }
        XCTAssertEqual(rimeEvents.count, 2)
        XCTAssertTrue(
            rimeEvents.allSatisfy {
                $0.origin == .keyboardExtension && $0.level == .debug
                    && $0.category == .engine && $0.fields.isEmpty
                    && $0.appearanceID == appearanceID
            })
        XCTAssertTrue(
            rimeEvents.contains {
                $0.rimeResumePayload
                    == .init(
                        phase: .started,
                        sessionEpoch: .max,
                        revision: 13
                    )
            })
        XCTAssertTrue(
            rimeEvents.contains {
                $0.rimeResumePayload
                    == .init(
                        phase: .failed,
                        failure: .schemaSelectionFailed,
                        sessionEpoch: 8,
                        revision: 14
                    )
            })

        let textProxy = try XCTUnwrap(newEvents.first { $0.code == .textProxyOperationPhaseChanged })
        XCTAssertEqual(textProxy.level, .debug)
        XCTAssertEqual(textProxy.category, .display)
        XCTAssertEqual(textProxy.appearanceID, appearanceID)
        XCTAssertTrue(textProxy.fields.isEmpty)
        XCTAssertEqual(textProxy.actionSequence, 91)
        XCTAssertEqual(
            textProxy.textProxyPayload,
            .init(operation: .insertText, phase: .returned)
        )

        XCTAssertEqual(try Data(contentsOf: mainSegment), originalMainBytes)
        XCTAssertEqual(try Data(contentsOf: extensionHistorySegment), originalExtensionBytes)

        XCTAssertNotNil(snapshot.events.first { $0.schemaVersion == 3 })
        let historicalV4 = try XCTUnwrap(
            snapshot.events.first {
                $0.schemaVersion == 4 && $0.processInstanceID == historicalExtensionID
            }
        )
        let v6Writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .keyboardExtension,
            processInstanceID: runtimeID,
            isMainAppWriter: false,
            writerVersion: .v6
        )
        let sameOriginV3 = try decodeEvent(
            rawEventObject(
                version: 3,
                origin: .keyboardExtension,
                processID: runtimeID,
                sequence: 99
            )
        )
        try await assertWriteRejected(sameOriginV3, by: v6Writer)
        try await assertWriteRejected(historicalV4, by: v6Writer)
    }

    func testV6WriterRechecksDecodedPayloadBeforeWriting() async throws {
        let rootURL = makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootURL) }
        try await prepareRoot(at: rootURL)

        let processInstanceID = UUID()
        let validRoute = DiagnosticEvent.RuntimeRoutePhaseEvent(
            operationID: UUID(),
            phase: .fallbackDeploy,
            result: .succeeded,
            schema: .lunaPinyin,
            layout: .twentySixKey,
            state: .ready,
            elapsedMilliseconds: 37
        )
        let validEvent = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_723_123_456),
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            localSequence: 1,
            code: .runtimeRoutePhaseChanged,
            level: .info,
            category: .deployment,
            runtimeRoutePayload: validRoute
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var rawEvent = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: encoder.encode(validEvent)) as? [String: Any]
        )
        var rawRoute = try XCTUnwrap(rawEvent["runtimeRoutePayload"] as? [String: Any])
        rawRoute["elapsedMilliseconds"] = -1
        rawEvent["runtimeRoutePayload"] = rawRoute

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedInvalidEvent = try decoder.decode(
            DiagnosticEvent.self,
            from: JSONSerialization.data(withJSONObject: rawEvent, options: [.sortedKeys])
        )
        XCTAssertEqual(decodedInvalidEvent.runtimeRoutePayload?.elapsedMilliseconds, -1)

        let v6Writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            isMainAppWriter: true,
            writerVersion: .v6
        )
        try await assertWriteRejected(decodedInvalidEvent, by: v6Writer)
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: rootURL.appendingPathComponent("g1/open").path
            )
        )

        var malformedGenericField = rawEventObject(
            version: 6,
            origin: .mainApp,
            processID: processInstanceID,
            sequence: 2
        )
        malformedGenericField["fields"] = [
            [
                "type": "count",
                "name": "revision",
                "integerValue": 1,
                "unreviewedValue": "must not persist",
            ]
        ]
        let malformedFieldData = try JSONSerialization.data(
            withJSONObject: malformedGenericField,
            options: [.sortedKeys]
        )
        XCTAssertEqual(
            DiagnosticEventWireValidator.rejectionReason(for: malformedFieldData),
            .unknownKey
        )
    }

    private func prepareRoot(at rootURL: URL) async throws {
        let writer = DiagnosticsJournalWriter(
            rootURL: rootURL,
            origin: .mainApp,
            isMainAppWriter: true
        )
        try await writer.prepareRootIfOwnedByMainApp()
    }

    private func makeTemporaryDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DiagnosticsJournalV6WriterTests-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func waitForSnapshot(
        at rootURL: URL,
        expectedEventCount: Int? = nil,
        expectedV6EventCount: Int? = nil
    ) async throws -> DiagnosticsJournalSnapshot {
        let reader = DiagnosticsJournalReader(rootURL: rootURL)
        for _ in 0..<100 {
            if let snapshot = try? await reader.latest() {
                let eventCountMatches = expectedEventCount.map { snapshot.events.count >= $0 } ?? true
                let v6CountMatches =
                    expectedV6EventCount.map {
                        snapshot.events.filter { $0.schemaVersion == 6 }.count >= $0
                    } ?? true
                if eventCountMatches && v6CountMatches {
                    return snapshot
                }
            }
            try await Task.sleep(for: .milliseconds(20))
        }
        XCTFail("Timed out waiting for the expected diagnostic records")
        return try await reader.latest()
    }

    private func rawEventObject(
        version: Int,
        origin: DiagnosticEvent.Origin,
        processID: UUID,
        sequence: UInt64
    ) -> [String: Any] {
        [
            "schemaVersion": version,
            "utcTimestamp": "2024-08-08T12:24:16Z",
            "monotonicNanoseconds": sequence,
            "origin": origin.rawValue,
            "processInstanceID": processID.uuidString,
            "localSequence": sequence,
            "code": DiagnosticEvent.Code.journalStarted.rawValue,
            "level": Logger.Level.info.rawValue,
            "category": Logger.Category.general.rawValue,
            "fields": [],
        ]
    }

    private func decodeEvent(_ object: [String: Any]) throws -> DiagnosticEvent {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(
            DiagnosticEvent.self,
            from: JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        )
    }

    private func appendRawRecord(_ object: [String: Any], to segmentURL: URL) throws {
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        if !FileManager.default.fileExists(atPath: segmentURL.path) {
            try FileManager.default.createDirectory(
                at: segmentURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            FileManager.default.createFile(atPath: segmentURL.path, contents: nil)
        }
        let handle = try FileHandle(forWritingTo: segmentURL)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
        try handle.write(contentsOf: Data([0x0A]))
    }

    private func makeEvent(
        sequence: UInt64,
        processInstanceID: UUID,
        timestamp: Date
    ) -> DiagnosticEvent {
        DiagnosticEvent(
            utcTimestamp: timestamp,
            monotonicNanoseconds: sequence,
            origin: .mainApp,
            processInstanceID: processInstanceID,
            localSequence: sequence,
            code: .journalStarted,
            level: .info,
            category: .general
        )
    }

    private func assertWriteRejected(
        _ event: DiagnosticEvent,
        by writer: DiagnosticsJournalWriter,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        do {
            try await writer.append([event])
            XCTFail("The v6 writer must reject this record", file: file, line: line)
        } catch let error as DiagnosticsJournalError {
            XCTAssertEqual(error, .writeFailed, file: file, line: line)
        }
    }
}
