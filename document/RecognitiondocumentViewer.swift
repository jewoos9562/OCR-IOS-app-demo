import UIKit

class RecognitiondocumentViewController: UIViewController {
    
    var image: UIImage?
    var resultImage: UIImage? // 결과 이미지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
                
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        // 이미지 레이아웃 설정
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.widthAnchor.constraint(equalToConstant: view.bounds.width - 40), // 이미지 너비 조정
            imageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.95 * 1.618) // 이미지 높이 조정
        ])
        
        // 결과 이미지 뷰 생성 및 설정
        let resultImageView = UIImageView()
        resultImageView.contentMode = .scaleAspectFit
        resultImageView.translatesAutoresizingMaskIntoConstraints = false
        resultImageView.image = resultImage
        
        view.addSubview(resultImageView)
        
        // 결과 이미지 레이아웃 설정
        NSLayoutConstraint.activate([
            resultImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultImageView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10), // 결과 이미지를 imageView 아래에 배치
            resultImageView.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.95),
            resultImageView.heightAnchor.constraint(equalToConstant: view.bounds.width * 0.95 * 1.618)
        ])
        
        // 다시 촬영하기 버튼 추가
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("다시 촬영하기", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.backgroundColor = .blue
        retryButton.layer.cornerRadius = 10.0
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
            retryButton.widthAnchor.constraint(equalToConstant: 150),
            retryButton.heightAnchor.constraint(equalToConstant: 50),
            
            goToMainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            goToMainButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            goToMainButton.widthAnchor.constraint(equalToConstant: 150),
            goToMainButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 뒤로 가기 버튼 숨김
        navigationItem.hidesBackButton = true
    }
    
    // 다시 촬영하기 버튼을 눌렀을 때 호출되는 메서드
    @objc func retryButtonTapped() {
        if let documentVC = navigationController?.viewControllers.first(where: { $0 is documentViewController }) {
            navigationController?.popToViewController(documentVC, animated: true)
        }
    }
    
    // 메인 화면으로 가는 버튼을 눌렀을 때 호출되는 메서드
    @objc func goToMainButtonTapped() {
        if let mainVC = navigationController?.viewControllers.first(where: { $0 is ViewController }) {
            navigationController?.popToViewController(mainVC, animated: true)
        }
    }
}

