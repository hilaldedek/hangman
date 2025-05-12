import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hangmanImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var wrongLettersLabel: UILabel!

    // MARK: - Properties

    var currentLanguage: String?
    var hangmanImages: [UIImage] = []
    var currentWord: String = ""
    var guessedLetters: [Character] = []
    var wrongGuessesRemaining = 6
    var wrongLetters: [Character] = []

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHangmanImages()
        updateUIForLanguage()
        updateWordLabel()
        updateWrongLettersDisplay()

        // guessTextField'ın delegate'ini bu ViewController'a ayarlayın
        guessTextField.delegate = self
        
        // Klavyeyi hemen büyük harflere ayarla
        guessTextField.autocapitalizationType = .allCharacters
    }

    // MARK: - UI Setup Methods

    func loadHangmanImages() {
        for i in 0...6 {
            if let image = UIImage(named: "hangman\(i)") {
                hangmanImages.append(image)
            }
        }
        hangmanImageView.image = hangmanImages.first
    }

    // MARK: - Game Logic Methods

    func startGame(withNewWord word: String) {
        currentWord = word.uppercased()
        guessedLetters = Array(repeating: "_", count: currentWord.count)
        updateWordLabel()
        wrongLetters.removeAll()
        wrongGuessesRemaining = 6
        updateHangmanImage()
        updateWrongLettersDisplay()
    }

    func updateWordLabel() {
        if wordLabel == nil { return }
        wordLabel.text = guessedLetters.map { String($0) }.joined(separator: " ")
    }

    func updateHangmanImage() {
        let imageIndex = 6 - wrongGuessesRemaining
        if imageIndex >= 0 && imageIndex < hangmanImages.count {
            hangmanImageView.image = hangmanImages[imageIndex]
        }
    }

    func updateWrongLettersDisplay() {
        if wrongLettersLabel == nil { return }
        wrongLettersLabel.text = "Hatalı Harfler: " + wrongLetters.map { String($0) }.joined(separator: ", ")
    }

    @IBAction func guessButtonTapped(_ sender: UIButton) {
        // Inputun boş olup olmadığını kontrol et
        guard let guessedText = guessTextField.text?.uppercased(),
              !guessedText.isEmpty,
              guessedText.count == 1,
              let guessedLetter = guessedText.first,
              guessedLetter.isLetter else {
            // Geçersiz input durumunda inputu temizle
            guessTextField.text = ""
            return
        }

        // Tahmin edilen harfi işle
        processGuessedLetter(guessedLetter)
        
        // Input alanını temizle
        guessTextField.text = ""
    }
    
    func processGuessedLetter(_ guessedLetter: Character) {
        if currentWord.contains(guessedLetter) {
            // Doğru tahmin
            for (index, letter) in currentWord.enumerated() {
                if letter == guessedLetter {
                    guessedLetters[index] = guessedLetter
                }
            }
            updateWordLabel()
            
            // Kelime tamamlandı mı kontrol et
            if !guessedLetters.contains("_") {
                showAlert(message: "Tebrikler! Kelimeyi buldunuz: \(currentWord)")
                guessButton.isEnabled = false
            }
        } else {
            // Yanlış tahmin
            if !wrongLetters.contains(guessedLetter) {
                wrongGuessesRemaining -= 1
                wrongLetters.append(guessedLetter)
                updateHangmanImage()
                updateWrongLettersDisplay()
                
                // Oyun bitti mi kontrol et
                if wrongGuessesRemaining == 0 {
                    showAlert(message: "Kaybettiniz! Doğru kelime: \(currentWord)")
                    guessButton.isEnabled = false
                }
            }
        }
    }

    // MARK: - Alert Method

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Oyun Sonucu", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ana Menüye Dön", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Language Update Method

    func updateUIForLanguage() {
        guessTextField.placeholder = "Bir harf girin"
        guessButton.setTitle("Tahmin Et", for: .normal)
    }

    // MARK: - Word Set Property

    var currentWordSet: String? {
        didSet {
            if let word = currentWordSet {
                startGame(withNewWord: word)
            }
        }
    }

    // MARK: - Deinitialization

    deinit {
        print("ViewController serbest bırakıldı")
    }
}

// MARK: - UITextFieldDelegate Methods

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Kullanıcı silme işlemi yapıyorsa izin ver
        if string.isEmpty {
            return true
        }

        // Zaten bir karakter varsa ve yeni bir karakter girmek istiyorsa engelle
        if let text = textField.text, !text.isEmpty {
            return false
        }

        // Sadece bir harf girişine izin ver ve özel karakterleri engelle
        guard string.count == 1,
              let inputChar = string.first,
              inputChar.isLetter else {
            return false
        }

        return true
    }
}
