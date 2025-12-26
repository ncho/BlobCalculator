//
//  ContentView.swift
//  BlobCalculator
//
//  Created by Nathan Cho on 12/26/25.
//  With ChatGPT Free and Claude Free
// 

import SwiftUI

struct ContentView: View {
    @State private var equationString = "0"
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: - Blob Visualization
            BlobView(equationString: equationString)
                .frame(height: 220)
            
            Spacer()
            
            // MARK: - Input Display
            Text(equationString)
                .font(.system(size: 48, weight: .medium, design: .monospaced))
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            
            // MARK: - Custom Keypad
            KeypadView { key in
                handleKeyPress(key)
            }
            .padding()
        }
        .padding()
    }
    
    // MARK: - Input Handling
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "C":
            equationString = "0"
            
        case "+":
            equationString += "+"
            
        case "0":
            // Only add 0 if string is not just "0"
            if equationString != "0" {
                equationString += key
            }
            
        default:
            // It's a number - replace initial 0
            if equationString == "0" {
                equationString = key
            } else {
                equationString += key
            }
        }
    }
}

// MARK: - Blob View

struct BlobView: View {
    let equationString: String
    
    // Parse the equation to get first and second numbers
    private var numbers: (first: Int, second: Int) {
        let components = equationString.components(separatedBy: "+")
        let first = Int(components.first ?? "") ?? 0
        let second = components.count > 1 ? (Int(components[1]) ?? 0) : 0
        return (first, second)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                blobGroup(
                    count: numbers.first,
                    color: .blue,
                    centerX: geo.size.width * 0.35
                )
                
                if numbers.second > 0 {
                    blobGroup(
                        count: numbers.second,
                        color: .orange,
                        centerX: geo.size.width * 0.65
                    )
                }
            }
        }
    }
    
    private func blobGroup(count: Int, color: Color, centerX: CGFloat) -> some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width * 0.3  // Each group gets 30% of width
            let availableHeight = geo.size.height * 0.8
            
            // Calculate blob size based on count
            // More blobs = smaller size, fewer blobs = larger size
            let blobSize: CGFloat = {
                if count == 0 { return 0 }
                if count == 1 { return min(availableWidth, availableHeight) * 0.8 }
                
                // Calculate optimal size to fit all blobs
                let area = availableWidth * availableHeight
                let areaPerBlob = area / CGFloat(count)
                let baseSize = sqrt(areaPerBlob) * 0.9  // 0.9 for spacing
                
                return max(8, min(baseSize, 60))  // Min 8px, max 60px
            }()
            
            // Calculate grid dimensions
            let cols = max(1, Int(availableWidth / (blobSize + 4)))
            
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: blobSize, height: blobSize)
                    .position(
                        x: centerX + CGFloat((i % cols)) * (blobSize + 4) - (CGFloat(cols - 1) * (blobSize + 4) / 2),
                        y: CGFloat(i / cols) * (blobSize + 4) + blobSize / 2 + 20
                    )
            }
        }
    }
}

// MARK: - Keypad View

struct KeypadView: View {
    let onKeyPress: (String) -> Void
    
    let keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["C", "0", "+"]
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            onKeyPress(key)
                        } label: {
                            Text(key)
                                .font(.title)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color(.systemGray6))
                                .cornerRadius(14)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
