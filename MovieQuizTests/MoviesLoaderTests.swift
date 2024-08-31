//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Aleks on 20.08.2024.
//


import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase{
    func testSuccessLoading() throws {

        let loader = MoviesLoader()
        let expectation = expectation(description: "Loading expectation")

        loader.loadMovies { result in

            switch result {
            case .success(_):

                expectation.fulfill()
            case .failure(_):

                XCTFail("Unexpected failure") 
            }
        }
        waitForExpectations(timeout: 3)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true) // говорим, что хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)

        // When
        let expectation = expectation(description: "Loading expectation")

        loader.loadMovies { result in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Unexpected failure")
            }
        }

        waitForExpectations(timeout: 1)
    }
}




