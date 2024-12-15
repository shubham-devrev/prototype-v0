import SwiftUI

struct TodayView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Your Dashboard")
                .font(.largeTitle)
                .padding(.bottom)
            
            Text("Your personal workspace for managing conversations and exploring content")
                .foregroundStyle(.secondary)
            
            HStack(spacing: 40) {
                VStack {
                    Text("3")
                        .font(.title)
                    Text("Active Chats")
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("1")
                        .font(.title)
                    Text("AI Assistant")
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("5")
                        .font(.title)
                    Text("Unread Messages")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TodayView()
} 
