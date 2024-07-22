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



