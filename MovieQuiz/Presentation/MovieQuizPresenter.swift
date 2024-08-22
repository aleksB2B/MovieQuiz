//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 22.08.2024.
//


import UIKit

final class MovieQuizPresenter {

    weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticServiceProtocol

    var onAnswerSelected: ((Bool) -> Void)?

    init(viewController: MovieQuizViewController, statisticService: StatisticServiceProtocol = StatisticService()) {
        self.viewController = viewController
        self.statisticService = statisticService
    }

    func yesButtonClicked() {
        handleButtonClicked(answer: true)
    }

    func noButtonClicked() {
        handleButtonClicked(answer: false)
    }

    private func handleButtonClicked(answer: Bool) {
        print("\(answer ? "Yes" : "No") button clicked")
        onAnswerSelected?(answer)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image),
            text: model.text
        )
    }

    func showAlertWithResults(correctAnswers: Int, totalQuestions: Int, startTime: Date?, endTime: Date?) {
        guard let startTime = startTime, let endTime = endTime else {
            print("Start or end time is nil")
            return
        }

        let correctPercent = Double(correctAnswers) / Double(totalQuestions) * 100.0

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let endTimestamp = formatter.string(from: endTime)

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
                self?.viewController?.startQuiz()
            }
        )

        viewController?.alertPresenter?.presentAlert(with: alertModel)
    }
    func didReceiveNextQuestion(question: QuizQuestion) {
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.updateUI(with: viewModel)
        }
    }
}
