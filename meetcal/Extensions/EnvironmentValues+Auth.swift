import SwiftUI

private struct IsUserAuthenticatedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isUserAuthenticated: Bool {
        get { self[IsUserAuthenticatedKey.self] }
        set { self[IsUserAuthenticatedKey.self] = newValue }
    }
}
