import UIKit
import Foundation

class creditcardShowController: UIViewController {

    var croppedImage: UIImage?
    var origin: CGPoint?
    var rectSize: CGSize?
    var is_horizontal: Bool?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let origin = origin, let rectSize = rectSize {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: origin.y),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: origin.x),
                imageView.widthAnchor.constraint(equalToConstant: rectSize.width),
                imageView.heightAnchor.constraint(equalToConstant: rectSize.height)
            ])
        } else {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        if let image = croppedImage {
            imageView.image = image
        }
        
        // 사각형 영역 주변에 검은색 테두리를 추가하는 UIView 생성
        let borderView = UIView()
        borderView.layer.borderWidth = 0.0
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: imageView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        // '주민등록증 인식' 버튼을 생성하고 툴바에 추가
        let button = UIButton(type: .system)
        button.setTitle("신용카드 인식", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10.0 // 둥근 테두리 설정
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 160),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    @objc func nextButtonTapped() {
            // 이미지 업로드 준비
            guard let image = croppedImage,
                  let imageData = image.jpegData(compressionQuality: 1.0) else {
                return
            }
            
            let loadingVC = LoadingcreditcardViewController()
        loadingVC.imageData = imageData;
        loadingVC.is_horizontal = is_horizontal
            navigationController?.pushViewController(loadingVC, animated: true)
            // ...
        }

    
}


