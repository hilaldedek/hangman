import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageDropDownButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var languageInstructionLabel: UILabel!

    // Diller ve seçili dil
    var languages = ["Türkçe", "English"] // Şimdilik sadece bu diller
    var selectedLanguage = ""

    // Dil kodları (API'nin beklediği formatta)
    var languageCodes: [String: String] = [
        "Türkçe": "tr",
        "English": "en"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // UI kurulumu
    func setupUI() {
        // Başlık
        titleLabel.text = "Hangman"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)

        // Dil talimatı
        updateLanguageInstructionLabel()

        // Dil açılır menüsü
        configureLanguageDropDownMenu()

        // Başlangıçta oyun başlatma butonu devre dışı
        startGameButton.isEnabled = false
        updateStartButtonAppearance()

        // Başlangıçta stil ayarlamaları
        startGameButton.layer.cornerRadius = 10
        languageDropDownButton.layer.cornerRadius = 8
    }

    // Dil açılır menüsü yapılandırması
    func configureLanguageDropDownMenu() {
        let menu = UIMenu(title: "Dil Seçiniz", options: .displayInline, children: createLanguageActions())

        if #available(iOS 14.0, *) {
            languageDropDownButton.menu = menu
            languageDropDownButton.showsMenuAsPrimaryAction = true
            languageDropDownButton.setTitle("Dil Seçiniz", for: .normal)
        } else {
            // iOS 14 öncesi için alternatif çözüm
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showLanguageActionSheet))
            languageDropDownButton.addGestureRecognizer(tapGesture)
            languageDropDownButton.setTitle("Dil Seçiniz", for: .normal)
        }
    }

    // Dil seçenekleri için UIAction'lar oluştur
    func createLanguageActions() -> [UIAction] {
        var actions = [UIAction]()

        for language in languages {
            let action = UIAction(title: language, image: nil, handler: { [weak self] _ in
                self?.selectedLanguage = language
                self?.languageDropDownButton.setTitle(language, for: .normal)
                self?.languageInstructionLabel.text = "Kelime yükleniyor..."
                self?.startGameButton.isEnabled = false // Kelime yüklenirken butonu devre dışı bırak
                self?.updateStartButtonAppearance()

                if let languageCode = self?.languageCodes[language] {
                    self?.fetchRandomWord(forLanguageCode: languageCode) { randomWord in
                        DispatchQueue.main.async {
                            if let word = randomWord {
                                self?.performSegue(withIdentifier: "goToGameScene", sender: word)
                            } else {
                                self?.languageInstructionLabel.text = "Kelime yüklenirken hata oluştu."
                                self?.startGameButton.isEnabled = false
                                self?.updateStartButtonAppearance()
                            }
                        }
                    }
                } else {
                    self?.languageInstructionLabel.text = "Bu dil için kod bulunamadı."
                    self?.startGameButton.isEnabled = false
                    self?.updateStartButtonAppearance()
                }
            })
            actions.append(action)
        }

        return actions
    }

    // iOS 14 öncesi için ActionSheet göster
    @objc func showLanguageActionSheet() {
        let actionSheet = UIAlertController(title: "Dil Seçiniz", message: nil, preferredStyle: .actionSheet)

        for language in languages {
            let action = UIAlertAction(title: language, style: .default) { [weak self] _ in
                self?.selectedLanguage = language
                self?.languageDropDownButton.setTitle(language, for: .normal)
                self?.languageInstructionLabel.text = "Kelime yükleniyor..."
                self?.startGameButton.isEnabled = false
                self?.updateStartButtonAppearance()

                if let languageCode = self?.languageCodes[language] {
                    self?.fetchRandomWord(forLanguageCode: languageCode) { randomWord in
                        DispatchQueue.main.async {
                            if let word = randomWord {
                                self?.performSegue(withIdentifier: "goToGameScene", sender: word)
                            } else {
                                self?.languageInstructionLabel.text = "Kelime yüklenirken hata oluştu."
                                self?.startGameButton.isEnabled = false
                                self?.updateStartButtonAppearance()
                            }
                        }
                    }
                } else {
                    self?.languageInstructionLabel.text = "Bu dil için kod bulunamadı."
                    self?.startGameButton.isEnabled = false
                    self?.updateStartButtonAppearance()
                }
            }
            actionSheet.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true, completion: nil)
    }

    // Rastgele kelime çekme fonksiyonu
    func fetchRandomWord(forLanguageCode languageCode: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://random-word-api.herokuapp.com/word?lang=\(languageCode)") else {
            print("Geçersiz API URL'si")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("API isteği sırasında hata: \(error)")
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

    // Başlat butonunun görünümünü güncelle
    func updateStartButtonAppearance() {
        if startGameButton.isEnabled {
            startGameButton.alpha = 1.0
            startGameButton.backgroundColor = UIColor.systemBlue
        } else {
            startGameButton.alpha = 0.5
            startGameButton.backgroundColor = UIColor.systemGray
        }
    }

    // Dil talimat etiketini güncelle
    func updateLanguageInstructionLabel() {
        if selectedLanguage.isEmpty {
            languageInstructionLabel.text = "Lütfen bir dil seçin"
            languageInstructionLabel.textColor = UIColor.systemRed
        } else {
            if selectedLanguage == "Türkçe" {
                languageInstructionLabel.text = "Oyuna başlamak için butona tıklayın"
            } else if selectedLanguage == "English" {
                languageInstructionLabel.text = "Click the button to start the game"
            }
            languageInstructionLabel.textColor = UIColor.darkGray
        }
    }

    // Oyuna başla butonuna tıklandığında (artık kelime çekildikten sonra segue tetikleniyor)
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        // Bu metot şu an için doğrudan bir işlem yapmıyor.
        // Segue, dil seçiminde API yanıtıyla birlikte tetikleniyor.
    }

    // Segue hazırlığı - Dil ve kelime bilgisini aktarma
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGameScene" {
            if let gameVC = segue.destination as? ViewController, let word = sender as? String {
                gameVC.currentLanguage = selectedLanguage
                gameVC.currentWord = word
            }
        }
    }
}
