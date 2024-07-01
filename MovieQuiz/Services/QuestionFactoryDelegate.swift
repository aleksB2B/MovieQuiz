//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Aleks on 25.06.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)   
    // 2
}
