//
//  Account.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 07/12/24.
//

import SwiftUI

// Account model
struct Account: Equatable {
    let name: String
    let logoUrl: URL?
    // You can add more properties like logo, color, etc.
    
    // Implement Equatable for Account
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.name == rhs.name && lhs.logoUrl == rhs.logoUrl
    }
}
