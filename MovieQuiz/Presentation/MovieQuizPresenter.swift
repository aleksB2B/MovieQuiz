//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 22.08.2024.
//


import UIKit

final class MovieQuizPresenter {

    weak var viewController: MovieQuizViewController?

    var onAnswerSelected: ((Bool) -> Void)?

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
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
}
