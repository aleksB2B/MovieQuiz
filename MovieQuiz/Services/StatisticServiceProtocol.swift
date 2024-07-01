//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Aleks on 29.06.2024.
//



import Foundation

struct GameResult: Codable {
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
}

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    func store(result: GameResult)
}

