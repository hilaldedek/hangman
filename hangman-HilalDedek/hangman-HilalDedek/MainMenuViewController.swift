import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageDropDownButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var languageInstructionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Hangman"
        languageDropDownButton.setTitle("Dil Seçiniz", for: .normal)
        startGameButton.setTitle("Oyuna Başla", for: .normal)
        languageInstructionLabel.text = "Lütfen bir dil seçin" // Başlangıç metni
    }

    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "goToGameScene", sender: nil)
    }

    // İleride dil seçimi için fonksiyonlar buraya eklenebilir.
}
