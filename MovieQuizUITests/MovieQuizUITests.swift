//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Aleks on 25.08.2024.
//

import XCTest
@testable import MovieQuiz

class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }
    func testYesButton() {
        let app = XCUIApplication()

        // Wait for the image to appear
        let firstPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Poster did not appear in time")

        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Да"].tap()

        // Wait for the image to change after the button tap
        let secondPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5), "Poster did not appear in time after tap")

        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData, "The poster image should change after tapping 'Да'")
    }
    func testNoButton() {
        let app = XCUIApplication()

        // Wait for the initial poster image to appear
        let firstPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 5), "Poster did not appear in time")

        // Capture the screenshot data of the first poster
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        // Tap the "Нет" button
        app.buttons["Нет"].tap()

        // Wait for the second poster image to appear
        let secondPoster = app.images.element(boundBy: 0)
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5), "Poster did not appear in time after tapping 'Нет'")

        // Capture the screenshot data of the second poster
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        // Ensure the poster has changed after the tap
        XCTAssertNotEqual(firstPosterData, secondPosterData, "The poster image should change after tapping 'Нет'")

        // Access the label that shows the question index
        let indexLabel = app.staticTexts.element(matching: .any, identifier: "2/10")

        // Verify the index label
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

            // Подождите, пока вопрос обновится
            sleep(2) // Уменьшите время ожидания, если необходимо
        }

        // Проверяем появление алерта
        let alert = app.alerts.element(boundBy: 0)
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectation(for: existsPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 10, handler: nil) // Увеличьте таймаут, если необходимо

        // Печатаем фактический текст алерта для отладки
        let alertText = alert.staticTexts.element(matching: .staticText, identifier: "Этот раунд окончен!")
        print("Alert result text: \(alertText.label)")

        // Проверяем заголовок алерта
        let alertTitle = alert.staticTexts["Этот раунд окончен!"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be 'Этот раунд окончен!'.")

        // Проверяем кнопку "Сыграть ещё раз"
        let restartButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(restartButton.exists, "Alert should have a button to restart the quiz.")

        // Кликаем по кнопке "Сыграть ещё раз"
        restartButton.tap()
    }

    func testAlertDismissalAndQuestionReset() {
        let app = XCUIApplication()
        app.launch()

        // Проходим все вопросы до конца раунда
        for _ in 1...10 {
            app.buttons["Нет"].tap() // Или используйте "Да", если это необходимо
            sleep(2) // Уменьшите время ожидания для улучшения производительности теста
        }

        // Проверяем появление алерта
        let alert = app.alerts.element(boundBy: 0)
        let existsPredicate = NSPredicate(format: "exists == 1")
        expectation(for: existsPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 15, handler: nil) // Увеличьте таймаут, если необходимо

        // Проверяем кнопку "Сыграть ещё раз"
        let restartButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(restartButton.exists, "Alert should have a button to restart the quiz.")

        // Нажимаем кнопку "Сыграть ещё раз" чтобы скрыть алерт
        restartButton.tap()

        // Проверяем, что алерт больше не существует
        let alertDismissedPredicate = NSPredicate(format: "exists == 0")
        expectation(for: alertDismissedPredicate, evaluatedWith: alert, handler: nil)
        waitForExpectations(timeout: 5, handler: nil) // Увеличьте таймаут, если необходимо

        // Проверяем сброс счетчика вопросов
        let indexLabel = app.staticTexts.element(matching: .any, identifier: "1/10")

        // Verify the index label
        XCTAssertEqual(indexLabel.label, "1/10", "The question index should update to '1/10' after tapping 'Нет'")
//        // Печатаем фактическое значение счетчика вопросов для отладки
//        print("Question label text after reset: \(questionLabelText)")
    }


    }

