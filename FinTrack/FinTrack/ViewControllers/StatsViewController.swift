import UIKit

class StatsViewController: UIViewController {

    @IBOutlet var refreshLogButton: UIButton!
    @IBOutlet var clearLogButton: UIButton!
    @IBOutlet var textView: UITextView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        [refreshLogButton, clearLogButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
    }

    @IBAction func refreshLog(_ sender: UIButton) {
        addTransactionToLog()
    }

    func addTransactionToLog() {
        guard let transaction = Transaction.latest else {
            return
        }

        textView.text.append("\n")
        textView.text.append("\(transaction.amount); \(transaction.category); \(transaction.date)")
    }

    @IBAction func clearLog(_ sender: Any) {
        let alert = UIAlertController(
            title: "Clear transaction log?",
            message: "This operation cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in
            self.textView.text = """
            amount; category; date, time;
            ------------------------------
            """
            NSLog("Log cleared")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
