import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var startTime: Date?
    private var endTime: Date?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol = StatisticService() // Убедитесь, что это корректно
    private var alertPresenter: AlertPresenter?

    struct QuizStepViewModel {
        let image: UIImage?
        let text: String
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startQuiz()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            showAlertWithResults()
            return
        }

        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(with: viewModel)
        }
    }

    private func updateUI(with viewModel: QuizStepViewModel) {
        textLabel.text = viewModel.text
        imageView.image = viewModel.image
        imageView.layer.borderWidth = 0
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questionFactory?.totalQuestions ?? 0)"
        imageView.contentMode = .scaleAspectFill
        resetButtons()
    }

    // MARK: - Setup
    private func setupUI() {
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        resetButtons()
    }

    // MARK: - Quiz Flow
    private func startQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        startTime = Date()
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        alertPresenter = AlertPresenter(viewController: self)
        showQuestion()
    }

    private func showQuestion() {
        guard let question = questionFactory?.question(at: currentQuestionIndex) else {
            showAlertWithResults()
            return
        }

        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(with: viewModel)
        }
    }

    private func handleAnswer(_ answer: Bool) {
        guard let question = questionFactory?.question(at: currentQuestionIndex) else {
            showAlertWithResults()
            return
        }
        let isCorrect = question.correctAnswer == answer

        if isCorrect {
            correctAnswers += 1
        }

        applyBorder(isCorrect: isCorrect, to: imageView)
        disableButtons()

        currentQuestionIndex += 1

        if currentQuestionIndex < questionFactory?.totalQuestions ?? 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showQuestion()
            }
        } else {
            showAlertWithResults()
        }
    }

    private func showAlertWithResults() {
        endTime = Date()
        guard let startTime = startTime, let endTime = endTime else { return }

        let totalQuestions = questionFactory?.totalQuestions ?? 0
        let correctPercent = Double(correctAnswers) / Double(totalQuestions) * 100.0

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let endTimestamp = formatter.string(from: endTime)

        // Создаем экземпляр GameResult
        let gameResult = GameResult(correctAnswers: correctAnswers, totalQuestions: totalQuestions, date: endTime)
        statisticService.store(result: gameResult)

        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let totalAccuracy = statisticService.totalAccuracy

        let bestGameText = "\(bestGame.correctAnswers) из \(bestGame.totalQuestions) (\(bestGame.date))"
        let message = """
            Ваш результат:
            Правильные ответы: \(correctAnswers) из \(totalQuestions)
            Процент правильных ответов: \(correctPercent)%
            Время окончания: \(endTimestamp)

            Количество завершённых игр: \(gamesCount)
            Лучшая попытка: \(bestGameText)
            Средняя точность: \(totalAccuracy)%
            """

        let alertModel = AlertModel(
            title: "Раунд окончен",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                self?.startQuiz()
            }
        )

        alertPresenter?.presentAlert(with: alertModel)
    }

    // MARK: - Conversion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image)
        return QuizStepViewModel(image: image, text: model.text)
    }

    // MARK: - Button State Management
    private func resetButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        handleAnswer(true)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        handleAnswer(false)
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
