//
//  AIService.swift
//  AINotesApp
//

import Foundation
import NaturalLanguage

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    // MARK: - Summarize Text
    func summarize(_ text: String, maxSentences: Int = 3) -> String {
        guard !text.isEmpty else { return "" }
        
        // Tokenize into sentences
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
            return true
        }
        
        // If text is short, return as is
        if sentences.count <= maxSentences {
            return text
        }
        
        // Score sentences based on word frequency
        let scoredSentences = rankSentences(sentences)
        
        // Get top N sentences
        let topSentences = Array(scoredSentences
            .sorted { $0.score > $1.score }
            .prefix(maxSentences))
            .sorted { $0.index < $1.index }
        
        return topSentences.map { $0.sentence }.joined(separator: " ")
    }
    
    // MARK: - Extract Keywords
    func extractKeywords(from text: String, limit: Int = 5) -> [String] {
        guard !text.isEmpty else { return [] }
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        var keywords: [String: Int] = [:]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                            unit: .word,
                            scheme: .lexicalClass,
                            options: [.omitWhitespace, .omitPunctuation]) { tag, range in
            if tag == .noun || tag == .verb {
                let word = String(text[range]).lowercased()
                if word.count > 3 { // Filter short words
                    keywords[word, default: 0] += 1
                }
            }
            return true
        }
        
        return Array(keywords.sorted { $0.value > $1.value }.prefix(limit).map { $0.key })
    }
    
    // MARK: - Generate Title
    func generateTitle(from text: String) -> String {
        guard !text.isEmpty else { return "New Note" }
        
        // Get first sentence
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        
        var firstSentence = ""
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            firstSentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return false // Stop after first sentence
        }
        
        // Limit to 50 characters
        if firstSentence.count > 50 {
            let index = firstSentence.index(firstSentence.startIndex, offsetBy: 50)
            return String(firstSentence[..<index]) + "..."
        }
        
        return firstSentence.isEmpty ? "New Note" : firstSentence
    }
    
    // MARK: - Analyze Sentiment
    func analyzeSentiment(_ text: String) -> String {
        guard !text.isEmpty else { return "Neutral" }
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex,
                                       unit: .paragraph,
                                       scheme: .sentimentScore)
        
        guard let sentimentScore = sentiment,
              let score = Double(sentimentScore.rawValue) else {
            return "Neutral"
        }
        
        if score > 0.3 {
            return "Positive 😊"
        } else if score < -0.3 {
            return "Negative 😔"
        } else {
            return "Neutral 😐"
        }
    }
    
    // MARK: - Private Helper Methods
    private func rankSentences(_ sentences: [String]) -> [(sentence: String, score: Double, index: Int)] {
        // Calculate word frequencies
        var wordFreq: [String: Int] = [:]
        
        for sentence in sentences {
            let words = sentence.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty && $0.count > 3 }
            
            for word in words {
                wordFreq[word, default: 0] += 1
            }
        }
        
        // Score each sentence
        return sentences.enumerated().map { index, sentence in
            let words = sentence.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty && $0.count > 3 }
            
            let score = words.reduce(0.0) { sum, word in
                sum + Double(wordFreq[word] ?? 0)
            } / Double(max(words.count, 1))
            
            return (sentence, score, index)
        }
    }
    
    // MARK: - CoreML Model Integration (Optional)
    // Uncomment when DistilBART.mlmodel is added
    /*
    func summarizeWithCoreML(_ text: String) async throws -> String {
        guard let model = try? DistilBART(configuration: MLModelConfiguration()) else {
            throw NSError(domain: "AIService", code: 500,
                         userInfo: [NSLocalizedDescriptionKey: "Model not found"])
        }
        
        let input = DistilBARTInput(text: text)
        let output = try model.prediction(input: input)
        return output.summary
    }
    */
}
