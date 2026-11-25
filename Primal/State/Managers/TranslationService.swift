//
//  TranslationService.swift
//  Primal
//
//  Created for Lightning Bounties by johnson251718-Agent
//

import Foundation

/// Service for translating text using LibreTranslate API
/// Uses the free public instance at libretranslate.com
class TranslationService {
    static let shared = TranslationService()
    
    private let baseURL = "https://libretranslate.com"
    
    /// Supported languages
    struct Language {
        let code: String
        let name: String
    }
    
    /// Common languages for translation
    static let supportedLanguages: [Language] = [
        Language(code: "en", name: "English"),
        Language(code: "es", name: "Spanish"),
        Language(code: "fr", name: "French"),
        Language(code: "de", name: "German"),
        Language(code: "it", name: "Italian"),
        Language(code: "pt", name: "Portuguese"),
        Language(code: "zh", name: "Chinese"),
        Language(code: "ja", name: "Japanese"),
        Language(code: "ko", name: "Korean"),
        Language(code: "ru", name: "Russian"),
        Language(code: "ar", name: "Arabic")
    ]
    
    /// User's preferred target language (defaults to device language)
    var targetLanguage: String {
        get {
            UserDefaults.standard.string(forKey: "translationTargetLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "translationTargetLanguage")
        }
    }
    
    /// Translates text to the target language
    /// - Parameters:
    ///   - text: The text to translate
    ///   - sourceLanguage: Source language code (auto-detect if nil)
    ///   - completion: Callback with translated text or error
    func translate(
        _ text: String,
        from sourceLanguage: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/translate") else {
            completion(.failure(TranslationError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "q": text,
            "source": sourceLanguage ?? "auto",
            "target": targetLanguage,
            "format": "text"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(TranslationError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let translatedText = json["translatedText"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(translatedText))
                    }
                } else if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let errorMessage = json["error"] as? String {
                    DispatchQueue.main.async {
                        completion(.failure(TranslationError.apiError(errorMessage)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(TranslationError.invalidResponse))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Detects the language of the given text
    func detectLanguage(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/detect") else {
            completion(.failure(TranslationError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["q": text]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(TranslationError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let first = json.first,
                   let language = first["language"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(language))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(TranslationError.invalidResponse))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

enum TranslationError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid translation service URL"
        case .noData:
            return "No data received from translation service"
        case .invalidResponse:
            return "Invalid response from translation service"
        case .apiError(let message):
            return "Translation error: \(message)"
        }
    }
}
