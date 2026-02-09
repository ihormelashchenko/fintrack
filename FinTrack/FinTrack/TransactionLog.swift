//
//  TransactionLog.swift
//  FinTrack
//
//  Created by Ihor Melashchenko on 12/4/21.
//

import Foundation

class TransactionLog {
    var amount: String = "0"
    var category: String = "Food"
    var date: String = "unknown date"
    
    init(amount: String, category: String, date: String) {
        self.amount = amount
        self.category = category
        self.date = date
    }
}
