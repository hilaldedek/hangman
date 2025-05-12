import UIKit

class MainMenuViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageDropDownButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var languageInstructionLabel: UILabel!

    // MARK: - Properties

    // Desteklenen dillerin listesi
    var languages = ["Brazilian Portuguese", "French", "German", "Italian", "Spanish", "English"]
    // Kullanıcının seçtiği dil (isteğe bağlı, başlangıçta nil olabilir)
    var selectedLanguage: String?
    // Seçilen dilin API için kullanılacak kodu (örneğin "es", "fr")
    var selectedLanguageCode: String?

    // Dil adlarından dil kodlarına eşleme sözlüğü
    var languageCodes: [String: String] = [
        "Spanish": "es",
        "English": "", // İngilizce için dil kodu gerekmiyor olabilir veya API varsayılanı kullanıyor olabilir
        "Italian": "it",
        "German": "de",
        "French": "fr",
        "Brazilian Portuguese": "pt-br",
    ]

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Kullanıcı arayüzünü ayarla
    }

    // MARK: - UI Setup

    // Kullanıcı arayüzü elemanlarının başlangıç ayarları
    func setupUI() {
        titleLabel.text = "Hangman" // Başlık etiketi metni
        updateLanguageInstructionLabel() // Dil seçim talimat etiketini güncelle
        configureLanguageDropDownMenu() // Dil seçim açılır menüsünü yapılandır
        startGameButton.isEnabled = false // Başlangıçta "Oyuna Başla" butonu devre dışı
        updateStartButtonAppearance() // "Oyuna Başla" butonu görünümünü güncelle
        startGameButton.layer.cornerRadius = 10 // "Oyuna Başla" butonu köşe yuvarlaklığı
        languageDropDownButton.layer.cornerRadius = 8 // Dil seçim butonu köşe yuvarlaklığı
    }

    // Dil seçim açılır menüsünü yapılandır
    func configureLanguageDropDownMenu() {
        // Dil seçeneklerini içeren bir UIMenu oluştur
        let menu = UIMenu(title: "Dil Seçiniz", options: .displayInline, children: createLanguageActions())

        // iOS 14 ve üzeri için UIMenu'yü butonun menüsü olarak ayarla
        if #available(iOS 14.0, *) {
            languageDropDownButton.menu = menu
            languageDropDownButton.showsMenuAsPrimaryAction = true // Butona tıklandığında menüyü göster
            languageDropDownButton.setTitle("Dil Seçiniz", for: .normal) // Başlangıçta buton metni
        } else {
            // iOS 14 öncesi için ActionSheet göstermek için bir UITapGestureRecognizer ekle
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showLanguageActionSheet))
            languageDropDownButton.addGestureRecognizer(tapGesture)
            languageDropDownButton.setTitle("Dil Seçiniz", for: .normal) // Başlangıçta buton metni
        }
    }

    // Dil seçenekleri için UIAction'lar oluşturur (UIMenu için)
    func createLanguageActions() -> [UIAction] {
        var actions = [UIAction]()

        // Desteklenen her dil için bir UIAction oluştur
        for language in languages {
            let action = UIAction(title: language, image: nil, handler: { [weak self] _ in
                // Dil seçildiğinde yapılacak işlemler
                self?.selectedLanguage = language // Seçilen dili güncelle
                self?.selectedLanguageCode = self?.languageCodes[language] // Seçilen dilin kodunu güncelle
                self?.languageDropDownButton.setTitle(language, for: .normal) // Buton metnini seçilen dil olarak güncelle
                self?.updateLanguageInstructionLabel() // Dil seçim talimat etiketini güncelle
                self?.startGameButton.isEnabled = true // "Oyuna Başla" butonunu etkinleştir
                self?.updateStartButtonAppearance() // "Oyuna Başla" butonu görünümünü güncelle
            })
            actions.append(action) // Oluşturulan eylemi diziye ekle
        }

        return actions
    }

    // iOS 14 öncesi için dil seçimini gösteren ActionSheet
    @objc func showLanguageActionSheet() {
        let actionSheet = UIAlertController(title: "Dil Seçiniz", message: nil, preferredStyle: .actionSheet)

        // Desteklenen her dil için bir UIAlertAction oluştur
        for language in languages {
            let action = UIAlertAction(title: language, style: .default) { [weak self] _ in
                // Dil seçildiğinde yapılacak işlemler (ActionSheet için)
                self?.selectedLanguage = language // Seçilen dili güncelle
                self?.selectedLanguageCode = self?.languageCodes[language] // Seçilen dilin kodunu güncelle
                self?.languageDropDownButton.setTitle(language, for: .normal) // Buton metnini seçilen dil olarak güncelle
                self?.updateLanguageInstructionLabel() // Dil seçim talimat etiketini güncelle
                self?.startGameButton.isEnabled = true // "Oyuna Başla" butonunu etkinleştir
                self?.updateStartButtonAppearance() // "Oyuna Başla" butonu görünümünü güncelle
            }
            actionSheet.addAction(action) // Oluşturulan eylemi actionSheet'e ekle
        }

        // İptal butonu
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)

        // ActionSheet'i göster
        present(actionSheet, animated: true, completion: nil)
    }

    // MARK: - API Interaction

    // Belirli bir dil kodu için rastgele bir kelime getirir
    func fetchRandomWord(withLanguageCode languageCode: String?, completion: @escaping (String?) -> Void) {
        var apiUrlString = "https://random-word-api.herokuapp.com/word"
        // Eğer bir dil kodu varsa, API URL'sine parametre olarak ekle
        if let code = languageCode, !code.isEmpty {
            apiUrlString += "?lang=\(code)"
        }

        // URL oluştur
        if let url = URL(string: apiUrlString) {
            // URLSession kullanarak API isteği yap
            URLSession.shared.dataTask(with: url) { data, response, error in
                // Hata kontrolü
                if let error = error {
                    print("API isteği hatası: \(error)")
                    completion(nil) // Hata durumunda nil döndür
                    return
                }

                // HTTP yanıtının başarılı olup olmadığını kontrol et (200-299 arası status kodları)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Geçersiz HTTP yanıtı")
                    completion(nil) // Başarısız yanıt durumunda nil döndür
                    return
                }

                // Veri kontrolü
                if let data = data {
                    do {
                        // JSON verisini ayrıştır
                        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String], let randomWord = jsonResult.first?.uppercased() {
                            completion(randomWord) // Başarılı durumda kelimeyi büyük harflerle döndür
                            return
                        }
                        print("Beklenmeyen JSON formatı")
                        completion(nil) // Beklenen formatta olmayan JSON durumunda nil döndür
                    } catch {
                        print("JSON ayrıştırma hatası: \(error)")
                        completion(nil) // JSON ayrıştırma hatası durumunda nil döndür
                    }
                }
            }.resume() // DataTask'ı başlatmayı unutma
        } else {
            print("Geçersiz API URL'si oluşturulamadı.")
            completion(nil) // Geçersiz URL durumunda nil döndür
        }
    }

    // MARK: - UI Update

    // "Oyuna Başla" butonunun görünümünü seçili dil durumuna göre günceller
    func updateStartButtonAppearance() {
        startGameButton.alpha = startGameButton.isEnabled ? 1.0 : 0.5 // Etkinse tam opak, değilse yarı saydam
        startGameButton.backgroundColor = startGameButton.isEnabled ? UIColor.systemBlue : UIColor.systemGray // Etkinse mavi, değilse gri
    }

    // Dil seçim talimat etiketini günceller
    func updateLanguageInstructionLabel() {
        if let selectedLanguage = self.selectedLanguage {
            languageInstructionLabel.text = "Seçilen Dil: \(selectedLanguage)"
        } else {
            // Henüz dil seçilmediyse kullanıcıya bilgi ver
            languageInstructionLabel.text = "Dil seçilmedi"
            startGameButton.isEnabled = false // Butonu devre dışı bırak
            updateStartButtonAppearance() // Buton görünümünü güncelle
        }
    }

    // MARK: - IBActions

    // "Oyuna Başla" butonuna tıklandığında çalışır
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        // Önce bir dilin seçildiğinden emin ol
        guard let selectedLanguageCode = self.selectedLanguageCode else {
            languageInstructionLabel.text = "Lütfen önce bir dil seçin."
            languageInstructionLabel.textColor = UIColor.systemRed
            return
        }

        // Kullanıcıya kelime yükleniyor mesajını göster
        languageInstructionLabel.text = "Kelime yükleniyor..."
        startGameButton.isEnabled = false // Butonu tekrar tıklanmayı önlemek için devre dışı bırak
        updateStartButtonAppearance() // Buton görünümünü güncelle

        // Rastgele kelimeyi API'den çek
        fetchRandomWord(withLanguageCode: selectedLanguageCode) { randomWord in
            // API yanıtı ana iş parçacığında işlenmeli
            DispatchQueue.main.async {
                if let word = randomWord {
                    // Eğer kelime başarıyla geldiyse, oyun ekranına geçiş yap
                    self.performSegue(withIdentifier: "goToGameScene", sender: word)
                } else {
                    // Kelime yüklenirken bir hata oluştuysa kullanıcıya bildir
                    self.languageInstructionLabel.text = "Kelime yüklenirken hata oluştu."
                    self.startGameButton.isEnabled = true // Butonu tekrar etkinleştir
                    self.updateStartButtonAppearance() // Buton görünümünü güncelle
                }
            }
        }
    }

    // MARK: - Navigation

    // Segue gerçekleşmeden önce çağrılır
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGameScene" {
            // Hedef ViewController'ı al
            if let gameVC = segue.destination as? ViewController, let word = sender as? String {
                // Oyun ekranına seçilen dili ve kelimeyi gönder
                gameVC.currentLanguage = selectedLanguage
                gameVC.currentWordSet = word
                print("MainMenuViewController -> ViewController: Kelime gönderildi: \(word), Dil: \(String(describing: selectedLanguage))") // Debug
            } else {
                print("HATA: ViewController'a geçiş başarısız!") // Debug
            }
        }
    }

    // MARK: - View Lifecycle

    // View her göründüğünde çağrılır
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Sayfa her göründüğünde dil seçiminin geçerli olduğundan emin ol
        if selectedLanguageCode == nil {
            languageInstructionLabel.text = "Dil seçilmedi"
            startGameButton.isEnabled = false
            updateStartButtonAppearance()
        } else {
            updateLanguageInstructionLabel() // Veya başka bir bilgilendirici metin
            startGameButton.isEnabled = true
            updateStartButtonAppearance()
        }
    }

    // MARK: - Deinitialization

    deinit {
        print("MainMenuViewController serbest bırakıldı") // Debug
    }
}
