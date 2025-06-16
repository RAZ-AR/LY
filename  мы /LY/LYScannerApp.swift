//
//  LYScannerApp.swift
//  LY Scanner
//
//  Created by Armen on 16/06/2025.
//  Redesigned in LY Platform Style
//

import SwiftUI

// MARK: - App Entry Point
@main
struct LYScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Enhanced Models
struct ScanResult: Identifiable {
    let id = UUID()
    let isValid: Bool
    let cardType: CardType
    let memberName: String?
    let points: Int?
    let membershipLevel: MembershipLevel?
    let expiryDate: String?
    let errorMessage: String?
    let scanTimestamp: Date = Date()
    let companyName: String?
    
    enum CardType: String, CaseIterable {
        case premium = "Премиум клиенты"
        case basic = "Базовые клиенты"
        case vip = "VIP программа"
        case seasonal = "Сезонная карта"
        case unknown = "Неизвестная карта"
        
        var icon: String {
            switch self {
            case .premium: return "crown.fill"
            case .basic: return "creditcard.fill"
            case .vip: return "star.fill"
            case .seasonal: return "leaf.fill"
            case .unknown: return "questionmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .premium: return .purple
            case .basic: return .blue
            case .vip: return .orange
            case .seasonal: return .green
            case .unknown: return .gray
            }
        }
    }
    
    enum MembershipLevel: String, CaseIterable {
        case beginner = "Начинающий"
        case silver = "Серебряный"
        case gold = "Золотой"
        case platinum = "Платиновый"
        
        var icon: String {
            switch self {
            case .beginner: return "star"
            case .silver: return "star.fill"
            case .gold: return "crown"
            case .platinum: return "crown.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .beginner: return .gray
            case .silver: return .gray
            case .gold: return .yellow
            case .platinum: return .purple
            }
        }
    }
    
    static func randomResult() -> ScanResult {
        let successOutcomes = [
            ScanResult(
                isValid: true,
                cardType: .premium,
                memberName: "Иван Петров",
                points: 2450,
                membershipLevel: .gold,
                expiryDate: "31.12.2025",
                errorMessage: nil,
                companyName: "Кофейня 'Дом'"
            ),
            ScanResult(
                isValid: true,
                cardType: .basic,
                memberName: "Мария Сидорова",
                points: 820,
                membershipLevel: .silver,
                expiryDate: "15.08.2025",
                errorMessage: nil,
                companyName: "Ресторан 'Вкус'"
            ),
            ScanResult(
                isValid: true,
                cardType: .vip,
                memberName: "Александр Волков",
                points: 5670,
                membershipLevel: .platinum,
                expiryDate: "01.06.2026",
                errorMessage: nil,
                companyName: "Спортклуб 'Энергия'"
            ),
            ScanResult(
                isValid: true,
                cardType: .seasonal,
                memberName: "Елена Смирнова",
                points: 1230,
                membershipLevel: .gold,
                expiryDate: "30.09.2025",
                errorMessage: nil,
                companyName: "Салон красоты 'Стиль'"
            )
        ]
        
        let errorOutcomes = [
            ScanResult(
                isValid: false,
                cardType: .unknown,
                memberName: nil,
                points: nil,
                membershipLevel: nil,
                expiryDate: nil,
                errorMessage: "Карта не найдена в системе",
                companyName: nil
            ),
            ScanResult(
                isValid: false,
                cardType: .unknown,
                memberName: nil,
                points: nil,
                membershipLevel: nil,
                expiryDate: nil,
                errorMessage: "Срок действия карты истек",
                companyName: nil
            ),
            ScanResult(
                isValid: false,
                cardType: .unknown,
                memberName: nil,
                points: nil,
                membershipLevel: nil,
                expiryDate: nil,
                errorMessage: "QR-код поврежден или нечитаем",
                companyName: nil
            )
        ]
        
        // 70% успешных сканирований, 30% ошибок
        return Bool.random() && Bool.random() && Bool.random() ? 
            errorOutcomes.randomElement()! : 
            successOutcomes.randomElement()!
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var isScanning = false
    @State private var scanResult: ScanResult?
    @State private var showingDetail = false
    @State private var scanHistory: [ScanResult] = []
    @State private var showingHistory = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Scanner Tab
            NavigationView {
                mainScannerView
            }
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
                Text("Сканер")
            }
            .tag(0)
            
            // History Tab
            NavigationView {
                historyView
            }
            .tabItem {
                Image(systemName: "clock.arrow.circlepath")
                Text("История")
            }
            .tag(1)
            
