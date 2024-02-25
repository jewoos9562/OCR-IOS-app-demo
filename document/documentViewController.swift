import UIKit
import AVFoundation

class documentViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private var shouldCaptureImage = false // 이미지 캡처 여부 플래그
    private var capturedImage: UIImage? // 캡처된 이미지 저장 변수
    private let captureSession = AVCaptureSession()
    private var croppedImage: UIImage?
    
    private var origin: CGPoint = .zero
    private var rectSize = CGSize(width: 300, height: 190)
     
    private var rectangleLayer: CAShapeLayer?
    
    
    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("촬영하기", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(captureButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],mediaType: .video, position: .back).devices.first else {
            fatalError("No back camera device found.")
        }
        
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(cameraInput)
            
            // 자동 초점 모드를 설정합니다.
            if device.isFocusModeSupported(.continuousAutoFocus) {
                print("Focus mode 실행중")
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
                print(device)
            }
        } catch {
            fatalError("Error setting up camera input: \(error.localizedDescription)")
        }
    }
    
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private func showCameraFeed() {
            self.previewLayer.videoGravity = .resize
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.frame
        }
        
    private func setCameraOutput() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Call drawRectangle() to redraw the rectangle when returning to this view
        drawRectangle()
    }
    
    
    private func drawRectangle() {
        guard rectangleLayer == nil else { return }
        
        let rectSize_temp = CGSize(width: view.bounds.size.width*0.95, height: view.bounds.size.width*0.95*1.618)
        rectSize=rectSize_temp
        print(rectSize)
        let origin_temp = CGPoint(x: (view.bounds.width - rectSize.width) / 2, y: (view.bounds.height - rectSize.height) / 2)
        
        
        origin=origin_temp
        print(origin)
        
        
        let rectanglePath = UIBezierPath(rect: CGRect(origin: .zero, size: view.bounds.size))
        let holePath = UIBezierPath(rect: CGRect(origin: origin, size: rectSize))
        rectanglePath.append(holePath)
        rectanglePath.usesEvenOddFillRule = true
        
        let cornerSize: CGFloat = 20
        let cornerPath = UIBezierPath()
        
        // Top-left corner
        cornerPath.move(to: CGPoint(x: origin.x, y: origin.y + cornerSize))
        cornerPath.addLine(to: CGPoint(x: origin.x, y: origin.y))
        cornerPath.addLine(to: CGPoint(x: origin.x + cornerSize, y: origin.y))
        
        // Top-right corner
        cornerPath.move(to: CGPoint(x: origin.x + rectSize.width - cornerSize, y: origin.y))
        cornerPath.addLine(to: CGPoint(x: origin.x + rectSize.width, y: origin.y))
        cornerPath.addLine(to: CGPoint(x: origin.x + rectSize.width, y: origin.y + cornerSize))
        
        // Bottom-left corner
        cornerPath.move(to: CGPoint(x: origin.x, y: origin.y + rectSize.height - cornerSize))
        cornerPath.addLine(to: CGPoint(x: origin.x, y: origin.y + rectSize.height))
        cornerPath.addLine(to: CGPoint(x: origin.x + cornerSize, y: origin.y + rectSize.height))
        
        // Bottom-right corner
        cornerPath.move(to: CGPoint(x: origin.x + rectSize.width - cornerSize, y: origin.y + rectSize.height))
        cornerPath.addLine(to: CGPoint(x: origin.x + rectSize.width, y: origin.y + rectSize.height))
        cornerPath.addLine(to: CGPoint(x: origin.x + rectSize.width, y: origin.y + rectSize.height - cornerSize))
        
        rectangleLayer = CAShapeLayer()
        rectangleLayer?.path = rectanglePath.cgPath
        rectangleLayer?.fillRule = .evenOdd
        rectangleLayer?.fillColor = UIColor(white: 0, alpha: 0.7).cgColor // 불투명 검은색 배경
        
        let cornerLayer = CAShapeLayer()
        cornerLayer.path = cornerPath.cgPath
        cornerLayer.strokeColor = UIColor.white.cgColor
        cornerLayer.lineWidth = 2.0
        cornerLayer.fillColor = UIColor.clear.cgColor
        
        previewLayer.addSublayer(rectangleLayer!)
        previewLayer.addSublayer(cornerLayer)
    }


    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            if self.shouldCaptureImage {
                if let image = self.captureImageFromSampleBuffer(sampleBuffer) {
                    self.capturedImage = image
                    self.shouldCaptureImage = false
                    self.showCapturedImage()
                }
            }
            self.drawRectangle()

        }
    }
    
    private func captureImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    

    private func showCapturedImage() {
        guard let capturedImage = capturedImage else { return }

        let imageSize = capturedImage.size
        let imageViewSize = previewLayer.frame.size // 화면에 표시되는 미리보기 이미지의 크기

        print("origin : \(origin)")
        print("rectSize : \(rectSize)")
        print("imageViewSize : \(imageViewSize)")
        print("imageSize : \(imageSize)")
        
        
        // 직사각형의 위치와 크기를 미리보기 이미지 내의 좌표로 변환
        let transformedOrigin = CGPoint(x: origin.x * (imageSize.width / imageViewSize.width), y: origin.y * (imageSize.height / imageViewSize.height))
        let transformedRectSize = CGSize(width: rectSize.width * (imageSize.width / imageViewSize.width), height: rectSize.height * (imageSize.height / imageViewSize.height))
        
        print("transformedOrigin : \(transformedOrigin)")
        print("transformedRectSize : \(transformedRectSize)")
        
        
        // 촬영 이미지에서 직사각형 영역을 잘라내어 croppedImage에 저장
        if let croppedCGImage = capturedImage.cgImage?.cropping(to: CGRect(origin: transformedOrigin, size: transformedRectSize)) {
            let croppedImage = UIImage(cgImage: croppedCGImage)
            
            let showVC = documentShowController()

            showVC.croppedImage = croppedImage
            showVC.origin = origin
            showVC.rectSize = rectSize
            navigationController?.pushViewController(showVC, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCameraInput()
        self.showCameraFeed()
        self.setCameraOutput()
        if captureSession.canSetSessionPreset(AVCaptureSession.Preset.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        }
        self.captureSession.startRunning()
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        // 기존의 버튼 제약 수정
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo : view.bottomAnchor, constant: -60), // 아래쪽으로 이동
            captureButton.widthAnchor.constraint(equalToConstant: 120),
            captureButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        view.backgroundColor = UIColor.clear
    }

    @objc private func captureButtonPressed(_ sender: UIButton) {
        shouldCaptureImage = true
    }
    
}




