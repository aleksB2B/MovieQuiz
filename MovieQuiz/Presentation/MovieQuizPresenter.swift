//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 22.08.2024.
//


import UIKit

final class MovieQuizPresenter {
    // MARK: - Properties
    weak var viewController: MovieQuizViewController?
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol
    private var startTime: Date?
    private var endTime: Date?

    // MARK: - Initializer
    init(viewController: MovieQuizViewController, statisticService: StatisticServiceProtocol = StatisticService()) {
        self.viewController = viewController
        self.statisticService = statisticService
    }

    // MARK: - Button Actions
    func yesButtonClicked() {
        handleButtonClicked(answer: true)
    }

    func noButtonClicked() {
        handleButtonClicked(answer: false)
    }

    private func handleButtonClicked(answer: Bool) {
        print("\(answer ? "Yes" : "No") button clicked")
        processAnswer(answer)
    }

    private func processAnswer(_ answer: Bool) {
        guard let question = viewController?.questionFactory?.question(at: viewController?.currentQuestionIndex ?? 0) else {
            print("No current question found")
            showAlertWithResults()
            return
        }

        let isCorrect = question.correctAnswer == answer
        viewController?.applyBorder(isCorrect: isCorrect, to: viewController!.imageView)
        viewController?.disableButtons()

        if isCorrect {
            correctAnswers += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.viewController?.resetImageViewBorder()
            self?.viewController?.currentQuestionIndex += 1

            if self?.viewController?.currentQuestionIndex ?? 0 < self?.viewController?.totalQuestions ?? 0 {
                self?.viewController?.questionFactory?.requestNextQuestion()
            } else {
                self?.endTime = Date()
                print("Quiz ended at \(String(describing: self?.endTime))")
                self?.showAlertWithResults()
            }
        }
    }

    // MARK: - Conversion
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image),
            text: model.text
        )
    }

    // MARK: - Alert
    func showAlertWithResults() {
        guard let startTime = startTime, let endTime = endTime else {
            print("Start or end time is nil")
            return
        }

        let correctPercent = Double(correctAnswers) / Double(viewController?.totalQuestions ?? 0) * 100.0

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let endTimestamp = formatter.string(from: endTime)

        let gameResult = GameResult(correctAnswers: correctAnswers, totalQuestions: viewController?.totalQuestions ?? 0, date: endTime)
        statisticService.store(result: gameResult)

        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let bestGameDateFormatted = formatter.string(from: bestGame.date)
        let totalAccuracy = statisticService.totalAccuracy

        let bestGameText = "\(bestGame.correctAnswers)/\(bestGame.totalQuestions)"
        let message = """
            Ваш результат: \(correctAnswers)/\(viewController?.totalQuestions ?? 0)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGameText) (\(bestGameDateFormatted))
            Средняя точность: \(String(format: "%.1f", totalAccuracy))%
            """

        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                self?.startQuiz() // Запуск нового квиза
            }
        )

        viewController?.alertPresenter?.presentAlert(with: alertModel)
    }
    // MARK: - Quiz Handling
    func resetCorrectAnswers() {
        correctAnswers = 0
    }

    func didReceiveNextQuestion(question: QuizQuestion) {
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.updateUI(with: viewModel)
        }
    }

    func startQuiz() {
        correctAnswers = 0
        viewController?.currentQuestionIndex = 0
        startTime = Date()
        viewController?.resetImageViewBorder()
        viewController?.questionFactory?.requestNextQuestion()
    }
}