            // Statistics Tab
            NavigationView {
                statisticsView
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Статистика")
            }
            .tag(2)
        }
        .accentColor(.blue)
    }
    
    // MARK: - Main Scanner View
    private var mainScannerView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Scanner Section
                scannerSection
                
                // Result Section
                if let result = scanResult {
                    resultSection(result)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .opacity
                        ))
                }
                
                // Quick Stats
                if !scanHistory.isEmpty {
                    quickStatsSection
                }
            }
            .padding()
        }
        .navigationTitle("LY Сканер")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let result = scanResult {
                ScanResultDetailView(result: result)
            }
        }
        .sheet(isPresented: $showingHistory) {
            ScanHistoryView(history: scanHistory)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Logo/Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(radius: 8)
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Сканер карт лояльности")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Наведите камеру на QR-код карты клиента")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var scannerSection: some View {
        VStack(spacing: 20) {
            // Scanner Viewfinder
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isScanning ? 
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 3
                    )
                    .frame(width: 250, height: 250)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray.opacity(0.05))
                    )
                    .scaleEffect(isScanning ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isScanning)
                
                VStack(spacing: 12) {
                    Image(systemName: isScanning ? "camera.viewfinder" : "qrcode")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(isScanning ? .blue : .gray)
                        .scaleEffect(isScanning ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isScanning)
                    
                    Text(isScanning ? "Сканирование..." : "Поместите QR-код сюда")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Scan Button
            Button(action: startScanning) {
                HStack(spacing: 12) {
                    Image(systemName: isScanning ? "stop.circle.fill" : "camera.fill")
                        .font(.title3)
                    
                    Text(isScanning ? "Остановить" : "Начать сканирование")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: isScanning ? [.orange, .red] : [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(radius: isScanning ? 8 : 4)
            }
            .disabled(false)
            .scaleEffect(isScanning ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isScanning)
        }
    }
    
    private func resultSection(_ result: ScanResult) -> some View {
        VStack(spacing: 20) {
            // Status Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(result.isValid ? .green.opacity(0.2) : .red.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(result.isValid ? .green : .red)
                }
                
                Text(result.isValid ? "Карта найдена!" : "Ошибка сканирования")
                    .font(.title3.bold())
                    .foregroundColor(result.isValid ? .green : .red)
            }
            
            // Result Card
            VStack(alignment: .leading, spacing: 16) {
                // Card Header
                HStack {
                    Image(systemName: result.cardType.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.cardType.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let company = result.companyName {
                            Text(company)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    if result.isValid {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
                
                if result.isValid {
                    Divider()
                        .background(.white.opacity(0.3))
                    
                    // Member Info
                    VStack(alignment: .leading, spacing: 12) {
                        if let memberName = result.memberName {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                Text(memberName)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        
                        if let points = result.points {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Баллы:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("\\(points)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let level = result.membershipLevel {
                            HStack {
                                Image(systemName: level.icon)
                                    .foregroundColor(level.color)
                                Text("Уровень:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(level.rawValue)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let expiryDate = result.expiryDate {
                            HStack {
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Действует до:")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(expiryDate)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                } else {
                    Divider()
                        .background(.white.opacity(0.3))
                    
                    if let errorMessage = result.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: result.isValid ? 
                                [result.cardType.color, result.cardType.color.opacity(0.7)] :
                                [.gray, .gray.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(radius: 8)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Подробнее") {
                    showingDetail = true
                }
                .font(.subheadline.bold())
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.opacity(0.1))
                .cornerRadius(12)
                
                if result.isValid {
                    Button("Добавить баллы") {
                        // Action for adding points
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрая статистика")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Всего сканирований",
                    value: "\\(scanHistory.count)",
                    icon: "qrcode",
                    color: .blue
                )
                
                StatCard(
                    title: "Успешных",
                    value: "\\(scanHistory.filter { $0.isValid }.count)",
                    icon: "checkmark.circle",
                    color: .green
                )
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    // MARK: - History View
    private var historyView: some View {
        List {
            if scanHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("История сканирований пуста")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Начните сканировать карты для отображения истории")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(scanHistory.reversed()) { result in
                    HistoryRowView(result: result)
                }
            }
        }
        .navigationTitle("История сканирований")
        .toolbar {
            if !scanHistory.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Очистить") {
                        scanHistory.removeAll()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Overview Stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        title: "Всего сканирований",
                        value: "\\(scanHistory.count)",
                        icon: "qrcode",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Успешных",
                        value: "\\(scanHistory.filter { $0.isValid }.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Ошибок",
                        value: "\\(scanHistory.filter { !$0.isValid }.count)",
                        icon: "xmark.circle.fill",
                        color: .red
                    )
                    
                    StatCard(
                        title: "Сегодня",
                        value: "\\(todayScans)",
                        icon: "calendar",
                        color: .orange
                    )
                }
                
                // Card Types Distribution
                if !scanHistory.isEmpty {
                    cardTypesSection
                }
            }
            .padding()
        }
        .navigationTitle("Статистика")
    }
    
    private var cardTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Типы карт")
                .font(.headline)
            
            let cardTypeCounts = Dictionary(grouping: scanHistory.filter { $0.isValid }) { $0.cardType }
                .mapValues { $0.count }
            
            ForEach(Array(cardTypeCounts.keys).sorted(by: { cardTypeCounts[$0]! > cardTypeCounts[$1]! }), id: \\.self) { cardType in
                HStack {
                    Image(systemName: cardType.icon)
                        .foregroundColor(cardType.color)
                        .frame(width: 20)
                    
                    Text(cardType.rawValue)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\\(cardTypeCounts[cardType] ?? 0)")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var todayScans: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return scanHistory.filter { 
            Calendar.current.startOfDay(for: $0.scanTimestamp) == today 
        }.count
    }
    
    // MARK: - Actions
    private func startScanning() {
        if isScanning {
            isScanning = false
            return
        }
        
        isScanning = true
        scanResult = nil
        
        // Simulate scanning with haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isScanning = false
            let result = ScanResult.randomResult()
            scanResult = result
            scanHistory.append(result)
            
            // Success/error haptic feedback
            if result.isValid {
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
            } else {
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct HistoryRowView: View {
    let result: ScanResult
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(result.isValid ? .green : .red)
                .font(.title3)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(result.cardType.rawValue)
                        .font(.subheadline.bold())
                    
                    Spacer()
                    
                    Text(result.scanTimestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let memberName = result.memberName {
                    Text(memberName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if let errorMessage = result.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // Points Badge
            if let points = result.points {
                Text("\\(points)")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail Views

struct ScanResultDetailView: View {
    let result: ScanResult
    @Environment(\\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    headerCard
                    
                    // Details Sections
                    if result.isValid {
                        memberDetailsSection
                        cardDetailsSection
                        actionsSection
                    } else {
                        errorDetailsSection
                    }
                }
                .padding()
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
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: result.cardType.icon)
                    .foregroundColor(.white)
                    .font(.title)
                
                VStack(alignment: .leading) {
                    Text(result.cardType.rawValue)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    if let company = result.companyName {
                        Text(company)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Image(systemName: result.isValid ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .foregroundColor(result.isValid ? .green : .red)
                    .font(.title)
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            HStack {
                Text("Статус:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text(result.isValid ? "Карта валидна" : "Ошибка валидации")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("Время сканирования:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text(result.scanTimestamp, style: .time)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: result.isValid ? 
                            [result.cardType.color, result.cardType.color.opacity(0.7)] :
                            [.gray, .gray.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(radius: 8)
    }
    
    private var memberDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация о клиенте")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let memberName = result.memberName {
                    DetailRow(
                        title: "Имя клиента",
                        value: memberName,
                        icon: "person.circle"
                    )
                }
                
                if let points = result.points {
                    DetailRow(
                        title: "Баллы",
                        value: "\\(points)",
                        icon: "star.circle",
                        valueColor: .orange
                    )
                }
                
                if let level = result.membershipLevel {
                    DetailRow(
                        title: "Уровень членства",
                        value: level.rawValue,
                        icon: level.icon,
                        valueColor: level.color
                    )
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var cardDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Детали карты")
                .font(.headline)
            
            VStack(spacing: 12) {
                DetailRow(
                    title: "Тип карты",
                    value: result.cardType.rawValue,
                    icon: result.cardType.icon,
                    valueColor: result.cardType.color
                )
                
                if let expiryDate = result.expiryDate {
                    DetailRow(
                        title: "Срок действия",
                        value: expiryDate,
                        icon: "calendar.circle"
                    )
                }
                
                DetailRow(
                    title: "ID сканирования",
                    value: String(result.id.uuidString.prefix(8)),
                    icon: "number.circle"
                )
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var errorDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Детали ошибки")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let errorMessage = result.errorMessage {
                    DetailRow(
                        title: "Описание ошибки",
                        value: errorMessage,
                        icon: "exclamationmark.triangle",
                        valueColor: .red
                    )
                }
                
                DetailRow(
                    title: "Время ошибки",
                    value: result.scanTimestamp.formatted(date: .abbreviated, time: .shortened),
                    icon: "clock.circle"
                )
            }
        }
        .padding()
        .background(.red.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                // Add points action
            } label: {
                Label("Добавить баллы", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
            }
            
            Button {
                // View history action
            } label: {
                Label("Просмотреть историю", systemImage: "clock.arrow.circlepath")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let valueColor: Color?
    
    init(title: String, value: String, icon: String, valueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(valueColor ?? .primary)
        }
        .padding(.vertical, 2)
    }
}

struct ScanHistoryView: View {
    let history: [ScanResult]
    @Environment(\\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(history.reversed()) { result in
                    HistoryRowView(result: result)
                }
            }
            .navigationTitle("История сканирований")
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

// MARK: - Preview
#Preview {
    ContentView()
}