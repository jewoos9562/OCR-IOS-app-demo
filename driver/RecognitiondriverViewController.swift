import UIKit

class RecognitiondriverViewController: UIViewController {
    
    var name: String?
    var idnum: String?
    var drnum: String?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
                
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        // 이미지 레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width - 40), // 이미지 너비 조정
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.7) // 이미지 높이 조정
        ])
        
        // 이름 표시
        let nameLabel = UILabel()
        nameLabel.text = "이름: \(name ?? "N/A")"
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        
        // 주민등록번호 표시
        let idnumLabel = UILabel()
        idnumLabel.text = "주민등록번호: \(idnum ?? "N/A")"
        idnumLabel.textColor = .white
        idnumLabel.textAlignment = .center
        idnumLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(idnumLabel)
        
        // 발급일자 표시
        let drnumLabel = UILabel()
        drnumLabel.text = "운전면허증번호: \(drnum ?? "N/A")"
        drnumLabel.textColor = .white
        drnumLabel.textAlignment = .center
        drnumLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(drnumLabel)
        
        // 버튼 레이아웃 설정
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            
            idnumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            idnumLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            
            drnumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            drnumLabel.topAnchor.constraint(equalTo: idnumLabel.bottomAnchor, constant: 20)
        ])
        
        // 다시 촬영하기 버튼 추가
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("다시 촬영하기", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.backgroundColor = .blue  // 버튼 배경색 설정
        retryButton.layer.cornerRadius = 10.0  // 버튼의 모서리를 둥글게 만듦
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitleColor(.white, for: .normal)
        
        view.addSubview(retryButton)
        
        // 메인 화면으로 가는 버튼 추가
        let goToMainButton = UIButton(type: .system)
        goToMainButton.setTitle("메인 화면으로 이동", for: .normal)
        goToMainButton.addTarget(self, action: #selector(goToMainButtonTapped), for: .touchUpInside)
        goToMainButton.backgroundColor = .red
        goToMainButton.layer.cornerRadius = 10.0
        goToMainButton.translatesAutoresizingMaskIntoConstraints = false
        goToMainButton.setTitleColor(.white, for: .normal)
        
        view.addSubview(goToMainButton)
        
        // 버튼 레이아웃 설정
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            retryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            retryButton.widthAnchor.constraint(equalToConstant: 150), // 너비 조정
            retryButton.heightAnchor.constraint(equalToConstant: 50),
            
            goToMainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            goToMainButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            goToMainButton.widthAnchor.constraint(equalToConstant: 150), // 너비 조정
            goToMainButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 뒤로 가기 버튼 숨김
        navigationItem.hidesBackButton = true
    }
    
    // 다시 촬영하기 버튼을 눌렀을 때 호출되는 메서드
    @objc func retryButtonTapped() {
        if let driverVC = navigationController?.viewControllers.first(where: { $0 is driverViewController }) {
            navigationController?.popToViewController(driverVC, animated: true)
        }
    }
    
    // 메인 화면으로 가는 버튼을 눌렀을 때 호출되는 메서드
    @objc func goToMainButtonTapped() {
        if let mainVC = navigationController?.viewControllers.first(where: { $0 is ViewController }) {
            navigationController?.popToViewController(mainVC, animated: true)
        }
    }
}

