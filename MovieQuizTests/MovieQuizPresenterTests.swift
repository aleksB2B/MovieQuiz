//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Aleks on 23.08.2024.
//

import XCTest
import UIKit
@testable import MovieQuiz


protocol MoviesLoaderProtocol {
    func loadMovies(completion: @escaping (Result<[Movie], Error>) -> Void)
}


struct Movie {
    let id: Int
    let title: String
    let imageData: Data
}


final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func updateUI(with viewModel: QuizStepViewModel, questionNumber: Int, totalQuestions: Int) { }
    func showNetworkError(message: String) { }
    func showLoadingIndicator() { }
    func hideLoadingIndicator() { }
    func highlightImageBorder(isCorrectAnswer: Bool) { }
    func disableButtons() { }
    func resetImageViewBorder() { }
    func startQuiz() { }
}


final class AlertPresenter: AlertPresenterProtocol {
    func presentAlert(with model: AlertModel) {

    }
}


final class MoviesLoader: MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {

        handler(.success(MostPopularMovies(items: [])))
    }
}

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        // Arrange
        let viewController = MovieQuizViewControllerMock()
        let alertPresenter = AlertPresenter()
        let statisticService = StatisticService()


        let moviesLoader = MoviesLoader()
        let questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: nil)


        let sut = MovieQuizPresenter(
            viewController: viewController,
            alertPresenter: alertPresenter,
            statisticService: statisticService,
            questionFactory: questionFactory
        )


        guard let image = UIImage(systemName: "star.fill")?.pngData() else {
            XCTFail("Failed to load test image")
            return
        }
        let question = QuizQuestion(image: image, text: "Question Text", correctAnswer: true)


        let viewModel = sut.convert(model: question)


        XCTAssertNotNil(viewModel.image) // проверка, что изображение не nil
        XCTAssertEqual(viewModel.text, "Question Text") // проверка текста вопроса
    }
}
