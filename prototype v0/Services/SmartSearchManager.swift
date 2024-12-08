//
//  SmartSearchManager.swift
//  prototype v0
//
//  Created by Shubham Gandhi on 04/12/24.
//

import Foundation
import NaturalLanguage

class SmartSearchManager: ObservableObject {
    static let shared = SmartSearchManager()
    
    private let languageRecognizer = NLLanguageRecognizer()
    private let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
    private let tokenizer = NLTokenizer(unit: .word)
    private let embeddingModel = NLEmbedding.wordEmbedding(for: .english)
    
    let knowledgeBase = [
        // Original entries
        KnowledgeItem(
            title: "How to set up SSO",
            category: "Authentication & Security",
            icon: "lock",
            tags: ["sso", "authentication", "security", "setup", "configuration"]
        ),
        KnowledgeItem(
            title: "Deployment best practices",
            category: "DevOps",
            icon: "server.rack",
            tags: ["deployment", "devops", "best practices", "ci/cd"]
        ),
        KnowledgeItem(
            title: "Employee onboarding process",
            category: "HR",
            icon: "person.badge.plus",
            tags: ["hr", "onboarding", "employees", "process"]
        ),
        
        // Analytics & Insights
        KnowledgeItem(
            title: "Understanding Instagram Engagement Metrics",
            category: "Analytics",
            icon: "chart.bar",
            tags: ["analytics", "engagement", "metrics", "insights", "reporting"]
        ),
        KnowledgeItem(
            title: "Audience Growth Analysis Dashboard",
            category: "Analytics",
            icon: "person.3",
            tags: ["audience", "growth", "analytics", "dashboard", "metrics"]
        ),
        KnowledgeItem(
            title: "Content Performance Tracking",
            category: "Analytics",
            icon: "chart.line.uptrend.xyaxis",
            tags: ["content", "performance", "tracking", "analytics", "posts"]
        ),

        // Campaign Management
        KnowledgeItem(
            title: "Creating Multi-Channel Campaigns",
            category: "Campaigns",
            icon: "bolt.horizontal",
            tags: ["campaigns", "marketing", "strategy", "multi-channel"]
        ),
        KnowledgeItem(
            title: "Influencer Campaign Setup Guide",
            category: "Campaigns",
            icon: "star",
            tags: ["influencer", "campaign", "setup", "collaboration"]
        ),
        KnowledgeItem(
            title: "Story Analytics and Campaign Tracking",
            category: "Campaigns",
            icon: "camera",
            tags: ["stories", "analytics", "tracking", "performance"]
        ),

        // Content Management
        KnowledgeItem(
            title: "Content Calendar Best Practices",
            category: "Content",
            icon: "calendar",
            tags: ["content", "calendar", "planning", "scheduling"]
        ),
        KnowledgeItem(
            title: "Bulk Post Scheduling",
            category: "Content",
            icon: "clock",
            tags: ["scheduling", "posts", "bulk", "automation"]
        ),
        KnowledgeItem(
            title: "Asset Library Management",
            category: "Content",
            icon: "photo.on.rectangle",
            tags: ["assets", "library", "media", "organization"]
        ),

        // Customer Support
        KnowledgeItem(
            title: "DM Automation Setup",
            category: "Support",
            icon: "message",
            tags: ["dm", "automation", "messages", "support"]
        ),
        KnowledgeItem(
            title: "Comment Management Workflow",
            category: "Support",
            icon: "bubble.left.and.bubble.right",
            tags: ["comments", "management", "moderation", "workflow"]
        ),
        KnowledgeItem(
            title: "Support Team Response Templates",
            category: "Support",
            icon: "text.bubble",
            tags: ["templates", "support", "responses", "customer service"]
        ),

        // Reporting
        KnowledgeItem(
            title: "Creating Custom Report Templates",
            category: "Reporting",
            icon: "exclamationmark.bubble",
            tags: ["reports", "templates", "custom", "analytics"]
        ),
        KnowledgeItem(
            title: "Automated Weekly Performance Reports",
            category: "Reporting",
            icon: "chart.bar.doc.horizontal",
            tags: ["automation", "reports", "weekly", "performance"]
        ),
        KnowledgeItem(
            title: "Competitor Analysis Reports",
            category: "Reporting",
            icon: "arrow.triangle.branch",
            tags: ["competitor", "analysis", "reports", "benchmarking"]
        ),

        // Integrations
        KnowledgeItem(
            title: "Instagram API Integration Guide",
            category: "Integrations",
            icon: "link",
            tags: ["api", "integration", "setup", "instagram"]
        ),
        KnowledgeItem(
            title: "Webhook Configuration",
            category: "Integrations",
            icon: "arrow.triangle.branch",
            tags: ["webhooks", "integration", "configuration", "automation"]
        ),
        KnowledgeItem(
            title: "Third-Party Tools Connection",
            category: "Integrations",
            icon: "square.grid.3x3.square",
            tags: ["integration", "tools", "connection", "third-party"]
        ),

        // Automation
        KnowledgeItem(
            title: "Setting Up Auto-Response Rules",
            category: "Automation",
            icon: "gearshape.2",
            tags: ["automation", "responses", "rules", "setup"]
        ),
        KnowledgeItem(
            title: "Engagement Automation Workflows",
            category: "Automation",
            icon: "arrow.triangle.turn.up.right.diamond",
            tags: ["automation", "engagement", "workflow", "responses"]
        ),
        KnowledgeItem(
            title: "Comment Filtering and Auto-Moderation",
            category: "Automation",
            icon: "text.bubble.fill",
            tags: ["comments", "moderation", "automation", "filtering"]
        )
    ]
    
