//
//  XboxButtonOwnerTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController
import Testing

@testable import StreamKit

#if os(macOS)
struct XboxButtonOwnerTests {
    @available(macOS 27.0, *)
    @Test(arguments: [
        (GCControllerHomeButtonSettingsManager.InAppAction.defer, XboxButtonOwner.stream),
        (.disabled, .stream),
        (.systemDefault, .system),
        (.unavailable, .unknown),
    ])
    func initFromInAppActionThenNamesWhoGetsTheButton(
        _ action: GCControllerHomeButtonSettingsManager.InAppAction,
        _ expected: XboxButtonOwner
    ) {
        #expect(XboxButtonOwner(inAppAction: action) == expected)
    }
}
#endif
