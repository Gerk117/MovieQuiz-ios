//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Георгий Ксенодохов on 20.07.2023.
//

import UIKit

class AlertPresenter {
     func createAlert(quiz result: AlertModel) -> UIAlertController {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        alert.addAction(action)
        
        return alert
    }
}
