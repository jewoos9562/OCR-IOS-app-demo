import UIKit
import AVFoundation

class creditcardViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var shouldCaptureImage = false // 이미지 캡처 여부 플래그
    private var capturedImage: UIImage? // 캡처된 이미지 저장 변수
    private let captureSession = AVCaptureSession()
    
    private var croppedImage: UIImage?
    
    private var origin: CGPoint = .zero
    private var rectSize = CGSize(width: 0, height: 0)
    
    private var rectangleLayer: CAShapeLayer?
    private var cornerLayer: CAShapeLayer?
    private var previousIsHorizontal = true
    
    private var is_horizontal = true // 가로 형태 여부를 나타내는 변수
    
    private lazy var horizontalCardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("가로형 신용카드", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(horizontalCardButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var verticalCardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("세로형 신용카드", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(verticalCardButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
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
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
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
        drawRectangle(is_horizontal: self.is_horizontal)
    }
    
    
    private func drawRectangle(is_horizontal: Bool) {
        
        rectangleLayer?.removeFromSuperlayer()
        cornerLayer?.removeFromSuperlayer()
        
        let rectSize_temp: CGSize
        if is_horizontal {
            rectSize_temp = CGSize(width: 300, height: 190)
        } else {
            rectSize_temp = CGSize(width: 190, height: 300)
        }
        
        
        let origin_temp = CGPoint(x: (view.bounds.width - rectSize.width) / 2, y: (view.bounds.height - rectSize.height) / 2)
        
        
        origin=origin_temp
        rectSize=rectSize_temp
        
        
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
        
        cornerLayer = CAShapeLayer()
        cornerLayer?.path = cornerPath.cgPath
        cornerLayer?.strokeColor = UIColor.white.cgColor
        cornerLayer?.lineWidth = 2.0
        cornerLayer?.fillColor = UIColor.clear.cgColor
        
        previewLayer.addSublayer(rectangleLayer!)
        previewLayer.addSublayer(cornerLayer!)
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
            self.drawRectangle(is_horizontal: self.is_horizontal) // 여기서 self를 명시적으로 참조

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
            
            
            let showVC = creditcardShowController()
            
            print(origin, rectSize)
            showVC.croppedImage = croppedImage
            showVC.origin = origin
            showVC.rectSize = rectSize
            showVC.is_horizontal=is_horizontal
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
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo : view.bottomAnchor, constant: -60), // 아래쪽으로 이동
            captureButton.widthAnchor.constraint(equalToConstant: 120),
            captureButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(horizontalCardButton)
        horizontalCardButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalCardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            horizontalCardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            horizontalCardButton.widthAnchor.constraint(equalToConstant: 150),
            horizontalCardButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(verticalCardButton)
        verticalCardButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalCardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            verticalCardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            verticalCardButton.widthAnchor.constraint(equalToConstant: 150),
            verticalCardButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.backgroundColor = UIColor.clear
    }
    
    @objc private func captureButtonPressed(_ sender: UIButton) {
        shouldCaptureImage = true
    }
    
    @objc private func horizontalCardButtonPressed(_ sender: UIButton) {
        self.is_horizontal = true
        if is_horizontal != previousIsHorizontal {
            drawRectangle(is_horizontal: self.is_horizontal)
            previousIsHorizontal = is_horizontal
        }
    }
    
    @objc private func verticalCardButtonPressed(_ sender: UIButton) {
        self.is_horizontal = false
        if is_horizontal != previousIsHorizontal {
            drawRectangle(is_horizontal: self.is_horizontal)
            previousIsHorizontal = is_horizontal
        }
    }
}



