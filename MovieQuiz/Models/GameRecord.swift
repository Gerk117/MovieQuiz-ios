//
//  File.swift
//  MovieQuiz
//
//  Created by Георгий Ксенодохов on 20.07.2023.
//

import Foundation
struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
}
