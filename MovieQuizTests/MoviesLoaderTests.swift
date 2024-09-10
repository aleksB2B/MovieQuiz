//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Aleks on 20.08.2024.
//


import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {

    // Тест успешной загрузки фильмов
    func testSuccessLoading() {
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MovieQuiz.MoviesLoader(networkClient: stubNetworkClient)
        let expectation = self.expectation(description: "Loading expectation")


        loader.loadMovies { result in

            switch result {
            case .success(let movies):
                XCTAssertGreaterThan(movies.items.count, 0, "Movies list should not be empty.")

                let firstMovie = movies.items.first
                XCTAssertNotNil(firstMovie, "First movie should not be nil.")
                XCTAssertFalse(firstMovie?.title.isEmpty ?? true, "First movie's title should not be empty.")

                expectation.fulfill()

            case .failure(let error):
                XCTFail("Unexpected failure with error: \(error)")
            }
        }


        waitForExpectations(timeout: 3, handler: nil)
    }
    
    // Тест неудачной загрузки фильмов
    func testFailureLoading() {
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MovieQuiz.MoviesLoader(networkClient: stubNetworkClient)
        let expectation = self.expectation(description: "Loading expectation")


        loader.loadMovies { result in

            switch result {
            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil.")
                expectation.fulfill()

            case .success(_):
                XCTFail("Unexpected success")
            }
        }


        waitForExpectations(timeout: 3, handler: nil)
    }
}
