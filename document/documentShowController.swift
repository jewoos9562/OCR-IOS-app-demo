import UIKit
import Foundation

class documentShowController: UIViewController {

    var croppedImage: UIImage?
    var origin: CGPoint?
    var rectSize: CGSize?
    
    private lazy var imageView2: UIImageView = {
        let imageView2 = UIImageView()
        imageView2.contentMode = .scaleToFill
        imageView2.clipsToBounds = true
        return imageView2
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(imageView2)
        imageView2.translatesAutoresizingMaskIntoConstraints = false
        
        if let origin = origin, let rectSize = rectSize {
            NSLayoutConstraint.activate([
                imageView2.topAnchor.constraint(equalTo: view.topAnchor, constant: origin.y),
                imageView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: origin.x),
                imageView2.widthAnchor.constraint(equalToConstant: rectSize.width),
                imageView2.heightAnchor.constraint(equalToConstant: rectSize.height)
            ])
        } else {
            NSLayoutConstraint.activate([
                imageView2.topAnchor.constraint(equalTo: view.topAnchor),
                imageView2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView2.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        if let image = croppedImage {
            imageView2.image = image
        }
        
        // 사각형 영역 주변에 검은색 테두리를 추가하는 UIView 생성
        let borderView = UIView()
        borderView.layer.borderWidth = 0.0
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: imageView2.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: imageView2.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: imageView2.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: imageView2.bottomAnchor)
        ])
        
        // '주민등록증 인식' 버튼을 생성하고 툴바에 추가
        let button = UIButton(type: .system)
        button.setTitle("문서 인식", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10.0 // 둥근 테두리 설정
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            //button.topAnchor.constraint(equalTo: imageView2.bottomAnchor, constant: -20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo : view.bottomAnchor, constant: -60),
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
            
            let loadingVC = LoadingdocumentViewController()
            loadingVC.imageData = imageData
            navigationController?.pushViewController(loadingVC, animated: true)
            // ...
        }

    
}


