//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aleks on 29.06.2024.
//
import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case gamesCount
        case bestGameCorrectAnswers
        case bestGameTotalQuestions
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestions
    }

    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.bestGameCorrectAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.bestGameTotalQuestions.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correctAnswers: correctAnswers, totalQuestions: totalQuestions, date: date)
        }
        set {
            storage.set(newValue.correctAnswers, forKey: Keys.bestGameCorrectAnswers.rawValue)
            storage.set(newValue.totalQuestions, forKey: Keys.bestGameTotalQuestions.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        get {
            let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
            return totalQuestions > 0 ? Double(totalCorrectAnswers) / Double(totalQuestions) * 100 : 0
        }
    }

    func store(result: GameResult) {

        gamesCount += 1


        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue) + result.correctAnswers
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + result.totalQuestions

        storage.set(totalCorrectAnswers, forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(totalQuestions, forKey: Keys.totalQuestions.rawValue)


        if result.correctAnswers > bestGame.correctAnswers {
            bestGame = result
        }
    }
}






