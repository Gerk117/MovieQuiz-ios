import UIKit

final class MovieQuizViewController: UIViewController , QuestionFactoryDelegate {
    
    
    // MARK: - Lifecycle
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService : StatisticService = StatisticServiceImplementation()
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        questionFactory?.requestNextQuestion()
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    func show(quiz result: AlertModel) {
        let alertPresenter = AlertPresenter()
        self.present(alertPresenter.createAlert(quiz: result), animated: true)
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.imageView.layer.borderColor = UIColor.clear.cgColor
        
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderColor =
        isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY.MM.dd HH.MM"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Kоличество сыграных квизов: \(statisticService.gamesCount)
                        Лучший результат: \(statisticService.bestGame.correct)/\(questionsAmount) (\(dateFormatter.string(from: statisticService.bestGame.date)))
                        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
                        """,
                buttonText: "Сыграть ещё раз",
                completion: {self.questionFactory?.requestNextQuestion()})
            show(quiz: alertModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}




