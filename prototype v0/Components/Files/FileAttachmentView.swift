import SwiftUI

struct FileAttachmentView: View {
    let attachment: FileAttachment
    let style: AttachmentStyle
    let onRemove: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: attachment.type.icon)
                .font(.system(size: style.iconSize))
                .foregroundColor(.gray)
            
            // File Info
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.name)
                    .font(.system(size: style.fileNameSize, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Text(formatFileSize(attachment.size))
                    .font(.system(size: style.fileSizeSize))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Remove Button (if provided)
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .help(attachment.name) // Show full filename in tooltip
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - Style Configuration
extension FileAttachmentView {
    struct AttachmentStyle {
        let iconSize: CGFloat
        let fileNameSize: CGFloat
        let fileSizeSize: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        
        static let compact = AttachmentStyle(
            iconSize: 14,
            fileNameSize: 12,
            fileSizeSize: 10,
            horizontalPadding: 8,
            verticalPadding: 8
        )
        
        static let expanded = AttachmentStyle(
            iconSize: 16,
            fileNameSize: 14,
            fileSizeSize: 12,
            horizontalPadding: 12,
            verticalPadding: 10
        )
    }
} 
