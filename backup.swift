
import UIKit

class LoadingIdcardViewController222: UIViewController {
    
    var imageData: Data?

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "주민등록증 인식 진행중입니다.\n잠시만 기다려주세요."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .red
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
            loadingLabel.bottomAnchor.constraint(equalTo: activityIndicatorView.topAnchor, constant: -20)
        ])
        
        activityIndicatorView.startAnimating()
        
        // 이미지 업로드 요청
        uploadImageToServer(imageData: imageData)
    }
    
    func showRecognitionResult(classId: Int, className: String, answer: String) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating() // 로딩 중지
            
            let resultLabel = UILabel()
            resultLabel.text = "class_id: \(classId), class_name: \(className), answer: \(answer)"
            resultLabel.numberOfLines = 0
            resultLabel.textAlignment = .center
            resultLabel.font = UIFont.systemFont(ofSize: 18)
            resultLabel.textColor = .black
            resultLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(resultLabel)
            
            NSLayoutConstraint.activate([
                resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                resultLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
            
            // 인식 결과 화면으로 전환
            let recognitionVC = RecognitionIdcardViewController() // 결과 데이터 전달
            self.navigationController?.pushViewController(recognitionVC, animated: true)
        }
    }
    
    func uploadImageToServer(imageData: Data?) {
        guard let imageData = imageData else {
            return
        }
        
        let serverURL = URL(string: "http://222.122.67.140:4995")! // 실제 서버 주소로 대체해야 합니다
        
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
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating() // 로딩 중지
            }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // 서버에서 온 데이터 처리
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonDict = jsonObject as? [String: Any],
               let classId = jsonDict["class_id"] as? Int,
               let className = jsonDict["class_name"] as? String,
               let answer = jsonDict["answer"] as? String {
                self.showRecognitionResult(classId: classId, className: className, answer: answer)

            }
        }
        
        task.resume()
    }
}

