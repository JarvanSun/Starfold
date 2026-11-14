//
//  AppDelegate.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    let orientationLock = OrientationLock()

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        orientationLock.supportedOrientations
    }
}
