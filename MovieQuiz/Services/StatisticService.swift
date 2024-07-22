//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aleks on 29.06.2024.
//
import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var totalAccuracy: Double { get }
    var bestGame: GameResult { get }
    func store(result: GameResult)
}

class StatisticService: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard

    var gamesCount: Int {
        return userDefaults.integer(forKey: "gamesCount")
    }

    var totalAccuracy: Double {
        return userDefaults.double(forKey: "totalAccuracy")
    }

    var bestGame: GameResult {
        guard let data = userDefaults.data(forKey: "bestGame"),
              let game = try? JSONDecoder().decode(GameResult.self, from: data) else {
            return GameResult(correctAnswers: 0, totalQuestions: 0, date: Date())
        }
        return game
    }

    func store(result: GameResult) {
        let currentGamesCount = gamesCount + 1
        userDefaults.set(currentGamesCount, forKey: "gamesCount")

        let correctAnswers = result.correctAnswers
        let totalQuestions = result.totalQuestions

        let currentAccuracy = Double(correctAnswers) / Double(totalQuestions)
        let totalAccuracy = self.totalAccuracy

        let newTotalAccuracy = (totalAccuracy * Double(gamesCount) + currentAccuracy) / Double(currentGamesCount)
        userDefaults.set(newTotalAccuracy, forKey: "totalAccuracy")

        if currentAccuracy > totalAccuracy {
            if let data = try? JSONEncoder().encode(result) {
                userDefaults.set(data, forKey: "bestGame")
            }
        }
    }
}







