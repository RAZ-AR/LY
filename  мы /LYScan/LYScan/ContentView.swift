//
//  ContentView.swift
//  LYScan
//
//  Created by Armen on 15/06/2025.
//

import SwiftUI

struct ScanResult {
    let isValid: Bool
    let customerName: String?
    let cardType: String?
    let discount: Int?
    let message: String
}

struct ContentView: View {
    @State private var isScanning = false
    @State private var scanResult: ScanResult?
    @State private var showingDetail = false
    
    let possibleResults: [ScanResult] = [
        ScanResult(isValid: true, customerName: "Анна Петрова", cardType: "Премиум", discount: 20, message: "Карта действительна! Скидка 20%"),
        ScanResult(isValid: true, customerName: "Михаил Козлов", cardType: "Базовая", discount: 10, message: "Карта действительна! Скидка 10%"),
        ScanResult(isValid: false, customerName: nil, cardType: nil, discount: nil, message: "Карта недействительна или заблокирована")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // Логотип и заголовок
                VStack(spacing: 16) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("LoyaltyScanner")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    
                    Text("Сканер карт лояльности")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Область сканирования
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isScanning ? .blue : .gray.opacity(0.3), lineWidth: 2)
                        )
                    
                    if isScanning {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Сканирование...")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top)
                        }
                    } else if let result = scanResult {
                        VStack(spacing: 12) {
                            Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(result.isValid ? .green : .red)
                            
                            Text(result.message)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                            
                            if result.isValid {
                                Button("Подробнее") {
                                    showingDetail = true
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    } else {
                        VStack {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("Наведите камеру на QR-код")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопки управления
                VStack(spacing: 16) {
                    Button(action: startScanning) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Начать сканирование")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isScanning)
                    
                    if scanResult != nil {
                        Button("Новое сканирование") {
                            resetScan()
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Сканер")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDetail) {
                if let result = scanResult {
                    ScanDetailView(result: result)
                }
            }
        }
    }
    
    private func startScanning() {
        isScanning = true
        scanResult = nil
        
        // Симуляция сканирования (2 секунды)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isScanning = false
            scanResult = possibleResults.randomElement()
        }
    }
    
    private func resetScan() {
        scanResult = nil
        isScanning = false
    }
}

struct ScanDetailView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Информация о клиенте") {
                    if let customerName = result.customerName {
                        HStack {
                            Text("Имя:")
                            Spacer()
                            Text(customerName)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let cardType = result.cardType {
                        HStack {
                            Text("Тип карты:")
                            Spacer()
                            Text(cardType)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let discount = result.discount {
                        HStack {
                            Text("Скидка:")
                            Spacer()
                            Text("\(discount)%")
                                .foregroundColor(.green)
                                .bold()
                        }
                    }
                }
                
                Section("Статус") {
                    HStack {
                        Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(result.isValid ? .green : .red)
                        Text(result.message)
                        Spacer()
                    }
                }
                
                if result.isValid {
                    Section("Действия") {
                        Button("Применить скидку") {
                            // Действие применения скидки
                        }
                        .foregroundColor(.blue)
                        
                        Button("История покупок") {
                            // Просмотр истории
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Детали сканирования")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
