//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 26.06.2024.
//

// Presentation/AlertPresenter.swift



import UIKit

protocol AlertPresenterProtocol {
    func presentAlert(with model: AlertModel)
}

final class AlertPresenterImplementation: AlertPresenterProtocol {
    private weak var viewController: MovieQuizViewControllerProtocol?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
    }

    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
            model.completion()
        }
        alert.addAction(action)
        (viewController as? UIViewController)?.present(alert, animated: true, completion: nil)
    }
}










