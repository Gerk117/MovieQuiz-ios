//
//  File.swift
//  MovieQuiz
//
//  Created by Георгий Ксенодохов on 20.07.2023.
//

import Foundation
protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}
