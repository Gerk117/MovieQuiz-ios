//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Георгий Ксенодохов on 20.07.2023.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults = UserDefaults.standard
    private var total : Int {userDefaults.integer(forKey: Keys.total.rawValue)}
    private var correct : Int {userDefaults.integer(forKey: Keys.correct.rawValue)}
    
    var totalAccuracy: Double {
        get{
            Double(userDefaults.double(forKey: Keys.correct.rawValue)/userDefaults.double(forKey: Keys.total.rawValue))
        }
    }
    
    var gamesCount : Int {
        get{
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame < newGame {
            bestGame = newGame
        }
        userDefaults.set(gamesCount + 1, forKey: Keys.gamesCount.rawValue)
        userDefaults.set(correct + count, forKey: Keys.correct.rawValue)
        userDefaults.set(total + amount, forKey: Keys.total.rawValue)
    }
    
}
