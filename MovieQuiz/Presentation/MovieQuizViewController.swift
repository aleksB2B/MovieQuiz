import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!

    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var startTime: Date?
    private var endTime: Date?

    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }

    struct QuizStepViewModel {
        let image: UIImage?
        let text: String
        let borderColor: UIColor
    }

    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startQuiz()
    }

    // MARK: - Setup
    private func setupUI() {
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        resetButtons()
    }

    // MARK: - Quiz Flow
    private func startQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        startTime = Date()
        showQuestion(index: currentQuestionIndex)
    }

    private func showQuestion(index: Int) {
        guard index < questions.count else {
            showAlertWithResults()
            return
        }

        let question = questions[index]
        let viewModel = convert(model: question)
        textLabel.text = viewModel.text
        imageView.image = viewModel.image
        imageView.layer.borderColor = viewModel.borderColor.cgColor
        imageView.layer.borderWidth = 8
        counterLabel.text = "\(index + 1)/\(questions.count)"
        resetButtons()
    }

    private func handleAnswer(_ answer: Bool) {
        let question = questions[currentQuestionIndex]
        let isCorrect = question.correctAnswer == answer

        if isCorrect {
            correctAnswers += 1
        }

        showAnswerResult(isCorrect: isCorrect)
        disableButtons()

        currentQuestionIndex += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showQuestion(index: self.currentQuestionIndex)
        }
    }

    private func showAlertWithResults() {
        endTime = Date()
        guard let startTime = startTime, let endTime = endTime else { return }

        let totalQuestions = questions.count
        let correctPercent = Double(correctAnswers) / Double(totalQuestions) * 100.0

        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let endTimestamp = formatter.string(from: endTime)

        let alert = UIAlertController(
            title: "Раунд окончен",
            message: """
            Ваш результат:
            Правильные ответы: \(correctAnswers) из \(totalQuestions)
            Процент правильных ответов: \(correctPercent)%
            Время окончания: \(endTimestamp)
            """,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { _ in
            self.startQuiz()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }

    // MARK: - Conversion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image)
        let borderColor: UIColor = (model.correctAnswer) ? .green : .red
        let viewModel = QuizStepViewModel(image: image, text: model.text, borderColor: borderColor)
        return viewModel
    }

    // MARK: - Show Answer Result
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.green.cgColor : UIColor.red.cgColor
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
