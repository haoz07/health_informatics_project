//
//  RashLog.swift
//  artest
//
//  Created by Hao Zhang on 11/9/18.
//  Copyright © 2018 Hao Zhang. All rights reserved.
//

import Foundation
import UIKit

struct RashLog: Codable {
    var closeup: Data
    var overview: Data
    var desField: String
    var dateField: String
    var size: String
    var painful: Bool
    var bleeding: Bool
    var growing: Bool
}
