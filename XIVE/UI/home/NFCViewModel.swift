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
    var urlDetected: ((String) -> Void)?
    @Published var urlToLoad: String?
    
    // 서버 응답 변수들
    @Published var eventWebUrl: String? {
        didSet {
            if let eventWebUrl = eventWebUrl {
                UserDefaults.standard.set(eventWebUrl, forKey: "eventWebUrl")
            }
        }
    }
    @Published var ticketId: Int?
    private var isRequestInProgress = false

    override init() {
        super.init()
        if let savedEventWebUrl = UserDefaults.standard.string(forKey: "eventWebUrl") {
            self.eventWebUrl = savedEventWebUrl
        }
    }

    func handleDetectedURL(url: String) {
        urlToLoad = url
        let formattedToken = formatToken(url: url)
        print("Detected URL: \(url)")
        print("Formatted Token: \(formattedToken)")
        getEventDetails(eventToken: formattedToken)
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
            NotificationCenter.default.post(name: NSNotification.Name("NFCSessionEnded"), object: nil)
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let text = String(data: record.payload, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.nfcContent = self.extractContent(from: text)
                        self.urlDetected?(self.nfcContent)
                        self.handleDetectedURL(url: self.nfcContent)
                        // 티켓 태그 날짜를 저장
                        UserDefaults.standard.set(Date(), forKey: "ticketTaggedDate")
                    }
                }
            }
        }
    }

    func extractContent(from text: String) -> String {
        return String(text.dropFirst(3))
    }

    func formatToken(url: String) -> String {
        let pattern = "^(stamp|event):[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
        if let range = url.range(of: pattern, options: .regularExpression) {
            return String(url[range])
        }
        return url
    }

    func getEventDetails(eventToken: String) {
        guard var urlComponents = URLComponents(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/event/tagging") else { return }
        urlComponents.queryItems = [URLQueryItem(name: "eventToken", value: eventToken)]
        guard let requestUrl = urlComponents.url else { return }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"

        // UserDefaults에서 AccessToken과 RefreshToken 읽기
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            return
        }

        // 헤더에 AccessToken과 RefreshToken 추가
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching event details: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Server response: \(json)")
                    if let eventId = json["eventId"] as? Int,
                       let eventWebUrl = json["eventWebUrl"] as? String {
                        DispatchQueue.main.async {
                            self.eventWebUrl = eventWebUrl
                            print("Fetched eventId: \(eventId), eventWebUrl: \(eventWebUrl)")
                            self.sendTicketData(eventId: eventId)
                        }
                    } else {
                        print("Invalid response data")
                    }
                } else {
                    print("Invalid response data format")
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    func handleStampTagging(eventToken: String, completion: @escaping (Int?) -> Void) {
        let trimmedToken = eventToken.trimmingCharacters(in: .whitespaces)
        print("Trimmed Token: \(trimmedToken)")

        // Form the URL with query parameters
        guard var urlComponents = URLComponents(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/stamps/tagging") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        urlComponents.queryItems = [URLQueryItem(name: "stampToken", value: trimmedToken)]
        guard let requestUrl = urlComponents.url else {
            print("Invalid URL")
            completion(nil)
            return
        }

        print("Request URL: \(requestUrl)")

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"

        // UserDefaults에서 AccessToken과 RefreshToken 읽기
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            completion(nil)
            return
        }

        // 인증 헤더 추가
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching stamp details: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                if let responseDataString = String(data: data, encoding: .utf8) {
                    print("Full Response Data: \(responseDataString)")
                }

                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let stampId = json["stampId"] as? Int {
                        completion(stampId)
                    } else {
                        print("Invalid response data")
                        completion(nil)
                    }
                } else {
                    print("Invalid response data format")
                    completion(nil)
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    public func sendTicketData(eventId: Int) {
        guard !isRequestInProgress else {
            print("Request already in progress, skipping...")
            return
        }

        isRequestInProgress = true

        guard let requestUrl = URL(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/exhibition-tickets") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        // UserDefaults에서 AccessToken과 RefreshToken 읽기
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            isRequestInProgress = false
            return
        }

        // HTTP 헤더에 AccessToken과 RefreshToken 추가
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")

        let requestBody: [String: Any] = [
            "eventId": eventId
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("JSON serialization error: \(error.localizedDescription)")
            isRequestInProgress = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { self.isRequestInProgress = false }

            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else { return }
            do {
                if let responseDataString = String(data: data, encoding: .utf8) {
                    print("Full Response Data: \(responseDataString)")
                }

                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Server response: \(jsonResponse)")

                    // JSON 응답에서 eventWebUrl 및 ticketId 값을 추출하여 저장
                    DispatchQueue.main.async {
                        if let eventWebUrl = jsonResponse["eventWebUrl"] as? String {
                            self.eventWebUrl = eventWebUrl
                            print("Updated eventWebUrl: \(eventWebUrl)")
                        } else {
                            print("eventWebUrl을 찾을 수 없습니다.")
                        }

                        if let ticketId = jsonResponse["ticketId"] as? Int {
                            self.ticketId = ticketId
                            print("Received ticketId: \(ticketId)")
                        } else {
                            print("ticketId를 찾을 수 없습니다.")
                        }
                    }
                } else {
                    print("Invalid response data")
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
