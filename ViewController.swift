import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let logoImageView = UIImageView(image: UIImage(named: "tmax_logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        
        // Layout constraints for the logo image view
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // 조정된 상단 간격
            logoImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            logoImageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.3)
        ])
        
        
        // Create buttons
        let buttons = [
            ("일반 문서", #selector(generalDocumentButtonTapped)),
            ("신용카드", #selector(creditCardButtonTapped)),
            ("주민등록증", #selector(idCardButtonTapped)),
            ("운전면허증", #selector(driverLicenseButtonTapped)),
//            ("테스트", #selector(testButtonTapped))
        ]
        
        // Create vertical stack for the buttons
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 30
        
        buttons.forEach { title, action in
            let button = createMenuButton(title: title, action: action)
            mainStackView.addArrangedSubview(button)
        }
        
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for the main stack view
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 18) // 조정된 상단 간격
        ])
    }
    
    // Button creation helper function
    private func createMenuButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // "navy" 색상을 UIColor 객체로 지정
        let navyColor = UIColor(red: 51/255, green: 51/255, blue: 204/255, alpha: 0.8)
        
        button.backgroundColor = navyColor
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        return button
    }
    // Button action handlers
    @objc func generalDocumentButtonTapped() {
        let documentVC = documentViewController()
        navigationController?.pushViewController(documentVC, animated: true)
    }
    
    @objc func creditCardButtonTapped() {
        let creditcardVC = creditcardViewController()
        navigationController?.pushViewController(creditcardVC, animated: true)
    }
    
    @objc func idCardButtonTapped() {
        let idCardVC = idcardViewController()
        navigationController?.pushViewController(idCardVC, animated: true)
    }
    
    @objc func driverLicenseButtonTapped() {
        let driverVC = driverViewController()
        navigationController?.pushViewController(driverVC, animated: true)
    }
//     @objc func testButtonTapped() {
//         let testVC = testViewController()
//         navigationController?.pushViewController(testVC, animated: true)
//     }
}

