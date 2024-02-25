import UIKit

class LoadingcreditcardViewController: UIViewController {
    
    var imageData: Data?
    var is_horizontal: Bool?

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "신용카드 인식중\n잠시만 기다려주세요"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .systemRed
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(activityIndicatorView)
        view.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 20)
        ])
        
        activityIndicatorView.startAnimating()
        
        // 이미지 업로드 요청
        uploadImageToServer(imageData: imageData)
    }
    
    func uploadImageToServer(imageData: Data?) {
        guard let imageData = imageData else {
            return
        }
        
        var serverURL: URL
        if let isHorizontal = is_horizontal {

            if isHorizontal {
                serverURL = URL(string: "http://222.122.67.140:5013")!
                print("가로형 신용카드 API 실행")
            } else {
                serverURL = URL(string: "http://222.122.67.140:5014")!
                print("세로형 신용카드 API 실행")
            }
        } else {
            // is_horizontal이 nil일 경우 기본 서버 URL을 설정하거나, 다른 처리를 수행
            serverURL = URL(string: "http://default-server-url.com")!
        }
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var formData = Data()
        
        formData.append(contentsOf: "--\(boundary)\r\n".utf8)
        formData.append(contentsOf: "Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".utf8)
        formData.append(contentsOf: "Content-Type: image/jpeg\r\n\r\n".utf8)
        formData.append(imageData)
        formData.append(contentsOf: "\r\n".utf8)
        formData.append(contentsOf: "--\(boundary)--\r\n".utf8)
        
        request.httpBody = formData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let responseDataString = String(data: data, encoding: .utf8) {
                print("Server Response: \(responseDataString)")
            }
            
            // 서버에서 온 데이터 처리
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                    
                    if let base64ImageString = jsonObject["image"] as? String,
                       let imageData = Data(base64Encoded: base64ImageString),
                       let image = UIImage(data: imageData),
                       let card_num = jsonObject["card_num"] as? String,
                       let date = jsonObject["date"] as? String
                    {
                        DispatchQueue.main.async {
                            // RecognitioncreditcardViewController를 초기화하고 데이터를 설정한 후 전환
                            let recognitionVC = RecognitioncreditcardViewController()

                            recognitionVC.image=image
                            recognitionVC.card_num=card_num
                            recognitionVC.date=date
                            self.navigationController?.pushViewController(recognitionVC, animated: true)
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
}

