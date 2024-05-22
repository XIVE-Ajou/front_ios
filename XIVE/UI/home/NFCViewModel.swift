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

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("이 장치에서는 NFC를 지원하지 않습니다.")
            return
        }

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "물건에 가까이 대고 스캔하세요."
        nfcSession?.begin()
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
                if let text = String(data: record.payload.advanced(by: 3), encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.nfcContent = text  // NFC 태그 내용 저장
                        self.urlDetected?(text)  // URL을 처리하는 콜백 호출
                        self.sendToServer(url: text)  // 서버로 전송
                    }
                }
            }
        }
    }
    
    public func sendToServer(url: String) {
        guard let requestUrl = URL(string: "http://18.219.56.184:8080/decrypt") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // URL 수정 (http://를 제거)
        let modifiedUrl = url.replacingOccurrences(of: "http://", with: "")
        
        // JSON 요청 바디 생성
        let requestBody = ["url": modifiedUrl]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
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
        guard let requestUrl = URL(string: "https://api.xive.co.kr/api/tickets") else { return }
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
        
        // 요청 바디에 eventId, nfcId, seatNumber 추가
        let requestBody: [String: Any] = [
            "eventId": eventId,
            "nfcId": nfcId,
            "seatNumber": seatNumber
        ]
        print(requestBody)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
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
            if let responseString = String(data: data, encoding: .utf8) {
                print("Ticket API response: \(responseString)")
            }
        }
        task.resume()
    }
}
