//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Aleks on 23.06.2024.
//
import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - QuestionFactoryProtocol
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            guard !self.movies.isEmpty else {
                print("No movies available to generate questions.")
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            let movie = self.movies[safe: index]
            
            URLSession.shared.dataTask(with: movie?.resizedImageURL ?? URL(string: "")!) { data, _, _ in
                guard let data = data else {
                    print("Failed to load image data.")
                    return
                }
                
                let rating = Float(movie?.rating ?? "") ?? 0
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7
                let question = QuizQuestion(image: data, text: text, correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }.resume()
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func question(at index: Int) -> QuizQuestion? {
        guard index >= 0 && index < movies.count else {
            return nil
        }
        
        let movie = movies[index]
        var imageData = Data()
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: movie.resizedImageURL) { data, _, _ in
            imageData = data ?? Data()
            semaphore.signal()
        }.resume()
        
        semaphore.wait() 
        
        let rating = Float(movie.rating) ?? 0
        let text = "Рейтинг этого фильма больше чем 7?"
        let correctAnswer = rating > 7
        return QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
    }
    
    var totalQuestions: Int {
        return movies.count
    }
}
