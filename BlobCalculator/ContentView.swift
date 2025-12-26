//
//  ContentView.swift
//  BlobCalculator
//
//  Created by Nathan Cho on 12/26/25.
//  With ChatGPT Free
//

import SwiftUI

struct ContentView: View {
    @State private var firstNumber = 0
    @State private var secondNumber = 0
    @State private var inputBuffer = ""
    @State private var enteringFirst = true
    
    var sum: Int {
        firstNumber + secondNumber
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            BlobView(
                first: firstNumber,
                second: secondNumber
            )
            .frame(height: 200)
            
            VStack(spacing: 8) {
                Text("\(firstNumber) + \(secondNumber)")
                    .font(.title2)
                
                Text("= \(sum)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Text(inputBuffer.isEmpty ? "0" : inputBuffer)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
                
                KeypadView { key in
                    handleKeyPress(key)
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .padding()
    }
    
    private func handleKeyPress(_ key: String) {
        switch key {
        case "C":
            firstNumber = 0
            secondNumber = 0
            inputBuffer = ""
            enteringFirst = true
            
        case "+":
            commitBuffer()
            enteringFirst = false
            
        case "=":
            commitBuffer()
            
        default:
            inputBuffer.append(key)
        }
    }
    
    private func commitBuffer() {
        let value = Int(inputBuffer) ?? 0
        if enteringFirst {
            firstNumber = value
        } else {
            secondNumber = value
        }
        inputBuffer = ""
    }
}

// MARK: - Blob View

struct BlobView: View {
    let first: Int
    let second: Int
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                blobGroup(
                    count: first,
                    color: .blue,
                    centerX: geo.size.width * 0.35
                )
                
                blobGroup(
                    count: second,
                    color: .orange,
                    centerX: geo.size.width * 0.65
                )
            }
        }
    }
    
    private func blobGroup(count: Int, color: Color, centerX: CGFloat) -> some View {
        ForEach(0..<min(count, 20), id: \.self) { _ in
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)
                .position(
                    x: centerX + CGFloat.random(in: -40...40),
                    y: CGFloat.random(in: 40...160)
                )
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
        ["C", "0", "+"],
        ["="]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            onKeyPress(key)
                        } label: {
                            Text(key)
                                .font(.title)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.white)
                                .cornerRadius(10)
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
