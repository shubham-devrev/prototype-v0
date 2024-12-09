import SwiftUI

struct InboxView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Inbox")
                .font(.largeTitle)
                .padding(.bottom)
            
            Text("Your messages and notifications")
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                NotificationRow(
                    title: "New Message from User 1",
                    description: "Hey, check out this new feature!",
                    time: "2m ago"
                )
                
                NotificationRow(
                    title: "AI Assistant Update",
                    description: "Your assistant has learned new capabilities",
                    time: "1h ago"
                )
                
                NotificationRow(
                    title: "System Update",
                    description: "New features are available",
                    time: "2h ago"
                )
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotificationRow: View {
    let title: String
    let description: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
    }
}

#Preview {
    InboxView()
} 