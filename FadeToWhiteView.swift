//
//  FadeToWhiteView.swift
//  edenic.ai
//
//  Created by Neil Young on 8/7/24.
//

import Foundation
import SwiftUI

struct FadeToWhiteView: View {
    @Binding var isFading: Bool  // Allow external control of the fading state

    var body: some View {
        Color.white
            .opacity(isFading ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 1.0), value: isFading)
            .edgesIgnoringSafeArea(.all)
    }
}

struct FadeToWhiteView_Previews: PreviewProvider {
    static var previews: some View {
        FadeToWhiteView(isFading: .constant(true))
    }
}
