//
//  HINavigationController.swift
//  HackIllinois
//
//  Created by Rauhul Varma on 2/21/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//

import Foundation
import UIKit

class HINavigationController: UINavigationController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        title = rootViewController.title
        NotificationCenter.default.addObserver(self, selector: #selector(refreshForThemeChange), name: .themeDidChange, object: nil)
        refreshForThemeChange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used.")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Themeable
    @objc func refreshForThemeChange() {
        navigationBar.tintColor = HIApplication.Palette.current.accent
        navigationBar.barTintColor = HIApplication.Palette.current.background
        navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: HIApplication.Palette.current.primary as Any
        ]

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        HIApplication.Palette.current.background.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        navigationBar.setBackgroundImage(image, for: .default)
    }
}
