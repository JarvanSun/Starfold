//
//  XboxButtonSettingsSourceStub.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

@testable import StreamKit

@MainActor
final class XboxButtonSettingsSourceStub {
    var owner: XboxButtonOwner = .system
    var isReadFailing = false

    private(set) var openedSettingsCount = 0
    private(set) var readCount = 0

    private var onChange: (@MainActor () -> Void)?

    var source: XboxButtonSettingsSource {
        .init(
            readOwner: {
                self.readCount += 1
                if self.isReadFailing { throw CancellationError() }

                return self.owner
            },
            openSettings: { self.openedSettingsCount += 1 },
            observeChanges: { onChange in
                self.onChange = onChange
                return Task {}
            }
        )
    }

    func sendChange() {
        onChange?()
    }
}
