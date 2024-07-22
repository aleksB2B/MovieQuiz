//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Aleks on 23.06.2024.
//

import Foundation
import UIKit

func convert(model: QuizQuestion) -> QuizStepViewModel {
    let image = UIImage(data: model.image)
    let viewModel = QuizStepViewModel(image: image, text: model.text)
    return viewModel
}

struct QuizStepViewModel {
    let image: UIImage?
    let text: String
}



