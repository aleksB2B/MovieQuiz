import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var currentQuestionIndex = 0
    private var startTime: Date?
    private var endTime: Date?
    var questionFactory: QuestionFactory?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?

    
    let totalQuestions = 10

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)

        setupUI()
        alertPresenter = AlertPresenterImplementation(viewController: self)

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion) {
            presenter?.didReceiveNextQuestion(question: question)
        }

    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        startQuiz() 
    }

    func didFailToLoadData(with error: Error) {
        activityIndicator.stopAnimating()
        showNetworkError(message: error.localizedDescription)
    }

    // MARK: - UI Updates
            func updateUI(with viewModel: QuizStepViewModel) {
        textLabel.text = viewModel.text
        imageView.image = viewModel.image
        counterLabel.text = "\(currentQuestionIndex + 1)/\(totalQuestions)"
        resetButtons()
        resetImageViewBorder() // Сброс рамки при обновлении UI
    }

    private func setupUI() {
        imageView.layer.cornerRadius = 20
        resetButtons()
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func resetButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

            func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    private func showNetworkError(message: String) {
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Quiz Flow
//    private func showAlertWithResults() {
//        presenter?.showAlertWithResults
//    }

    func startQuiz() {
        presenter?.startQuiz()
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter?.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter?.noButtonClicked()
    }

    // MARK: - Helpers
    private func applyBorderr(isCorrect: Bool, to imageView: UIImageView) {
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
    }

            func resetImageViewBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
}












/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
