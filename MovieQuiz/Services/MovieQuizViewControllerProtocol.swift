//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Aleks on 23.08.2024.
//

protocol MovieQuizViewControllerProtocol: AnyObject {
    func updateUI(with viewModel: QuizStepViewModel, questionNumber: Int, totalQuestions: Int)
    func showNetworkError(message: String)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func disableButtons()
    func resetImageViewBorder()
    func startQuiz()
}
