//
//  UIViewControllerExtension.swift
//  SeSAC4TheaterMap
//
//  Created by Minho on 1/15/24.
//

import UIKit

extension UIViewController: ReusableProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}
