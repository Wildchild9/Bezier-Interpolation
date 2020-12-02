//
//  ContentView.swift
//  Bezier Interpolation
//
//  Created by Noah Wilder on 2020-12-01.
//

import SwiftUI

struct ContentView: View {
    var text: NSAttributedString {
        NSAttributedString(
            string: "Hello World!",
            attributes: [.font: NSFont.systemFont(ofSize: 30)]
        )
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Hello World!")
                .font(.system(size: 30))
                .fontWeight(.light)
                .foregroundColor(.primary)
                .background(Color.red)
            
            Spacer()
            
            TextShapeView(text: text)
                .foregroundColor(.primary)
                .background(Color.blue)
            
            Spacer()
        }
        .frame(width: 300, height: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
