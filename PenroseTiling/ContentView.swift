//
//  ContentView.swift
//  PenroseTiling
//
//  Created by Juan Carlos Aguilera Núñez on 16-01-21.
//

import SwiftUI

extension CGFloat {
    var degreesToRadians: CGFloat {
        self * CGFloat.pi / 180
    }
}

enum TriangleType {
    case acute, obtuse
    
    var baseAngle: CGFloat {
        switch self {
        case .acute:
            return CGFloat(36).degreesToRadians
        case .obtuse:
            return CGFloat(108).degreesToRadians
        }
    }
    
    var sideAngle: CGFloat {
        switch self {
        case .acute:
            return CGFloat(72).degreesToRadians
        case .obtuse:
            return CGFloat(36).degreesToRadians
        }
    }
}

struct PenroseTriangle {

    var type: TriangleType
    var startPoint, endPoint: CGPoint
    var mirrored: Bool
    
    init(type: TriangleType, startPoint: CGPoint, endPoint: CGPoint, mirrored: Bool = false) {
        self.type = type
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.mirrored = mirrored
    }
    
    init(type: TriangleType, startPoint: CGPoint, middlePoint: CGPoint, mirrored: Bool = false) {
        self.type = type
        self.startPoint = startPoint
        self.mirrored = mirrored
        
        let sideLength = sqrt(pow(middlePoint.x - startPoint.x, 2) + pow(middlePoint.y - startPoint.y, 2))
        
        let x_u = (startPoint.x - middlePoint.x) / sideLength
        let y_u = (startPoint.y - middlePoint.y) / sideLength
        
        
        let angle = self.type.baseAngle
        let direction = CGPoint(x: x_u * cos(angle) - y_u * sin(angle), y: x_u * sin(angle) + y_u * cos(angle))
        
        self.endPoint = CGPoint(x: middlePoint.x + sideLength * direction.x, y: middlePoint.y + sideLength * direction.y)
        
    }

    var middlePoint: CGPoint {
        let midPoint = CGPoint(x: 0.5 * (startPoint.x + endPoint.x), y: 0.5 * (startPoint.y + endPoint.y))
        let sideLength = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
        
        let angle = self.type.sideAngle
        
        let direction = CGPoint(x: (startPoint.y - endPoint.y) / sideLength, y: (endPoint.x - startPoint.x) / sideLength)
        let length: CGFloat = 0.5 * sideLength * tan(angle)
        
        return CGPoint(x: midPoint.x + length * direction.x, y: midPoint.y + length * direction.y)
        
    }
    
