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

    private func coloredEquationText() -> Text {
        var result = Text("")
        let components = equationString.components(separatedBy: "+")
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
                // MARK: - Artistic Blob Area (Non-Scrolling)
                ZStack {
                    GeometryReader { geo in
                        let totalCount = equationString.components(separatedBy: "+").compactMap { Int($0) }.reduce(0, +)
                        let size = calculateBlobSize(totalCount: totalCount, containerSize: geo.size)
                        
                        // Using a standard View here instead of ScrollView
                        WrappingBlobGrid(equation: equationString, colors: numberColors, blobSize: size)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    // MARK: - Sum Overlay
                    if equationString.contains("+") {
                        Text("\(sum)")
                            // Font changed to match input (Monospaced), but larger
                            .font(.system(size: 140, weight: .medium, design: .monospaced))
                            .minimumScaleFactor(0.1)
                            .foregroundColor(.black.opacity(0.5))
                            .allowsHitTesting(false)
                    }
                }
                .padding(.top)

                // MARK: - Horizontal Input String (1 Line Only)
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
    
    private func calculateBlobSize(totalCount: Int, containerSize: CGSize) -> CGFloat {
        if totalCount <= 0 { return 20 }
        
        let area = containerSize.width * containerSize.height
        // We calculate size so that (count * size^2) is slightly less than total area
        // to account for spacing and padding.
        let idealSize = sqrt(area / CGFloat(totalCount))
        
        // Clamp the size: Max 24px, Min 2px
        return max(2, min(24, idealSize * 0.7))
    }
    
    private func handleKeyPress(_ key: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            switch key {
            case "C":
                equationString = "0"
            case "+":
                if !equationString.hasSuffix("+") {
                    equationString += "+"
                }
            case "0":
                if equationString != "0" {
                    equationString += key
                }
            default:
                if equationString == "0" {
                    equationString = key
                } else {
                    equationString += key
                }
            }
        }
    }
}

// MARK: - Updated Blob Grid (No LazyVGrid to prevent scrolling issues)
struct WrappingBlobGrid: View {
    let equation: String
    let colors: [Color]
    let blobSize: CGFloat
    
    var body: some View {
        let components = equation.components(separatedBy: "+")
        let allBlobs = components.enumerated().flatMap { (index, value) -> [Color] in
            let count = Int(value) ?? 0
            return Array(repeating: colors[index % colors.count], count: count)
        }
        
        // LazyVGrid inside a non-scrolling container will just fit what it can.
        // The calculateBlobSize logic ensures they all fit.
        LazyVGrid(columns: [GridItem(.adaptive(minimum: blobSize), spacing: 1)], spacing: 1) {
            ForEach(0..<allBlobs.count, id: \.self) { i in
                Circle()
                    .fill(allBlobs[i])
                    .frame(width: blobSize, height: blobSize)
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
