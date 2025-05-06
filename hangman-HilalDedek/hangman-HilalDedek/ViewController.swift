import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var hangmanImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var wrongLettersLabel: UILabel!

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
        updateWrongLettersDisplay()
        
        // viewDidLoad sonunda wrongLettersLabel kontrolü
        if wrongLettersLabel == nil {
            print("viewDidLoad: HATA: wrongLettersLabel hala nil!")
        } else {
            print("viewDidLoad: wrongLettersLabel bağlı.")
        }
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
        updateWrongLettersDisplay()
        guessTextField.text = ""
        guessButton.isEnabled = true
    }

    func updateWordLabel() {
        print("updateWordLabel() çağrıldı. wordLabel: \(String(describing: wordLabel)), guessedLetters: \(guessedLetters)")
        if wordLabel == nil {
            print("updateWordLabel(): HATA: wordLabel hala nil!")
            return
        }
        wordLabel.text = guessedLetters.map { String($0) }.joined(separator: " ")
        print("updateWordLabel(): wordLabel.text ayarlandı: \(String(describing: wordLabel.text))")
    }

    func updateHangmanImage() {
        let imageIndex = 6 - wrongGuessesRemaining
        if imageIndex >= 0 && imageIndex < hangmanImages.count {
            hangmanImageView.image = hangmanImages[imageIndex]
        }
    }

    func updateWrongLettersDisplay() {
        print("updateWrongLettersDisplay() çağrıldı. wrongLettersLabel: \(String(describing: wrongLettersLabel)), wrongLetters: \(wrongLetters)")
        if wrongLettersLabel == nil {
            print("updateWrongLettersDisplay(): HATA: wrongLettersLabel nil!")
            return
        }
        wrongLettersLabel.text = "Hatalı Harfler: " + wrongLetters.map { String($0) }.joined(separator: ", ")
        print("updateWrongLettersDisplay(): wrongLettersLabel.text ayarlandı: \(String(describing: wrongLettersLabel.text))")
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
                updateWrongLettersDisplay()
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

    deinit {
        print("ViewController serbest bırakıldı")
    }
}
