//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Георгий Ксенодохов on 20.07.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
