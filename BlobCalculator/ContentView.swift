//
//  ContentView.swift
//  BlobCalculator
//
//  Created by Nathan Cho on 12/26/25.
//  With ChatGPT Free and Claude Free and Gemini
//

import SwiftUI

struct ContentView: View {
    @State private var equationString = "0"
    
    let numberColors: [Color] = [.red, .orange, .blue, .green, .purple, .pink, .teal]
    
    private var sum: Int {
        let components = equationString.components(separatedBy: "+")
        return components.compactMap { Int($0) }.reduce(0, +)
    }

    // Formats numbers with commas (e.g., 1000 -> 1,000)
    private func formatWithCommas(_ string: String) -> String {
        let components = string.components(separatedBy: "+")
        let formattedComponents = components.map { component in
            // Only format if it's a valid number
            if let number = Int(component) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: number)) ?? component
            }
            return component
        }
        return formattedComponents.joined(separator: "+")
    }

    private func coloredEquationText() -> Text {
        var result = Text("")
        let formattedString = formatWithCommas(equationString)
        let components = formattedString.components(separatedBy: "+")
        
        for (index, number) in components.enumerated() {
            let color = numberColors[index % numberColors.count]
            result = result + Text(number).foregroundColor(color)
            if index < components.count - 1 {
                result = result + Text("+").foregroundColor(.black)
            }
        }
        return result
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Artistic Area
                ZStack {
                    GeometryReader { geo in
                        let totalCount = equationString.components(separatedBy: "+").compactMap { Int($0) }.reduce(0, +)
                        let size = calculateBlobSize(totalCount: totalCount, containerSize: geo.size)
                        
                        WrappingBlobGrid(equation: equationString, colors: numberColors, blobSize: size)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    // MARK: - Sum Overlay
                    if equationString.contains("+") {
                        Text(formatWithCommas("\(sum)"))
                            .font(.system(size: 140, weight: .medium, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .foregroundColor(.black.opacity(0.15))
                            .allowsHitTesting(false)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)

                // MARK: - Horizontal Input String
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        coloredEquationText()
                            .font(.system(size: 44, weight: .medium, design: .monospaced))
                            .id("end")
                            .padding(.horizontal)
                            .onChange(of: equationString) { _ in
                                withAnimation { proxy.scrollTo("end", anchor: .trailing) }
                            }
                    }
                }
                .frame(height: 60)
                .padding(.vertical, 10)
                
                // MARK: - Keypad
                KeypadView { key in
                    handleKeyPress(key)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private func handleKeyPress(_ key: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Get the current number segment we are typing
            let components = equationString.components(separatedBy: "+")
            let currentSegment = components.last ?? ""
            
            switch key {
            case "C":
                equationString = "0"
            case "+":
                // Don't allow + if we just typed a +
                if !equationString.hasSuffix("+") {
                    equationString += "+"
                }
            case "0":
                // BLOCK: If current number is empty (after a +) or is the starting "0",
                // don't allow another 0 to be the first digit.
                if currentSegment == "" || equationString == "0" {
                    return
                }
                equationString += key
            default:
                // For keys 1-9
                if equationString == "0" {
                    // Replace the initial starting 0
                    equationString = key
                } else {
                    equationString += key
                }
            }
        }
    }
    
    private func calculateBlobSize(totalCount: Int, containerSize: CGSize) -> CGFloat {
        if totalCount <= 0 { return 20 }
        let area = containerSize.width * containerSize.height
        let idealSize = sqrt(area / CGFloat(totalCount))
        return max(2, min(24, idealSize * 0.7))
    }
}

// MARK: - Updated Blob Grid (No LazyVGrid to prevent scrolling issues)
struct WrappingBlobGrid: View {
    let equation: String
    let colors: [Color]
    let blobSize: CGFloat
    
    var body: some View {
        let components = equation.components(separatedBy: "+")
        let allColors = components.enumerated().flatMap { (index, value) -> [Color] in
            let count = Int(value) ?? 0
            return Array(repeating: colors[index % colors.count], count: count)
        }
        
        // Canvas is much faster for drawing many small shapes
        Canvas { context, size in
            let spacing: CGFloat = 1
            let step = blobSize + spacing
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            for color in allColors {
                // Create a rectangle for the dot
                let rect = CGRect(x: x, y: y, width: blobSize, height: blobSize)
                
                // Draw the circle
                context.fill(Path(ellipseIn: rect), with: .color(color))
                
                // Move to the next position
                x += step
                
                // Wrap to next line if we hit the edge
                if x + blobSize > size.width {
                    x = 0
                    y += step
                }
                
                // Stop drawing if we run out of vertical space
                if y + blobSize > size.height { break }
            }
        }
        .padding(.horizontal, 10)
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
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color(.systemGray5))
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
