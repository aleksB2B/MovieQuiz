//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Aleks on 23.06.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    var totalQuestions: Int { get }
    func requestNextQuestion()
    func question(at index: Int) -> QuizQuestion? // Добавлено
}

