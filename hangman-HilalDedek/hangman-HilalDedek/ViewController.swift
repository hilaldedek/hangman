import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var hangmanImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var wrongLettersLabel: UILabel!

    var currentLanguage: String? // MainMenu'den gelen dil bilgisi
    var hangmanImages: [UIImage] = [] // Hangman resimlerini tutacak dizi
    var currentWord: String = ""
    var guessedLetters: [Character] = []
    var wrongGuessesRemaining = 6
    var wrongLetters: [Character] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Gelen dili kullanabilirsiniz: currentLanguage
        loadHangmanImages()
        startGame()
    }

    func loadHangmanImages() {
        // Projenize 7 tane hangman resmi ekleyin (örneğin, "hangman0.png", "hangman1.png", ...)
        for i in 0...6 {
            if let image = UIImage(named: "hangman\(i)") {
                hangmanImages.append(image)
            }
        }
        hangmanImageView.image = hangmanImages.first // Başlangıç resmi
    }

    func startGame() {
        // Burada seçilen dile göre kelime çekme veya rastgele kelime seçme işlemini yapabilirsiniz.
        // Şimdilik statik bir kelime kullanalım.
        currentWord = "trakyaüni".uppercased()
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
        wrongLettersLabel.text = "Hatalı Harfler: \(wrongLetters.map { String($0) }.joined(separator: ", "))"
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
                // Oyunu kazandınız!
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
                    // Oyunu kaybettiniz!
                    showAlert(message: "Kaybettiniz! Doğru kelime: \(currentWord)")
                    guessButton.isEnabled = false
                }
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Oyun Sonucu", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.startGame() // Yeni bir oyun başlat
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
