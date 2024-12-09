import SwiftUI

struct ChatAvatar: View {
    let user: User
    let size: CGFloat
    
    var body: some View {
        Avatar(user: user, size: size)
    }
} 