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
    
    // Vibrant palette
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
                // MARK: - Artistic Blob & Sum Area
                ZStack {
                    // Layer 1: The Blobs (Background)
                    GeometryReader { geo in
                        VStack(alignment: .leading, spacing: 6) {
                            Spacer(minLength: 0)
                            let components = equationString.components(separatedBy: "+")
                            ForEach(0..<components.count, id: \.self) { index in
                                if let count = Int(components[index]), count > 0 {
                                    BlobRow(count: count, color: numberColors[index % numberColors.count])
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    }
                    
                    // Layer 2: Large Condensed Sum (Foreground)
                    if equationString.contains("+") {
                        Text("\(sum)")
                            // Using SF Pro Condensed / Compressed style
                            .font(.system(size: 160, weight: .black, design: .rounded))
                            .minimumScaleFactor(0.2)
                            .kerning(-5) // Tighten characters for that condensed look
                            .foregroundColor(.black.opacity(0.15)) // Subtle overlay effect
                            .allowsHitTesting(false)
                    }
                }
                .padding(.top)

                // MARK: - Equation Display
                coloredEquationText()
                    .font(.system(size: 40, weight: .medium, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // MARK: - Custom Keypad
                KeypadView { key in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        handleKeyPress(key)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "C":
            equationString = "0"
        case "+":
            if !equationString.hasSuffix("+") && equationString != "0" {
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

// MARK: - Blob Row Component

struct BlobRow: View {
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            // We use the count itself as the ID for the ForEach to help SwiftUI
            // animate the change in number of blobs
            ForEach(0..<min(count, 500), id: \.self) { _ in
                Circle()
                    .fill(color)
                    .frame(minWidth: 1, maxWidth: 12)
                    .aspectRatio(1, contentMode: .fit)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity).combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Keeps blobs left-aligned
        .padding(.horizontal, 20)
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
