import Foundation

struct FileAttachment: Identifiable, Codable {
    let id: String
    let name: String
    let size: Int64
    let mimeType: String
    let url: URL
    var thumbnail: URL?
    
    var type: AttachmentType {
        switch mimeType.split(separator: "/").first ?? "" {
        case "image": return .image
        case "video": return .video
        case "application" where mimeType.contains("pdf"): return .pdf
        default: return .other
        }
    }
    
    enum AttachmentType {
        case image
        case video
        case pdf
        case other
        
        var icon: String {
            switch self {
            case .image: return "photo"
            case .video: return "play.rectangle"
            case .pdf: return "doc.text"
            case .other: return "doc"
            }
        }
    }
    
    init(url: URL) {
        self.id = UUID().uuidString
        self.url = url
        self.name = url.lastPathComponent
        
        let resources = try? url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
        self.size = Int64(resources?.fileSize ?? 0)
        self.mimeType = resources?.contentType?.identifier ?? "unknown"
        self.thumbnail = nil
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         size: Int64,
         mimeType: String,
         url: URL,
         thumbnail: URL? = nil) {
        self.id = id
        self.name = name
        self.size = size
        self.mimeType = mimeType
        self.url = url
        self.thumbnail = thumbnail
    }
} 