//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Aleks on 25.08.2024.
//

import XCTest
@testable import MovieQuiz

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }

    func testYesButton() {
        let firstPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Poster did not appear in time")

        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Да"].tap()

        let secondPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5), "Poster did not appear in time after tap")

        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData, "The poster image should change after tapping 'Да'")
    }

    func testNoButton() {
        let firstPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Poster did not appear in time")

        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Нет"].tap()

        let secondPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5), "Poster did not appear in time after tapping 'Нет'")

        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData, "The poster image should change after tapping 'Нет'")


        let indexLabel = app.staticTexts.element(matching: .any, identifier: "2/10")
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Question index label did not update")
        XCTAssertEqual(indexLabel.label, "2/10", "The question index should update to '2/10' after tapping 'Нет'")
    }

    func testAlertAppearsAfterRoundEnds() {
        let app = XCUIApplication()
        app.launch()

        // Проходим все вопросы до конца раунда
        for _ in 1...10 {
            let noButton = app.buttons["Нет"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 5), "No button should be visible before tapping.")
            noButton.tap()

            // Ожидаем обновления вопроса
            sleep(2)
        }

        // Проверяем появление алерта
        let alert = app.alerts.element(boundBy: 0)
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectation(for: existsPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 20, handler: nil) // Увеличиваем таймаут

        // Проверяем заголовок алерта
        let alertTitle = alert.staticTexts["Этот раунд окончен!"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be 'Этот раунд окончен!'.")

        // Проверяем кнопку "Сыграть ещё раз"
        let restartButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(restartButton.exists, "Alert should have a button to restart the quiz.")

    }

    func testAlertDismissalAndQuestionReset() {
        let app = XCUIApplication()
        app.launch()


        for _ in 1...10 {
            let noButton = app.buttons["Нет"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 5), "No button should be visible before tapping.")
            noButton.tap()


            sleep(2)
        }


        let alert = app.alerts.element(boundBy: 0)
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectation(for: existsPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 15, handler: nil)


        let restartButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(restartButton.exists, "Alert should have a button to restart the quiz.")


        restartButton.tap()


        let alertDismissedPredicate = NSPredicate(format: "exists == 0")
        expectation(for: alertDismissedPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)


        let indexLabel = app.staticTexts["1/10"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Question index label did not reset")
        XCTAssertEqual(indexLabel.label, "1/10", "The question index should reset to '1/10' after tapping 'Сыграть ещё раз'")
    }

}
