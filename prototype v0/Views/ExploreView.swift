import SwiftUI

struct ExploreView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Explore")
                .font(.largeTitle)
                .padding(.bottom)
            
            Text("Discover new conversations and content")
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ExploreCard(
                    title: "AI Chat",
                    description: "Start a conversation with our AI assistant",
                    icon: "sparkle"
                )
                
                ExploreCard(
                    title: "Group Chat",
                    description: "Create or join group conversations",
                    icon: "person.3"
                )
                
                ExploreCard(
                    title: "Direct Messages",
                    description: "Start a private conversation",
                    icon: "bubble.left.and.bubble.right"
                )
                
                ExploreCard(
                    title: "Settings",
                    description: "Customize your experience",
                    icon: "gear"
                )
            }
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExploreCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    ExploreView()
} 