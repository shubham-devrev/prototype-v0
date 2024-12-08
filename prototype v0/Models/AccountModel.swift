//
//  Account.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 07/12/24.
//

import SwiftUI

// Account model
struct Account: Equatable, Codable {
    let name: String
    let logoUrl: URL?
    
    // Coding keys
    private enum CodingKeys: String, CodingKey {
        case name, logoUrl
    }
    
    // Custom decoder implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        logoUrl = try container.decodeIfPresent(URL.self, forKey: .logoUrl)
    }
    
    // Custom encoder implementation
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(logoUrl, forKey: .logoUrl)
    }
    
    // Regular initializer
    init(name: String, logoUrl: URL? = nil) {
        self.name = name
        self.logoUrl = logoUrl
    }
    
    // Implement Equatable for Account
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.name == rhs.name && lhs.logoUrl == rhs.logoUrl
    }
}
