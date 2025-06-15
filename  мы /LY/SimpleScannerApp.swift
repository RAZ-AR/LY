//
//  SimpleScannerApp.swift
//  LoyaltyScanner
//
//  Created by Armen on 15/06/2025.
//

import SwiftUI

// MARK: - App Entry Point
@main
struct LoyaltyScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Models
struct ScanResult {
    let id = UUID()
    let isValid: Bool
    let cardTitle: String
    let memberName: String?
    let points: Int?
    let membershipLevel: String?
    let expiryDate: String?
    let errorMessage: String?
    
    static func randomResult() -> ScanResult {
        let outcomes = [
            ScanResult(
                isValid: true,
                cardTitle: "Премиум клиенты",
                memberName: "Иван Петров",
                points: 2450,
                membershipLevel: "Золотой",
                expiryDate: "31.12.2025",
                errorMessage: nil
            ),
            ScanResult(
                isValid: true,
                cardTitle: "Базовые клиенты",
                memberName: "Мария Сидорова",
                points: 820,
                membershipLevel: "Серебряный",
                expiryDate: "15.08.2025",
                errorMessage: nil
            ),
            ScanResult(
                isValid: false,
                cardTitle: "Неизвестная карта",
                memberName: nil,
                points: nil,
                membershipLevel: nil,
                expiryDate: nil,
                errorMessage: "Карта не найдена в системе"
            )
        ]
        return outcomes.randomElement()!
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var isScanning = false
    @State private var scanResult: ScanResult?
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Сканер карт лояльности")
                        .font(.title)
                        .bold()
                    
                    Text("Наведите камеру на QR-код или штрих-код")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // Scan Button
                Button(action: startScanning) {
                    HStack {
                        Image(systemName: isScanning ? "stop.circle" : "camera")
                        Text(isScanning ? "Сканирование..." : "Начать сканирование")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isScanning ? Color.orange : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(isScanning)
                .padding(.horizontal)
                
                // Result Section
                if let result = scanResult {
                    resultView(result)
                        .transition(.slide)
                }
                
                Spacer()
            }
            .navigationTitle("Сканер")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDetail) {
                if let result = scanResult {
                    ScanResultDetailView(result: result)
                }
            }
        }
    }
    
    private func startScanning() {
        isScanning = true
        scanResult = nil
        
        // Симуляция сканирования
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isScanning = false
            scanResult = ScanResult.randomResult()
        }
    }
    
    private func resultView(_ result: ScanResult) -> some View {
        VStack(spacing: 16) {
            // Status Icon
            Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(result.isValid ? .green : .red)
            
            // Result Card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(result.cardTitle)
                        .font(.headline)
                    Spacer()
                    if result.isValid {
                        Text("✅ Валидна")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Ошибка")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if let memberName = result.memberName {
                    Text("Клиент: \(memberName)")
                        .font(.subheadline)
                }
                
                if let points = result.points {
                    Text("Баллы: \(points)")
                        .font(.subheadline)
                }
                
                if let errorMessage = result.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Detail Button
            Button("Подробнее") {
                showingDetail = true
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .animation(.easeInOut, value: scanResult?.id)
    }
}

// MARK: - Detail View
struct ScanResultDetailView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Статус сканирования") {
                    HStack {
                        Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(result.isValid ? .green : .red)
                        Text(result.isValid ? "Карта валидна" : "Ошибка валидации")
                            .font(.headline)
                    }
                }
                
                Section("Информация о карте") {
                    DetailRow(title: "Тип карты", value: result.cardTitle)
                    
                    if let memberName = result.memberName {
                        DetailRow(title: "Владелец", value: memberName)
                    }
                    
                    if let membershipLevel = result.membershipLevel {
                        DetailRow(title: "Уровень", value: membershipLevel)
                    }
                    
                    if let points = result.points {
                        DetailRow(title: "Баллы", value: "\(points)")
                    }
                    
                    if let expiryDate = result.expiryDate {
                        DetailRow(title: "Срок действия", value: expiryDate)
                    }
                    
                    if let errorMessage = result.errorMessage {
                        DetailRow(title: "Ошибка", value: errorMessage, isError: true)
                    }
                }
                
                Section("Действия") {
                    if result.isValid {
                        Button("Добавить баллы") {
                            // Действие добавления баллов
                        }
                        
                        Button("Просмотреть историю") {
                            // Действие просмотра истории
                        }
                    } else {
                        Button("Сканировать повторно") {
                            dismiss()
                        }
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

struct DetailRow: View {
    let title: String
    let value: String
    let isError: Bool
    
    init(title: String, value: String, isError: Bool = false) {
        self.title = title
        self.value = value
        self.isError = isError
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(isError ? .red : .primary)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}