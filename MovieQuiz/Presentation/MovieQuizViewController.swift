
import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterProtocol {
    // MARK: - Properties
    private var presenter: MovieQuizPresenter?

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPresenter()
    }

    private func setupUI() {
        activityIndicator.startAnimating()
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    private func setupPresenter() {
        // Создаем MoviesLoader
        let moviesLoader = MoviesLoader()

        // Создаем QuestionFactory и передаем в него MoviesLoader, делегат пока nil
        let questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: nil)

        // Создаем MovieQuizPresenter и передаем в него QuestionFactory
        presenter = MovieQuizPresenter(
            viewController: self,
            alertPresenter: self,
            statisticService: StatisticService(),
            questionFactory: questionFactory
        )

        // Настраиваем делегат для QuestionFactory
        questionFactory.delegate = presenter
    }

    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }

    // MARK: - MovieQuizViewControllerProtocol
    func updateUI(with viewModel: QuizStepViewModel, questionNumber: Int, totalQuestions: Int) {
        imageView.image = viewModel.image
        textLabel.text = viewModel.text
        counterLabel.text = "\(questionNumber)/\(totalQuestions)"
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    func showNetworkError(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { [weak self] _ in
            self?.presenter?.startQuiz()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    func resetImageViewBorder() {
        imageView.layer.borderWidth = 0
    }

    func startQuiz() {
        presenter?.startQuiz()
    }

    // MARK: - AlertPresenterProtocol
    func presentAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
