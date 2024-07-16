//
//  NFCViewModel.swift
//  XIVE
//
//  Created by 나현흠 on 5/4/24.
//

import Foundation
import CoreNFC

class NFCViewModel: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    var nfcSession: NFCNDEFReaderSession?
    @Published var nfcContent = ""
    var urlDetected: ((String) -> Void)?  // URL 감지 콜백
    @Published var urlToLoad: String?

    // 서버 응답 변수들
    @Published var eventWebUrl: String? {
        didSet {
            if let eventWebUrl = eventWebUrl {
                // 로컬에 저장
                UserDefaults.standard.set(eventWebUrl, forKey: "eventWebUrl")
                print("Saved eventWebUrl to UserDefaults: \(eventWebUrl)")
            }
        }
    }
    
    override init() {
        super.init()
        // 로컬에서 로드
        if let savedEventWebUrl = UserDefaults.standard.string(forKey: "eventWebUrl") {
            self.eventWebUrl = savedEventWebUrl
            print("Loaded eventWebUrl from UserDefaults: \(savedEventWebUrl)")
        }
    }

    func handleDetectedURL(url: String) {
        urlToLoad = url
        eventWebUrl = cleanURL(url: url)  // NFC 태그 내용을 정리하여 eventWebUrl에 저장
        print("Detected URL: \(url)")  // URL 출력
        sendToServer(url: url)
    }

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("이 장치에서는 NFC를 지원하지 않습니다.")
            return
        }

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "티켓의 하단을 휴대폰 상단에 태그해주세요."
        nfcSession?.begin()
        print(eventWebUrl ?? "No eventWebUrl")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC 세션 비활성화: \(error.localizedDescription)")
        DispatchQueue.main.async {
            // 화면 리프레시 로직 추가
            NotificationCenter.default.post(name: NSNotification.Name("NFCSessionEnded"), object: nil)
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let text = String(data: record.payload, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.nfcContent = text  // NFC 태그 내용 저장
                        self.urlDetected?(text)  // URL을 처리하는 콜백 호출
                        self.handleDetectedURL(url: text)  // URL 처리 함수 호출
                    }
                }
            }
        }
    }
    
    // URL에서 앞에 있는 문자나 숫자를 제거하는 함수
    func cleanURL(url: String) -> String {
        let pattern = "^[^a-zA-Z0-9]*"
        let cleanedUrl = url.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        return cleanedUrl
    }

    public func sendToServer(url: String) {
        guard let requestUrl = URL(string: "http://18.219.56.184:8080/decrypt") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // URL 수정 (base URL과 nfc 값 추출 및 결합)
        guard let urlComponents = URLComponents(string: url),
              let nfcQueryItem = urlComponents.queryItems?.first(where: { $0.name == "nfc" }),
              let nfcValue = nfcQueryItem.value else {
            print("Invalid URL format")
            return
        }
        
        // 새로운 변수를 만들어 수정된 URL 생성
        var modifiedUrl = "\(urlComponents.host ?? "")\(urlComponents.path)\(nfcValue)"
        
        // 수정된 URL 로그 출력
        print("Modified URL before cleaning: \(modifiedUrl)")
        
        // modifiedUrl을 정리하여 eventWebUrl에 저장
        modifiedUrl = cleanURL(url: modifiedUrl)
        DispatchQueue.main.async {
            self.eventWebUrl = modifiedUrl
        }
        
        print("Modified URL after cleaning: \(modifiedUrl)")

        // JSON 요청 바디 생성
        let requestBody = ["url": modifiedUrl]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization error: \(error.localizedDescription)")
            return
        }
        
        // 서버에 요청 전송
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            do {
                if let serverResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Server response: \(serverResponse)")
                    if let eventIdStr = serverResponse["eventId"] as? String,
                       let nfcIdStr = serverResponse["nfcId"] as? String,
                       let seatNumber = serverResponse["seatNumber"] as? String,
                       let eventId = Int(eventIdStr),
                       let nfcId = Int(nfcIdStr) {
                        self.sendTicketData(eventId: eventId, nfcId: nfcId, seatNumber: seatNumber)
                    } else {
                        print("Invalid response data or failed to convert strings to integers")
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    private func sendTicketData(eventId: Int, nfcId: Int, seatNumber: String) {
        guard let requestUrl = URL(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/tickets") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // UserDefaults에서 AccessToken과 RefreshToken 읽기
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            return
        }
        
        // HTTP 헤더에 AccessToken과 RefreshToken 추가
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        
        // 요청 바디에 eventId, nfcId, seatNumber, eventWebUrl 추가
        let requestBody: [String: Any] = [
            "eventId": eventId,
            "nfcId": nfcId,
            "seatNumber": seatNumber,
            "eventWebUrl": eventWebUrl ?? ""  // eventWebUrl을 추가
        ]
        print(requestBody)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization error: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Server response: \(jsonResponse)")
                    
                    // JSON 응답에서 eventWebUrl 값을 추출하여 저장
                    DispatchQueue.main.async {
                        if let eventWebUrl = jsonResponse["eventWebUrl"] as? String {
                            self.eventWebUrl = eventWebUrl
                            print("Updated eventWebUrl: \(eventWebUrl)")  // Updated eventWebUrl 출력
                        } else {
                            print("eventWebUrl을 찾을 수 없습니다.")
                        }
                    }
                } else {
                    print("Invalid response data")
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
