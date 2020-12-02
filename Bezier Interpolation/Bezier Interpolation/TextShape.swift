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
        
        var newPath = Path()
        let functions = bezierFunctions(from: path)
        for f in functions {
            newPath.move(to: f(0))
            let step: CGFloat = 0.02
            for t in stride(from: step, through: 1, by: step) {
                newPath.addLine(to: f(t))
            }
        }
        
        return newPath
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

func bezierFunctions(from path: Path) -> [(CGFloat) -> CGPoint] {
    var p0 = CGPoint() // Subpath start point
    var p1 = CGPoint() // Previous point
    
    var functions = [(CGFloat) -> CGPoint]()
    
    path.forEach { component in
        switch component {
        case let .move(to: p2):
            p0 = p2
            p1 = p2
            
        case let .line(to: p2):
            // w₁(1 - t) + w₂t
            functions.append({ t in
                let x = p1.x * (1 - t) + p2.x * t
                let y = p1.y * (1 - t) + p2.y * t
                return CGPoint(x: x, y: y)
            })
            p1 = p2
            
        case let .quadCurve(to: p2, control: c):
            // w₁(1 - t)² + 2w₂(1 - t)t + w₃t²
            functions.append({ t in
                let x = p1.x * pow(1 - t, 2) + c.x * 1 * (1 - t) * t + p2.x * pow(t, 2)
                let y = p1.y * pow(1 - t, 2) + c.y * 1 * (1 - t) * t + p2.y * pow(t, 2)
                return CGPoint(x: x, y: y)
            })
            p1 = p2
            
        case let .curve(to: p2, control1: c1, control2: c2):
            // w₁(1 - t)³ + 3w₂(1 - t)²t + 3w₃(1 - t)t² + w₄t³
            functions.append({ t in
                let x = p1.x * pow(1 - t, 3) + c1.x * 3 * pow(1 - t, 2) * t + c2.x * 3 * (1 - t) * pow(t, 2) + p2.x * pow(t, 3)
                let y = p1.y * pow(1 - t, 3) + c1.y * 3 * pow(1 - t, 2) * t + c2.y * 3 * (1 - t) * pow(t, 2) + p2.y * pow(t, 3)
                return CGPoint(x: x, y: y)
            })
            p1 = p2
            
        case .closeSubpath:
            functions.append({ t in
                let x = p1.x * (1 - t) + p0.x * t
                let y = p1.y * (1 - t) + p0.y * t
                return CGPoint(x: x, y: y)
            })
        }
    }
    return functions
}
