import UIKit

class LoadingIdcardViewController: UIViewController {
    
    var imageData: Data?

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "주민등록증 인식중\n잠시만 기다려주세요"
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
        
        //let serverURL = URL(string: "http://192.168.155.48:5012")!
        let serverURL = URL(string: "http://222.122.67.140:5010")! 
        
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
                    
                    if let name = jsonObject["이름"] as? String,
                       let idnum = jsonObject["주민등록번호"] as? String,
                       let base64ImageString = jsonObject["image"] as? String,
                       let imageData = Data(base64Encoded: base64ImageString),
                       let image = UIImage(data: imageData),
                       let date = jsonObject["발급일자"] as? String {
                        DispatchQueue.main.async {
                            // RecognitionIdcardViewController를 초기화하고 데이터를 설정한 후 전환
                            let recognitionVC = RecognitionIdcardViewController()
                            recognitionVC.name = name
                            recognitionVC.idnum = idnum
                            recognitionVC.date = date
                            recognitionVC.image=image
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
