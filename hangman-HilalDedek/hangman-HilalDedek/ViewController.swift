import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var hangmanImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var guessButton: UIButton!
    // Hatalı harfler için yeni UI elemanları (IBOutlet bağlantılarını Storyboard'da yapmayı unutmayın)
    @IBOutlet weak var wrongLetterSlot1: UILabel!
    @IBOutlet weak var wrongLetterSlot2: UILabel!
    @IBOutlet weak var wrongLetterSlot3: UILabel!
    @IBOutlet weak var wrongLetterSlot4: UILabel!
    @IBOutlet weak var wrongLetterSlot5: UILabel!
    @IBOutlet weak var wrongLetterSlot6: UILabel!

    var currentLanguage: String? // MainMenu'den gelen dil bilgisi
    var hangmanImages: [UIImage] = [] // Hangman resimlerini tutacak dizi
    var currentWord: String = ""
    var guessedLetters: [Character] = []
    var wrongGuessesRemaining = 6
    var wrongLetters: [Character] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHangmanImages()
        startGame()
        // updateUIForLanguage() - Lokalizasyon kaldırıldı
    }

    func loadHangmanImages() {
        for i in 0...6 {
            if let image = UIImage(named: "hangman\(i)") {
                hangmanImages.append(image)
            }
        }
        hangmanImageView.image = hangmanImages.first
    }

    func startGame() {
        guessedLetters = Array(repeating: "_", count: currentWord.count)
        updateWordLabel()
        wrongLetters.removeAll()
        wrongGuessesRemaining = 6
        updateHangmanImage()
        updateWrongLettersLabel()
        guessTextField.text = ""
        guessButton.isEnabled = true
    }

    func updateWordLabel() {
        wordLabel.text = guessedLetters.map { String($0) }.joined(separator: " ")
    }

    func updateHangmanImage() {
        let imageIndex = 6 - wrongGuessesRemaining
        if imageIndex >= 0 && imageIndex < hangmanImages.count {
            hangmanImageView.image = hangmanImages[imageIndex]
        }
    }

    func updateWrongLettersLabel() {
        let wrongLetterSlots = [wrongLetterSlot1, wrongLetterSlot2, wrongLetterSlot3, wrongLetterSlot4, wrongLetterSlot5, wrongLetterSlot6]

        for slot in wrongLetterSlots {
            slot?.text = ""
            slot?.backgroundColor = UIColor.clear
            slot?.layer.borderWidth = 1
            slot?.layer.borderColor = UIColor.lightGray.cgColor
            slot?.textAlignment = .center
        }

        for (index, letter) in wrongLetters.enumerated() {
            if index < wrongLetterSlots.count {
                wrongLetterSlots[index]?.text = String(letter)
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func guessButtonTapped(_ sender: UIButton) {
        guard let guessedLetter = guessTextField.text?.uppercased().first else { return }
        guessTextField.text = ""

        if currentWord.contains(guessedLetter) {
            for (index, letter) in currentWord.enumerated() {
                if letter == guessedLetter {
                    guessedLetters[index] = guessedLetter
                }
            }
            updateWordLabel()
            if !guessedLetters.contains("_") {
                showAlert(message: "Tebrikler! Kelimeyi buldunuz: \(currentWord)")
                guessButton.isEnabled = false
            }
        } else {
            if !wrongLetters.contains(guessedLetter) {
                wrongGuessesRemaining -= 1
                wrongLetters.append(guessedLetter)
                updateHangmanImage()
                updateWrongLettersLabel()
                if wrongGuessesRemaining == 0 {
                    showAlert(message: "Kaybettiniz! Doğru kelime: \(currentWord)")
                    guessButton.isEnabled = false
                }
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Oyun Sonucu", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.startGame()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    // Dil bazlı metinleri güncelle (lokalizasyon kaldırıldı)
    func updateUIForLanguage() {
        guessTextField.placeholder = "Bir harf girin"
        guessButton.setTitle("Tahmin Et", for: .normal)
        backButton.setTitle("Geri", for: .normal)
    }
}
