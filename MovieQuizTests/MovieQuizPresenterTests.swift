//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Aleks on 23.08.2024.
//

import XCTest
@testable import MovieQuiz

// Мок реализация протокола MovieQuizViewControllerProtocol
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

final class MovieQuizPresenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        // Arrange
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        // Используйте действительное изображение для тестов
        guard let image = UIImage(systemName: "star.fill")?.pngData() else {
            XCTFail("Failed to load test image")
            return
        }
        let question = QuizQuestion(image: image, text: "Question Text", correctAnswer: true)

        // Act
        let viewModel = sut.convert(model: question)

        // Assert
        XCTAssertNotNil(viewModel.image) // проверка, что изображение не nil
        XCTAssertEqual(viewModel.text, "Question Text") // проверка текста вопроса
    }
}

