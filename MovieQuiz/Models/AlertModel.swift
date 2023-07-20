//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Георгий Ксенодохов on 20.07.2023.
//

import Foundation

struct AlertModel {
    var title : String
    var message : String
    var buttonText : String
    var completion : ()->Void
}
