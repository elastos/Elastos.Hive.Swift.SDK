import Foundation


/// Configuration for the ElastosHiveSDK.
/// All app information should match the information in your app portal with Microsoft Accounts or Azure Active Directory.
/// @see https://dev.onedrive.com/README.htm for more information.
public class OAuthEntry {

    /// ClientId for OneDrive registered with Microsoft Account.
    /// @see https://dev.onedrive.com/auth/msa_oauth.htm for registration information.
    let clientId: String

    /// Scopes to be used for OneDrive registered with Microsoft Account.
    /// @see https://dev.onedrive.com/auth/msa_oauth.htm for registration information.
    let scope   : String

    /// Redirect URL for OneDrive.
    /// @see https://dev.onedrive.com/auth/aad_oauth.htm for registration information.
    /// @warning This value must be the same as the RedirectURL provided in the Azure Active Directory portal.
    let redirectURL: String

    /// Create OAuthEntry instance
    ///
    /// - Parameters:
    ///   - clientId: The clientId
    ///   - scope: The scope
    ///   - redirectURL: The redirectURL
    public init(_ clientId: String,  _ scope: String, _ redirectURL: String) {
        self.clientId = clientId
        self.scope = scope
        self.redirectURL = redirectURL
    }
}
