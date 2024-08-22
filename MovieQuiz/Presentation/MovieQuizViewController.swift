import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var startTime: Date?
    private var endTime: Date?
    private var questionFactory: QuestionFactory?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?

    
    private let totalQuestions = 10

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
        startQuiz() // Начинаем квиз после загрузки данных
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

    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    private func showNetworkError(message: String) {
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Quiz Flow
    private func startQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        startTime = Date()
        resetImageViewBorder() // Сброс рамки перед началом квиза
        questionFactory?.requestNextQuestion()
    }

        func handleAnswer(_ answer: Bool) {
        guard let question = questionFactory?.question(at: currentQuestionIndex) else {
            print("No question found at index \(currentQuestionIndex)")
            showAlertWithResults()
            return
        }
        let isCorrect = question.correctAnswer == answer

        if isCorrect {
            correctAnswers += 1
        }

        applyBorder(isCorrect: isCorrect, to: imageView)
        disableButtons()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.resetImageViewBorder()
            self?.currentQuestionIndex += 1

            if self?.currentQuestionIndex ?? 0 < self?.totalQuestions ?? 0 {
                self?.questionFactory?.requestNextQuestion()
            } else {
                self?.endTime = Date()
                print("Quiz ended at \(String(describing: self?.endTime))")
                self?.showAlertWithResults()
            }
        }
    }

    private func showAlertWithResults() {
        print("showAlertWithResults called")
        print("Start time: \(String(describing: startTime)), End time: \(String(describing: endTime))")

        guard let startTime = startTime, let endTime = endTime else {
            print("Start or end time is nil")
            return
        }

        let correctPercent = Double(correctAnswers) / Double(totalQuestions) * 100.0

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let endTimestamp = formatter.string(from: endTime)

        let gameResult = GameResult(correctAnswers: correctAnswers, totalQuestions: totalQuestions, date: endTime)
        statisticService.store(result: gameResult)

        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let bestGameDateFormatted = formatter.string(from: bestGame.date)
        let totalAccuracy = statisticService.totalAccuracy

        let bestGameText = "\(bestGame.correctAnswers)/\(bestGame.totalQuestions)"
        let message = """
            Ваш результат: \(correctAnswers)/\(totalQuestions)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGameText) (\(bestGameDateFormatted))
            Средняя точность: \(String(format: "%.1f", totalAccuracy))%
            """

        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                self?.startQuiz()
            }
        )

        alertPresenter?.presentAlert(with: alertModel)
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        print("Yes button clicked")
        handleAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        print("No button clicked")
        handleAnswer(false)
    }

    // MARK: - Helpers
    private func applyBorderr(isCorrect: Bool, to imageView: UIImageView) {
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
    }

    private func resetImageViewBorder() {
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
