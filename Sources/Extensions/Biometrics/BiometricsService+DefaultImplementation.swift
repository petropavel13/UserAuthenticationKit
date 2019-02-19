//
//  Copyright (c) 2018 Touch Instinct
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the Software), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import LocalAuthentication

public extension BiometricsService {

    typealias BiometricsAuthHandler = (Bool, Error?) -> Void

    /// Returns true if user can authenticate via FaceID.
    var isFaceIdSupported: Bool {
        if #available(iOS 11.0, *) {
            return canAuthenticateWithBiometrics && context.biometryType == .faceID
        } else {
            return false
        }
    }

    /// Indicates is it possible to authenticate on this device via touch id.
    var canAuthenticateWithBiometrics: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    /// Initiates system biometrics authentication process.
    ///
    /// - Parameters:
    ///   - description: Prompt on the system alert.
    ///   - fallbackTitle: Alternative action button title on system alert.
    ///   - cancelTitle: Cancel button title on the system alert.
    ///   - authHandler: Callback, with parameter, indicates if user authenticate successfuly.
    func authenticateWithBiometrics(with parameters: BiometricsAuthenticationParameters,
                                    authHandler: @escaping BiometricsAuthHandler) {

        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = parameters.cancelTitle
        }
        context.localizedFallbackTitle = parameters.fallbackTitle

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: parameters.reason,
                               reply: authHandler)
    }

}