    func search(query: String, onAction: @escaping (String) -> Void) -> [ResultItem] {
        if query.isEmpty { return [] }
        
        var results: [ResultItem] = []
        
        // Process query for intent detection
        let queryLower = query.lowercased()
        
        // After knowledgeBase declaration, add:
        struct ActionPattern {
            let verbs: [String]
            let nouns: [String]
            let icon: String
            let shortcut: String
            let type: String
        }

        let actionPatterns: [ActionPattern] = [
            // Ticket related
            ActionPattern(
                verbs: ["create", "new", "add", "open", "start", "make", "raise", "submit", "file"],
                nouns: ["ticket", "issue", "bug", "problem", "request", "support"],
                icon: "ticket",
                shortcut: "⌘+T",
                type: "ticket"
            ),
            
            // Article related
            ActionPattern(
                verbs: ["create", "new", "add", "write", "publish", "draft", "compose"],
                nouns: ["article", "doc", "document", "guide", "tutorial", "post"],
                icon: "doc.text",
                shortcut: "⌘+N",
                type: "article"
            ),
            
            // Profile related
            ActionPattern(
                verbs: ["create", "new", "add", "setup", "configure", "make"],
                nouns: ["profile", "account", "user", "contact", "person"],
                icon: "person.circle",
                shortcut: "⌘+P",
                type: "profile"
            ),
            
            // Opportunity related
            ActionPattern(
                verbs: ["create", "new", "add", "start", "track", "register"],
                nouns: ["opportunity", "deal", "lead", "sale", "prospect"],
                icon: "chart.line.uptrend.xyaxis",
                shortcut: "⌘+O",
                type: "opportunity"
            ),
            
            // Resource related
            ActionPattern(
                verbs: ["create", "new", "add", "upload", "share", "store"],
                nouns: ["resource", "file", "asset", "document", "attachment"],
                icon: "folder",
                shortcut: "⌘+R",
                type: "resource"
            ),
            
            // Task related
            ActionPattern(
                verbs: ["create", "new", "add", "assign", "schedule"],
                nouns: ["task", "todo", "assignment", "work", "activity"],
                icon: "checklist",
                shortcut: "⌘+K",
                type: "task"
            ),
            
            // Meeting related
            ActionPattern(
                verbs: ["create", "new", "schedule", "setup", "arrange", "book"],
                nouns: ["meeting", "call", "appointment", "session", "discussion"],
                icon: "video",
                shortcut: "⌘+M",
                type: "meeting"
            ),
            
            // Project related
            ActionPattern(
                verbs: ["create", "new", "start", "initialize", "begin"],
                nouns: ["project", "initiative", "program", "campaign"],
                icon: "folder.badge.gearshape",
                shortcut: "⌘+J",
                type: "project"
            )
        ]

        // Add this helper function
        func detectAction(in query: String) -> (ActionPattern, String)? {
            let queryLower = query.lowercased()
            let words = queryLower.components(separatedBy: " ")
            
            for pattern in actionPatterns {
                // Check if query contains any of the verbs and nouns
                let hasVerb = pattern.verbs.contains { verb in
                    words.contains(verb)
                }
                let hasNoun = pattern.nouns.contains { noun in
                    words.contains(noun)
                }
                
                if hasVerb && hasNoun {
                    // Extract title by removing action words
                    let titleWords = words.filter { word in
                        !pattern.verbs.contains(word) && !pattern.nouns.contains(word)
                    }
                    
                    let title = titleWords
                        .map { $0.capitalized }
                        .joined(separator: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    return (pattern, title)
                }
            }
            
            return nil
        }
                
        // Detect action and extract title
        let actionResult = detectAction(in: query)
        
        if let (pattern, title) = actionResult {
            let actionTitle = title.isEmpty
                ? "Create new \(pattern.type)"
                : "Create \(pattern.type): \(title)"
            
            results.append(
                ResultItem(
                    icon: pattern.icon,
                    title: actionTitle,
                    shortcut: pattern.shortcut,
                    action: { onAction("create_\(pattern.type): \(title)") }
                )
            )
            
        } else {
            // AI suggestion (if no action detected)
            results.append(
                ResultItem(
                    icon: "sparkle",
                    title: "Ask AI about '\(query)'",
                    shortcut: "⏎",
                    action: { onAction("ai_query: \(query)") }
                )
            )
        }
        
        // Process query for knowledge base search
        tagger.string = query
        var searchTerms: Set<String> = []
        tagger.enumerateTags(in: query.startIndex..<query.endIndex,
                           unit: .word,
                           scheme: .nameType) { tag, range in
            if tag != nil {
                searchTerms.insert(String(query[range]).lowercased())
            }
            return true
        }
        
        // Score and filter knowledge base
        let scoredItems = knowledgeBase.map { item in
            (item, calculateRelevance(query: query, item: item, searchTerms: searchTerms))
        }
        .filter { $0.1 > 0.3 }
        .sorted(by: { $0.1 > $1.1 })
        .prefix(5)
        
        // Add knowledge base results
        results.append(contentsOf: scoredItems.map { item, _ in
            ResultItem(
                icon: item.icon,
                title: item.title,
                shortcut: "⏎",
                action: { onAction("open_article: \(item.title)") }
            )
        })
        
        // Suggest contextual actions if no direct action detected
        if actionResult == nil && query.count > 2 {
            // Suggest most relevant action based on query content
            let relevantActions = [
                ("ticket", queryLower.contains("issue") || queryLower.contains("problem")),
                ("article", queryLower.contains("guide") || queryLower.contains("help")),
                ("resource", queryLower.contains("file") || queryLower.contains("document")),
                ("opportunity", queryLower.contains("lead") || queryLower.contains("sale"))
            ]
            
            if let (type, _) = relevantActions.first(where: { $0.1 }) {
                results.append(
                    ResultItem(
                        icon: "plus.circle",
                        title: "Create new \(type) about '\(query)'",
                        shortcut: "⌘+N",
                        action: { onAction("create_\(type): \(query)") }
                    )
                )
            }
        }
        
        return results
    }
    
    private func calculateRelevance(query: String, item: KnowledgeItem, searchTerms: Set<String>) -> Float {
        let queryLower = query.lowercased()
        var score: Float = 0
        
        if item.title.lowercased().contains(queryLower) { score += 0.5 }
        if item.category.lowercased().contains(queryLower) { score += 0.3 }
        
        for tag in item.tags where tag.lowercased().contains(queryLower) {
            score += 0.2
        }
        
        for term in searchTerms {
            if item.title.lowercased().contains(term) { score += 0.1 }
            if item.tags.contains(where: { $0.lowercased().contains(term) }) { score += 0.05 }
        }
        
        return min(score, 1.0)
    }
}
