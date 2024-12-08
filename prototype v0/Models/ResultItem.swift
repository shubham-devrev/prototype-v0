//
//  ResultItem.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import Foundation

struct ResultItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let shortcut: String?
    let action: () -> Void
    
    static func == (lhs: ResultItem, rhs: ResultItem) -> Bool {
        lhs.id == rhs.id
    }
}
