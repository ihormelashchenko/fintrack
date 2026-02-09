//
//  Transaction.swift
//  FinTrack
//
//  Created by Ihor Melashchenko on 12/4/21.
//

import Foundation

class Transaction {
    var category: String = "Food"
    var amount: String = "0"
    var option: TransactionOption = .unknown
    var date: String = "unknown date"
    
    init(category: String, amount: String, option: TransactionOption, date: String) {
        self.category = category
        self.amount = amount
        self.option = option
        self.date = date
    }
}

enum TransactionOption {
    case income, expense, unknown
}
