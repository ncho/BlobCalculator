//
//  ContentView.swift
//  BlobCalculator
//
//  Created by Nathan Cho on 12/26/25.
//  With ChatGPT Free
//

import SwiftUI

struct ContentView: View {
    @State private var firstText = ""
    @State private var secondText = ""
    
    private var firstNumber: Int {
        Int(firstText) ?? 0
    }
    
    private var secondNumber: Int {
        Int(secondText) ?? 0
    }
    
    private var sum: Int {
        firstNumber + secondNumber
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Blob Visualization
            BlobView(
                first: firstNumber,
                second: secondNumber
            )
            .frame(height: 220)
            
            // MARK: - Equation Display
            VStack(spacing: 8) {
                Text("\(firstNumber) + \(secondNumber)")
                    .font(.title2)
                
                Text("= \(sum)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // MARK: - Numeric Input Area
            VStack(spacing: 16) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("First number")
                        .font(.headline)
                    
                    TextField("0", text: $firstText)
                        .keyboardType(.numberPad)
                        .font(.largeTitle)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Number to add")
                        .font(.headline)
                    
                    TextField("0", text: $secondText)
                        .keyboardType(.numberPad)
                        .font(.largeTitle)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
        ForEach(0..<min(count, 20), id: \.self) { index in
            Circle()
                .fill(color)
                .frame(width: 22, height: 22)
                .position(
                    x: centerX + CGFloat((index % 5) * 24 - 48),
                    y: CGFloat(60 + (index / 5) * 24)
                )
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
