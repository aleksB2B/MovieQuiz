//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 22.08.2024.
//


import UIKit

final class MovieQuizPresenter {
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticServiceProtocol
    private var questionFactory: QuestionFactory
    private var alertPresenter: AlertPresenterProtocol

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var startTime: Date?
    private var endTime: Date?
    private var currentQuestion: QuizQuestion?

    private let totalQuestions = 10

    init(viewController: MovieQuizViewControllerProtocol,
         alertPresenter: AlertPresenterProtocol,
         statisticService: StatisticServiceProtocol,
         questionFactory: QuestionFactory) {
        self.viewController = viewController
        self.alertPresenter = alertPresenter
        self.statisticService = statisticService
        self.questionFactory = questionFactory
        self.questionFactory.delegate = self // Set the delegate here
        startQuiz()
    }

    func startQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        startTime = Date()
        viewController?.resetImageViewBorder()
        viewController?.showLoadingIndicator()
        questionFactory.loadData()
    }

    func yesButtonClicked() {
        processAnswer(true)
    }

    func noButtonClicked() {
        processAnswer(false)
    }

    private func processAnswer(_ answer: Bool) {
        guard let question = currentQuestion else {
            showAlertWithResults()
            return
        }

        let isCorrect = question.correctAnswer == answer
        if isCorrect {
            correctAnswers += 1
        }

        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.disableButtons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.viewController?.resetImageViewBorder()
            self?.currentQuestionIndex += 1

            if self?.currentQuestionIndex ?? 0 < self?.totalQuestions ?? 0 {
                self?.questionFactory.requestNextQuestion()
            } else {
                self?.endTime = Date()
                self?.showAlertWithResults()
            }
        }
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image),
            text: model.text
        )
    }

    private func showAlertWithResults() {
        guard let startTime = startTime, let endTime = endTime else { return }

        let correctPercent = Double(correctAnswers) / Double(totalQuestions) * 100.0
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"

        let gameResult = GameResult(correctAnswers: correctAnswers, totalQuestions: totalQuestions, date: endTime)
        statisticService.store(result: gameResult)

        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let bestGameDateFormatted = formatter.string(from: bestGame.date)
        let totalAccuracy = statisticService.totalAccuracy

        let bestGameText = "\(bestGame.correctAnswers)/\(bestGame.totalQuestions)"
        let message = """
        Ваш результат: \(correctAnswers)/\(totalQuestions)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGameText) (\(bestGameDateFormatted))
        Средняя точность: \(String(format: "%.1f", totalAccuracy))%
        """

        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                self?.startQuiz()
            }
        )

        alertPresenter.presentAlert(with: alertModel)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion) {
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let currentQuestionNumber = self.currentQuestionIndex + 1
            self.viewController?.updateUI(with: viewModel, questionNumber: currentQuestionNumber, totalQuestions: self.totalQuestions)
        }
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
