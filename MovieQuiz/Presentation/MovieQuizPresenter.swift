//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 22.08.2024.
//


import UIKit

final class MovieQuizPresenter {
    weak var viewController: MovieQuizViewController?

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var startTime: Date?
    private var endTime: Date?
    private let totalQuestions = 10
    private var currentQuestion: QuizQuestion?

    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var questionFactory: QuestionFactory?
    private var alertPresenter: AlertPresenter?

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.alertPresenter = AlertPresenterImplementation(viewController: viewController)
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        startQuiz()
    }

    func startQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        startTime = Date()
        viewController?.resetImageViewBorder()
        questionFactory?.loadData()
    }

    func yesButtonClicked() {
        processAnswer(true)
    }

    func noButtonClicked() {
        processAnswer(false)
    }

    private func processAnswer(_ answer: Bool) {
        guard let question = currentQuestion else {
            print("No current question found")
            showAlertWithResults()
            return
        }

        let isCorrect = question.correctAnswer == answer

        if isCorrect {
            correctAnswers += 1
        }

        viewController?.applyBorder(isCorrect: isCorrect, to: viewController?.imageView)
        viewController?.disableButtons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.viewController?.resetImageViewBorder()
            self?.currentQuestionIndex += 1

            if self?.currentQuestionIndex ?? 0 < self?.totalQuestions ?? 0 {
                self?.questionFactory?.requestNextQuestion()
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

    func showAlertWithResults() {
        guard let startTime = startTime, let endTime = endTime else {
            print("Start or end time is nil")
            return
        }

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

        alertPresenter?.presentAlert(with: alertModel)
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion) {
        currentQuestion = question
        let viewModel = convert(model: question)
        let questionNumber = currentQuestionIndex + 1
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.updateUI(with: viewModel, questionNumber: questionNumber, totalQuestions: self?.totalQuestions ?? 10)
        }
    }

    func didLoadDataFromServer() {
        viewController?.activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.activityIndicator.stopAnimating()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}

