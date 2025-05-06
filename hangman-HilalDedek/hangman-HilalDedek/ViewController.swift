import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var hangmanImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var wrongLettersLabel: UILabel! // Yeni Hatalı Harfler Outlet'ı

    var currentLanguage: String?
    var hangmanImages: [UIImage] = []
    var currentWord: String = ""
    var guessedLetters: [Character] = []
    var wrongGuessesRemaining = 6
    var wrongLetters: [Character] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHangmanImages()
        updateUIForLanguage()
        updateWrongLettersDisplay() // Başlangıçta hatalı harfler etiketini güncelle
    }

    func loadHangmanImages() {
        for i in 0...6 {
            if let image = UIImage(named: "hangman\(i)") {
                hangmanImages.append(image)
            }
        }
        hangmanImageView.image = hangmanImages.first
    }

    func startGame(withNewWord word: String) {
        currentWord = word
        guessedLetters = Array(repeating: "_", count: currentWord.count)
        updateWordLabel()
        wrongLetters.removeAll()
        wrongGuessesRemaining = 6
        updateHangmanImage()
        updateWrongLettersDisplay() // Yeni kelime başladığında hatalı harfler etiketini güncelle
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

    func updateWrongLettersDisplay() {
        wrongLettersLabel.text = "Hatalı Harfler: " + wrongLetters.map { String($0) }.joined(separator: ", ")
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
                updateWrongLettersDisplay() // Hatalı tahmin yapıldığında etiketi güncelle
                if wrongGuessesRemaining == 0 {
                    showAlert(message: "Kaybettiniz! Doğru kelime: \(currentWord)")
                    guessButton.isEnabled = false
                }
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Oyun Sonucu", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yeni Oyun", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func updateUIForLanguage() {
        guessTextField.placeholder = "Bir harf girin"
        guessButton.setTitle("Tahmin Et", for: .normal)
        backButton.setTitle("Geri", for: .normal)
    }

    var currentWordSet: String? {
        didSet {
            if let word = currentWordSet {
                startGame(withNewWord: word)
            }
        }
    }
}
