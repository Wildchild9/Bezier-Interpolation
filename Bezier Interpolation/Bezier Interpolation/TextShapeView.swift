//
//  TextShapeView.swift
//  Bezier Interpolation
//
//  Created by Noah Wilder on 2020-12-02.
//

import SwiftUI

struct TextShapeView: View {
    
    var text: NSAttributedString
    
    var body: some View {
        TextShape(text: text)
            .frame(width: size.width, height: size.height)
    }

    var size: CGSize {
        return text.size()
    }
}

struct TextShapeView_Previews: PreviewProvider {
    static var previews: some View {
        TextShapeView(text: NSAttributedString(string: "Hello World", attributes: [.font: NSFont.systemFont(ofSize: 30)]))
    }
}
