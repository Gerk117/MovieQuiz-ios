import UIKit

final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate {
    
    
    // MARK: - Lifecycle
    //    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let presenter = MovieQuizPresenter()
    //    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService : StatisticService = StatisticServiceImplementation()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        questionFactory?.requestNextQuestion()
        presenter.viewController = self
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        show(quiz: model)
        
    }
    
    //    private func convert(model: QuizQuestion) -> QuizStepViewModel {
    //        return QuizStepViewModel(
    //            image: UIImage(data: model.image) ?? UIImage(),
    //            question: model.text,
    //            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    //    }
    func show(quiz result: AlertModel) {
        let alertPresenter = AlertPresenter()
        self.present(alertPresenter.createAlert(quiz: result), animated: true)
        presenter.resetQuestionIndex()
        self.correctAnswers = 0
        
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderColor =
        isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.YY HH:MM"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                        Kоличество сыграных квизов: \(statisticService.gamesCount)
                        Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(dateFormatter.string(from: statisticService.bestGame.date)))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
                        """,
                buttonText: "Сыграть ещё раз",
                completion: {self.questionFactory?.requestNextQuestion()})
            show(quiz: alertModel)
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
}




