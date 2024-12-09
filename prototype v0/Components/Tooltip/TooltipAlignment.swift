import SwiftUI

public enum TooltipAlignment {
    case start
    case center
    case end
    
    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .start:
            return .leading
        case .center:
            return .center
        case .end:
            return .trailing
        }
    }
    
    var verticalAlignment: VerticalAlignment {
        switch self {
        case .start:
            return .top
        case .center:
            return .center
        case .end:
            return .bottom
        }
    }
} 