//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aleks on 26.06.2024.
//

// Presentation/AlertPresenter.swift



import UIKit

protocol AlertPresenter {
    func presentAlert(with model: AlertModel)
}

class AlertPresenterImplementation: AlertPresenter {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}









