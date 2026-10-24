//
//  MemoryView.swift
//  Oscar°
//
//  Created by Philipp Bolte on 05.05.24.
//

import SwiftUI

struct MemoryView: View {
    var body: some View {
        VStack {
            ImageCircleView()
                .padding(30)
            Spacer()
            VStack {
                Text("Oscar°")
                    .font(.system(size: 50))
                    .fontWeight(.medium)
                    .padding(.bottom, 1)
                Text("... wurde in liebevoller Erinnerung an diejenigen entwickelt, die nicht mehr unter uns sind. In unseren Herzen und Gedanken bleiben sie jedoch für immer lebendig.")
                    .font(.body)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 50)
            }
            .foregroundStyle(.white.opacity(0.9))
            .shadow(radius: 15)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MemoryView()
}

struct ImageCircleView: View {
    let imageNames = ["oscar", "reinhard", "urselwerner", "daniela"]

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            let radius = diameter / 3.4

            ForEach(0..<imageNames.count, id: \.self) { index in
                Image(imageNames[index])
                    .resizable()
                    .scaledToFill()
                    .grayscale(1.0)
                    .opacity(0.95)
                    .frame(width: diameter / 2.2, height: diameter / 2.2)
                    .clipShape(Circle())
                    .position(x: geometry.size.width / 2 + radius * cos(CGFloat(index) * 2 * .pi / CGFloat(imageNames.count)),
                              y: geometry.size.height / 2 + radius * sin(CGFloat(index) * 2 * .pi / CGFloat(imageNames.count)))
                    .shadow(color: .black.opacity(0.4), radius: 20)
            }
        }
    }
}
