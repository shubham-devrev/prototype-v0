// ChatBubbleStyle.swift
struct ChatBubbleStyle {
    let backgroundColor: Color
    let textColor: Color
    let cornerRadius: CGFloat
    
    static let user = ChatBubbleStyle(
        backgroundColor: .blue.opacity(0.15),
        textColor: .white,
        cornerRadius: 8
    )
    
    static let ai = ChatBubbleStyle(
        backgroundColor: .gray.opacity(0.15),
        textColor: .white,
        cornerRadius: 8
    )
    
    static let system = ChatBubbleStyle(
        backgroundColor: .clear,
        textColor: .secondary,
        cornerRadius: 8
    )
}