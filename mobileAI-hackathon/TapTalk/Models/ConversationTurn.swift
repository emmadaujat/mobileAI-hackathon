//
//  ConversationTurn.swift
//  TapTalk
//

import Foundation

struct ConversationTurn: Identifiable, Equatable {
    enum Speaker: Equatable {
        case taptalk
        case user
    }

    let id = UUID()
    let speaker: Speaker
    let text: String
    let timestamp = Date()
}
