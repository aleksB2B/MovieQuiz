//
//  QuizResultsViewModel.swift
//  MovieQuiz
//
//  Created by Aleks on 23.06.2024.
//

import UIKit
extension MovieQuizViewController {

    func applyBorder(isCorrect: Bool, to imageView: UIImageView) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
}



