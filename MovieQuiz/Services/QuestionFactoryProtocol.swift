//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Aleks on 23.06.2024.
//

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
    func question(at index: Int) -> QuizQuestion?
    var totalQuestions: Int { get }
}




