import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageDropDownButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var languageInstructionLabel: UILabel!

    // Diller ve seçili dil
    var languages = ["Brazilian Portuguese", "French", "German", "Italian", "Spanish", "English"]
    var selectedLanguage: String? // Optional yaptık
    var selectedLanguageCode: String?

    // Dil kodları
    var languageCodes: [String: String] = [
        "Spanish": "es",
        "English": "",
        "Italian": "it",
        "German": "de",
        "French": "fr",
        "Brazilian Portuguese": "pt-br",
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // UI kurulumu
    func setupUI() {
        titleLabel.text = "Hangman"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        updateLanguageInstructionLabel()
        configureLanguageDropDownMenu()
        startGameButton.isEnabled = false // Başlangıçta kapalı
        updateStartButtonAppearance()
        startGameButton.layer.cornerRadius = 10
        languageDropDownButton.layer.cornerRadius = 8
    }

    // Dil açılır menüsü
    func configureLanguageDropDownMenu() {
        let menu = UIMenu(title: "Dil Seçiniz", options: .displayInline, children: createLanguageActions())

        if #available(iOS 14.0, *) {
            languageDropDownButton.menu = menu
            languageDropDownButton.showsMenuAsPrimaryAction = true
            languageDropDownButton.setTitle("Dil Seçiniz", for: .normal)
        } else {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showLanguageActionSheet))
            languageDropDownButton.addGestureRecognizer(tapGesture)
            languageDropDownButton.setTitle("Dil Seçiniz", for: .normal)
        }
    }

    // Dil seçenekleri için UIAction'lar
    func createLanguageActions() -> [UIAction] {
        var actions = [UIAction]()

        for language in languages {
            let action = UIAction(title: language, image: nil, handler: { [weak self] _ in
                self?.selectedLanguage = language
                self?.selectedLanguageCode = self?.languageCodes[language]
                self?.languageDropDownButton.setTitle(language, for: .normal)
                self?.updateLanguageInstructionLabel() // Dil seçildikten sonra etiketi güncelle
                self?.startGameButton.isEnabled = true // Butonu etkinleştir
                self?.updateStartButtonAppearance()
            })
            actions.append(action)
        }

        return actions
    }

    // iOS 14 öncesi için ActionSheet
    @objc func showLanguageActionSheet() {
        let actionSheet = UIAlertController(title: "Dil Seçiniz", message: nil, preferredStyle: .actionSheet)

        for language in languages {
            let action = UIAlertAction(title: language, style: .default) { [weak self] _ in
                self?.selectedLanguage = language
                self?.selectedLanguageCode = self?.languageCodes[language]
                self?.languageDropDownButton.setTitle(language, for: .normal)
                self?.updateLanguageInstructionLabel() // Dil seçildikten sonra etiketi güncelle
                self?.startGameButton.isEnabled = true // Butonu etkinleştir
                self?.updateStartButtonAppearance()
            }
            actionSheet.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true, completion: nil)
    }

    // Rastgele kelime çekme (artık startGameButtonTapped içinde çağrılıyor)
    func fetchRandomWord(withURL url: URL, completion: @escaping (String?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("API isteği hatası: \(error)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Geçersiz HTTP yanıtı")
                completion(nil)
                return
            }

            if let data = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                        if let randomWord = jsonResult.first?.uppercased() {
                            completion(randomWord)
                            return
                        }
                        print("JSON Sonucu:", jsonResult)
                    }
                    print("Beklenmeyen JSON formatı")
                    completion(nil)
                } catch {
                    print("JSON ayrıştırma hatası: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }

    // Başlat butonunun görünümü
    func updateStartButtonAppearance() {
        startGameButton.alpha = startGameButton.isEnabled ? 1.0 : 0.5
        startGameButton.backgroundColor = startGameButton.isEnabled ? UIColor.systemBlue : UIColor.systemGray
    }

    // Dil talimat etiketi
    func updateLanguageInstructionLabel() {
        if let selectedLanguage = self.selectedLanguage {
            let localizedText: String
            switch selectedLanguage {
            case "Brazilian Portuguese":
                localizedText = "Para começar o jogo, clique no botão"
            case "French":
                localizedText = "Pour démarrer le jeu, cliquez sur le bouton"
            case "German":
                localizedText = "Klicken Sie auf die Schaltfläche, um das Spiel zu starten"
            case "Italian":
                localizedText = "Per iniziare il gioco, clicca sul pulsante"
            case "Spanish":
                localizedText = "Para empezar el juego, haz clic en el botón"
            default: // English
                localizedText = "Click the button to start the game"
            }
            languageInstructionLabel.text = localizedText
            languageInstructionLabel.textColor = UIColor.darkGray
        } else {
            languageInstructionLabel.text = "Lütfen bir dil seçin"
            languageInstructionLabel.textColor = UIColor.systemRed
            startGameButton.isEnabled = false
            updateStartButtonAppearance()
        }
    }

    // Oyuna başla butonu (kelime çekiliyor ve segue tetikleniyor)
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        guard let selectedLanguage = self.selectedLanguage else {
            languageInstructionLabel.text = "Lütfen önce bir dil seçin."
            languageInstructionLabel.textColor = UIColor.systemRed
            return
        }

        languageInstructionLabel.text = "Kelime yükleniyor..."
        startGameButton.isEnabled = false
        updateStartButtonAppearance()

        var apiUrlString = "https://random-word-api.herokuapp.com/word"
        if let languageCode = self.selectedLanguageCode, !languageCode.isEmpty {
            apiUrlString += "?lang=\(languageCode)"
        }

        if let url = URL(string: apiUrlString) {
            self.fetchRandomWord(withURL: url) { randomWord in
                DispatchQueue.main.async {
                    if let word = randomWord {
                        self.performSegue(withIdentifier: "goToGameScene", sender: word)
                    } else {
                        self.languageInstructionLabel.text = "Kelime yüklenirken hata oluştu."
                        self.startGameButton.isEnabled = true
                        self.updateStartButtonAppearance()
                    }
                }
            }
        } else {
            self.languageInstructionLabel.text = "Geçersiz API URL'si."
            self.startGameButton.isEnabled = true
            self.updateStartButtonAppearance()
        }
    }

    // Segue hazırlığı
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGameScene" {
            if let gameVC = segue.destination as? ViewController, let word = sender as? String {
                gameVC.currentLanguage = selectedLanguage
                gameVC.currentWordSet = word
                print("ViewController'a geçiş yapılıyor. Kelime: \(word), gameVC: \(String(describing: gameVC))") // Debug
            } else {
                print("HATA: ViewController'a geçiş başarısız!") // Debug
            }
        }
    }

    deinit {
        print("MainMenuViewController serbest bırakıldı") // Debug
    }
}