    func deflate() -> ([PenroseTriangle]) {
        let phi = CGFloat((1 + sqrt(5)) / 2)
        
        switch (self.type, self.mirrored) {
        case (.acute, false):
            let goldenPoint = CGPoint(x: phi / (1 + phi) * self.startPoint.x + 1 / (1 + phi) * self.middlePoint.x, y: phi / (1 + phi) * self.startPoint.y + 1 / (1 + phi) * self.middlePoint.y)
            return [
                PenroseTriangle(type: .acute, startPoint: goldenPoint, middlePoint: self.endPoint, mirrored: self.mirrored),
                PenroseTriangle(type: .obtuse, startPoint: self.endPoint, endPoint: self.middlePoint, mirrored: self.mirrored)
            ]
        case (.acute, true):
            let goldenPoint = CGPoint(x: phi / (1 + phi) * self.endPoint.x + 1 / (1 + phi) * self.middlePoint.x, y: phi / (1 + phi) * self.endPoint.y + 1 / (1 + phi) * self.middlePoint.y)
            return [
                PenroseTriangle(type: .acute, startPoint: self.endPoint, endPoint: goldenPoint, mirrored: self.mirrored),
                PenroseTriangle(type: .obtuse, startPoint: self.middlePoint, endPoint: self.startPoint, mirrored: self.mirrored)
            ]
        case (.obtuse, false):
            let goldenPointBase = CGPoint(x: 1 / (1 + phi) * self.startPoint.x + phi / (1 + phi) * self.endPoint.x, y: 1 / (1 + phi) * self.startPoint.y + phi / (1 + phi) * self.endPoint.y)
            let goldenPointSide = CGPoint(x: phi / (1 + phi) * self.middlePoint.x + 1 / (1 + phi) * self.startPoint.x, y: phi / (1 + phi) * self.middlePoint.y + 1 / (1 + phi) * self.startPoint.y)
            return [
                PenroseTriangle(
                    type: .acute, startPoint: self.middlePoint, endPoint: goldenPointSide, mirrored: !self.mirrored),
                PenroseTriangle(
                    type: .obtuse, startPoint: self.startPoint, endPoint: goldenPointBase, mirrored: !self.mirrored),
                PenroseTriangle(
                    type: .obtuse, startPoint: self.endPoint, endPoint: self.middlePoint, mirrored: self.mirrored)
            ]
        case (.obtuse, true):
            let goldenPointBase = CGPoint(x: phi / (1 + phi) * self.startPoint.x + 1 / (1 + phi) * self.endPoint.x, y: phi / (1 + phi) * self.startPoint.y + 1 / (1 + phi) * self.endPoint.y)
            let goldenPointSide = CGPoint(x: phi / (1 + phi) * self.middlePoint.x + 1 / (1 + phi) * self.endPoint.x, y: phi / (1 + phi) * self.middlePoint.y + 1 / (1 + phi) * self.endPoint.y)
            return [
                PenroseTriangle(
                    type: .acute, startPoint: goldenPointSide, endPoint:  self.middlePoint, mirrored: !self.mirrored),
                PenroseTriangle(
                    type: .obtuse, startPoint: goldenPointBase, endPoint: self.endPoint, mirrored: !self.mirrored),
                PenroseTriangle(
                    type: .obtuse, startPoint: self.middlePoint, endPoint: self.startPoint, mirrored: self.mirrored)
            ]
        }
    }
    
    func draw(on path: inout Path) {
        path.move(to: self.startPoint)
        path.addLine(to: self.middlePoint)
        path.addLine(to: self.endPoint)
    }
}

func deflate(_ triangles: [PenroseTriangle], levels: Int = 0) -> [PenroseTriangle] {
    if levels <= 0 {
        return triangles
    }
    let newTriangles = triangles
        .map { $0.deflate() }
        .reduce([PenroseTriangle](), { $0 + $1 })
    return deflate(newTriangles, levels: levels - 1)
}

func deflate(_ triangle: PenroseTriangle, levels: Int = 0) -> [PenroseTriangle] {
    return deflate([triangle], levels: levels)
}

struct Triangle: Shape {
    
    var triangleType: TriangleType = .acute
    @Binding var iterations: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var triangleList = [
            PenroseTriangle(type: .acute, startPoint: CGPoint(x: rect.midX, y: rect.minY), middlePoint: CGPoint(x: rect.midX, y: rect.midY))
        ]
        for i in 1..<10 {
            triangleList.append(PenroseTriangle(type: .acute, startPoint: triangleList[i-1].endPoint, middlePoint: CGPoint(x: rect.midX, y: rect.midY), mirrored: i % 2 == 1))
        }

        var triangles = deflate(triangleList, levels: iterations)
        
        triangles = triangles.filter { $0.type == self.triangleType}
        for triangle in triangles {
            triangle.draw(on: &path)
        }
        
        return path
    }
}

struct ContentView: View {
    @State var iterations = 1
    var body: some View {
        VStack {
            ZStack {
                Triangle(iterations: $iterations).fill(Color.yellow).frame(width: 300, height: 300, alignment: .center)
                Triangle(triangleType: .obtuse, iterations: $iterations).fill(Color.green).frame(width: 300, height: 300, alignment: .center)
                Triangle(iterations: $iterations).stroke(Color.black).frame(width: 300, height: 300, alignment: .center)
                Triangle(triangleType: .obtuse, iterations: $iterations).stroke(Color.black).frame(width: 300, height: 300, alignment: .center)

            }
            Stepper("Iterations: \(iterations)", value: $iterations, in: 1...7)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
