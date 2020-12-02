//
//  TextShape.swift
//  Bezier Interpolation
//
//  Created by Noah Wilder on 2020-12-02.
//

import SwiftUI

struct TextShape: Shape {
    var text: NSAttributedString
    
    func path(in rect: CGRect) -> Path {
        var path = textPath(for: text)
        let size = text.size()
        let targetCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        let boundingRect = path.boundingRect
        
        var sourceCenter = boundingRect.origin
        sourceCenter.x += boundingRect.size.width / 2
        sourceCenter.y += boundingRect.size.height / 2
        
        path = path.offsetBy(dx: targetCenter.x - sourceCenter.x, dy: targetCenter.y - sourceCenter.y)
        path = path.offsetBy(dx: rect.origin.x, dy: rect.origin.y)
        
        return path
    }
    
    func textPath(for attributedString: NSAttributedString) -> Path {
        let line = CTLineCreateWithAttributedString(attributedString)
        
        guard let glyphRuns = CTLineGetGlyphRuns(line) as? [CTRun] else { return Path() }
        
        //    var characterPaths = [Path]()
        var path = Path()
        
        for glyphRun in glyphRuns {
            guard let attributes = CTRunGetAttributes(glyphRun) as? [String:AnyObject] else { continue }
            let font = attributes[kCTFontAttributeName as String] as! CTFont
            
            for index in 0..<CTRunGetGlyphCount(glyphRun) {
                let glyphRange = CFRangeMake(index, 1)
                
                var glyph = CGGlyph()
                CTRunGetGlyphs(glyphRun, glyphRange, &glyph)
                
                var characterPosition = CGPoint()
                CTRunGetPositions(glyphRun, glyphRange, &characterPosition)
                //            characterPosition.x += position.x
                //            characterPosition.y += position.y
                
                if let glyphPath = CTFontCreatePathForGlyph(font, glyph, nil) {
                    var transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: characterPosition.x, ty: characterPosition.y)
                    if let charPath = glyphPath.copy(using: &transform) {
                        //                    characterPaths.append(Path(charPath))
                        path.addPath(Path(charPath))
                    }
                }
            }
        }
        return path
    }
}
