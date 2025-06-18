//
//  LVScannerApp.swift
//  LV Scanner
//
//  Created by Armen on 17/06/2025.
//  Redesigned in LY Platform Visual Style
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import Combine

// MARK: - QR Code Generation (from LY Platform)
class QRCodeGenerator {
    static let shared = QRCodeGenerator()
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    private init() {}
    
    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

// MARK: - LY Platform Color Scheme
extension Color {
    static let lyPrimary = Color.blue
    static let lySecondary = Color.purple  
    static let lyAccent = Color.green
    static let lyWarning = Color.orange
    static let lyError = Color.red
    static let lySuccess = Color.green
    
    // LY Gradients
    static let lyGradient1 = [Color.blue, Color.purple]
    static let lyGradient2 = [Color.green, Color.blue]
    static let lyGradient3 = [Color.orange, Color.red]
    static let lyGradient4 = [Color.purple, Color.pink]
    static let lyGradient5 = [Color.indigo, Color.blue]
}

// MARK: - LY Platform Components
struct LYGradientCard<Content: View>: View {
    let gradient: [Color]
    let content: Content
    
    init(gradient: [Color] = Color.lyGradient1, @ViewBuilder content: () -> Content) {
        self.gradient = gradient
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: gradient.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
    }
}

struct LYQuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var animateIcon = false
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            animateIcon = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateIcon = false
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.2 : 1.0)
                    .rotationEffect(.degrees(animateIcon ? 360 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateIcon)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: gradient.first?.opacity(0.3) ?? .clear, radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - App Entry Point
@main
struct LVScannerApp: App {
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
        case boardingPass = "Посадочный талон"
        case eventTicket = "Билет на мероприятие"
        case loyaltyCard = "Карта лояльности"
        case coupon = "Купон"
        case giftCard = "Подарочная карта"
        case membership = "Членская карта"
        case unknown = "Неизвестная карта"
        
        var icon: String {
            switch self {
            case .boardingPass: return "airplane"
            case .eventTicket: return "ticket.fill"
            case .loyaltyCard: return "creditcard.fill"
            case .coupon: return "percent"
            case .giftCard: return "gift.fill"
            case .membership: return "person.card.fill"
            case .unknown: return "questionmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .boardingPass: return .blue
            case .eventTicket: return .purple
            case .loyaltyCard: return .green
            case .coupon: return .orange
            case .giftCard: return .pink
            case .membership: return .indigo
            case .unknown: return .gray
            }
        }
        
        var appleWalletStyle: AppleWalletCardStyle {
            switch self {
            case .boardingPass:
                return AppleWalletCardStyle(
                    primaryColor: .blue,
                    secondaryColor: .blue.opacity(0.8),
                    textColor: .white,
                    hasBarcode: true,
                    layout: .boardingPass
                )
            case .eventTicket:
                return AppleWalletCardStyle(
                    primaryColor: .purple,
                    secondaryColor: .purple.opacity(0.8),
                    textColor: .white,
                    hasBarcode: true,
                    layout: .eventTicket
                )
            case .loyaltyCard:
                return AppleWalletCardStyle(
                    primaryColor: .green,
                    secondaryColor: .green.opacity(0.8),
                    textColor: .white,
                    hasBarcode: false,
                    layout: .storeCard
                )
            case .coupon:
                return AppleWalletCardStyle(
                    primaryColor: .orange,
                    secondaryColor: .orange.opacity(0.8),
                    textColor: .white,
                    hasBarcode: true,
                    layout: .coupon
                )
            case .giftCard:
                return AppleWalletCardStyle(
                    primaryColor: .pink,
                    secondaryColor: .pink.opacity(0.8),
                    textColor: .white,
                    hasBarcode: false,
                    layout: .storeCard
                )
            case .membership:
                return AppleWalletCardStyle(
                    primaryColor: .indigo,
                    secondaryColor: .indigo.opacity(0.8),
                    textColor: .white,
                    hasBarcode: false,
                    layout: .storeCard
                )
            case .unknown:
                return AppleWalletCardStyle(
                    primaryColor: .gray,
                    secondaryColor: .gray.opacity(0.8),
                    textColor: .white,
                    hasBarcode: false,
                    layout: .storeCard
                )
            }
        }
    }
    
    struct AppleWalletCardStyle {
        let primaryColor: Color
        let secondaryColor: Color
        let textColor: Color
        let hasBarcode: Bool
        let layout: AppleWalletLayout
    }
    
    enum AppleWalletLayout {
        case boardingPass
        case eventTicket
        case storeCard
        case coupon
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
                cardType: .boardingPass,
                memberName: "Иван Петров",
                points: nil,
                membershipLevel: nil,
                expiryDate: "25.12.2024",
                errorMessage: nil,
                companyName: "Аэрофлот • SU 1234 • Москва → Сочи"
            ),
            ScanResult(
                isValid: true,
                cardType: .eventTicket,
                memberName: "Мария Сидорова",
                points: nil,
                membershipLevel: nil,
                expiryDate: "15.01.2025",
                errorMessage: nil,
                companyName: "Концерт • Ряд 12, Место 15"
            ),
            ScanResult(
                isValid: true,
                cardType: .loyaltyCard,
                memberName: "Александр Волков",
                points: 5670,
                membershipLevel: .platinum,
                expiryDate: "01.06.2026",
                errorMessage: nil,
                companyName: "Спортклуб 'Энергия'"
            ),
            ScanResult(
                isValid: true,
                cardType: .coupon,
                memberName: "Елена Смирнова",
                points: nil,
                membershipLevel: nil,
                expiryDate: "30.09.2025",
                errorMessage: nil,
                companyName: "Скидка 25% • Салон красоты 'Стиль'"
            ),
            ScanResult(
                isValid: true,
                cardType: .giftCard,
                memberName: "Анна Козлова",
                points: nil,
                membershipLevel: nil,
                expiryDate: "31.12.2025",
                errorMessage: nil,
                companyName: "Подарочная карта 5000₽"
            ),
            ScanResult(
                isValid: true,
                cardType: .membership,
                memberName: "Дмитрий Новиков",
                points: 1850,
                membershipLevel: .gold,
                expiryDate: "15.03.2026",
                errorMessage: nil,
                companyName: "Фитнес-клуб 'Олимп'"
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
        .preferredColorScheme(.light)
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
        .navigationTitle("LV Сканер")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
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
        LYGradientCard(gradient: Color.lyGradient1) {
            VStack(spacing: 20) {
                // LV Logo Design
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 2)
                        )
                    
                    // LV Text Logo instead of system icon
                    VStack(spacing: 2) {
                        Text("LV")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("SCAN")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(2)
                    }
                    .scaleEffect(isScanning ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isScanning)
                }
                
                VStack(spacing: 12) {
                    Text("LV Сканер Карт")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Профессиональное сканирование карт лояльности с аналитикой")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    // Quick stats
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(scanHistory.count)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Сканирований")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 1, height: 30)
                        
                        VStack(spacing: 4) {
                            Text("\(scanHistory.filter { $0.isValid }.count)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Успешных")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var scannerSection: some View {
        VStack(spacing: 24) {
            // Enhanced Scanner Viewfinder with LY styling
            ZStack {
                // Background gradient card
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: isScanning ? Color.lyGradient2 : [.gray.opacity(0.1), .gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 280, height: 280)
                    .shadow(color: isScanning ? .green.opacity(0.3) : .gray.opacity(0.2), radius: isScanning ? 12 : 6)
                
                // Animated border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: isScanning ? Color.lyGradient2 : [.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isScanning ? 4 : 2
                    )
                    .frame(width: 280, height: 280)
                    .scaleEffect(isScanning ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isScanning)
                
                // Inner content
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(isScanning ? 0.2 : 0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: isScanning ? "camera.viewfinder" : "qrcode")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(isScanning ? .white : .gray)
                            .scaleEffect(isScanning ? 1.1 : 1.0)
                            .rotationEffect(.degrees(isScanning ? 360 : 0))
                            .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isScanning)
                    }
                    
                    VStack(spacing: 8) {
                        Text(isScanning ? "Сканирование..." : "Поместите QR-код")
                            .font(.headline)
                            .foregroundColor(isScanning ? .white : .primary)
                        
                        Text(isScanning ? "Поиск карт лояльности" : "Нажмите кнопку для начала")
                            .font(.caption)
                            .foregroundColor(isScanning ? .white.opacity(0.8) : .secondary)
                    }
                }
            }
            
            // Enhanced Scan Button with LY styling
            LYQuickActionCard(
                title: isScanning ? "Остановить" : "Начать сканирование",
                subtitle: isScanning ? "Завершить процесс" : "Сканировать QR-код",
                icon: isScanning ? "stop.circle.fill" : "camera.fill",
                gradient: isScanning ? Color.lyGradient3 : Color.lyGradient1,
                action: startScanning
            )
            
            // Quick actions row
            if !isScanning {
                HStack(spacing: 12) {
                    Button(action: {
                        // Show scanner tips
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                            Text("Советы")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.orange.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        // Show scanner settings
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                            Text("Настройки")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    private func resultSection(_ result: ScanResult) -> some View {
        VStack(spacing: 20) {
            // Enhanced Status Header with LY styling
            LYGradientCard(gradient: result.isValid ? Color.lyGradient2 : Color.lyGradient3) {
                VStack(spacing: 16) {
                    // Status icon with enhanced animation
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        Image(systemName: result.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 45))
                            .foregroundColor(.white)
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: result.id)
                    }
                    
                    VStack(spacing: 8) {
                        Text(result.isValid ? "Карта найдена!" : "Ошибка сканирования")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(result.isValid ? "Данные успешно считаны" : "Повторите попытку")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(20)
            }
            
            // Apple Wallet Style Card
            AppleWalletCardView(result: result)
            
            // Enhanced Action Buttons with LY styling
            HStack(spacing: 16) {
                // Details button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    showingDetail = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                        Text("Подробнее")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.blue.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                
                if result.isValid {
                    // Add points button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        // Action for adding points
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("+ Баллы")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: Color.lyGradient2,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Быстрая статистика")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                LYStatCard(
                    title: "Всего сканирований",
                    value: "\\(scanHistory.count)",
                    icon: "qrcode.viewfinder",
                    gradient: Color.lyGradient1
                )
                
                LYStatCard(
                    title: "Успешных",
                    value: "\\(scanHistory.filter { $0.isValid }.count)",
                    icon: "checkmark.circle.fill",
                    gradient: Color.lyGradient2
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray.opacity(0.1), lineWidth: 1)
                )
        )
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
                    LYStatCard(
                        title: "Всего сканирований",
                        value: "\\(scanHistory.count)",
                        icon: "qrcode.viewfinder",
                        gradient: Color.lyGradient1
                    )
                    
                    LYStatCard(
                        title: "Успешных",
                        value: "\\(scanHistory.filter { $0.isValid }.count)",
                        icon: "checkmark.circle.fill",
                        gradient: Color.lyGradient2
                    )
                    
                    LYStatCard(
                        title: "Ошибок",
                        value: "\\(scanHistory.filter { !$0.isValid }.count)",
                        icon: "xmark.circle.fill",
                        gradient: Color.lyGradient3
                    )
                    
                    LYStatCard(
                        title: "Сегодня",
                        value: "\\(todayScans)",
                        icon: "calendar.circle.fill",
                        gradient: Color.lyGradient4
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
        VStack(alignment: .leading, spacing: 20) {
            Text("Распределение типов карт")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            let cardTypeCounts = Dictionary(grouping: scanHistory.filter { $0.isValid }) { $0.cardType }
                .mapValues { $0.count }
            
            VStack(spacing: 12) {
                ForEach(Array(cardTypeCounts.keys).sorted(by: { cardTypeCounts[$0]! > cardTypeCounts[$1]! }), id: \\.self) { cardType in
                    LYGradientCard(gradient: [cardType.color, cardType.color.opacity(0.8)]) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: cardType.icon)
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(cardType.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Сканирований")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Text("\\(cardTypeCounts[cardType] ?? 0)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        .padding(16)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.gray.opacity(0.1), lineWidth: 1)
                )
        )
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

// MARK: - Apple Wallet Card View

struct AppleWalletCardView: View {
    let result: ScanResult
    
    var body: some View {
        let style = result.cardType.appleWalletStyle
        
        ZStack {
            // Card Background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [style.primaryColor, style.secondaryColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: cardHeight)
                .shadow(color: style.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Card Content based on layout
            switch style.layout {
            case .boardingPass:
                boardingPassLayout(style: style)
            case .eventTicket:
                eventTicketLayout(style: style)
            case .storeCard:
                storeCardLayout(style: style)
            case .coupon:
                couponLayout(style: style)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
    }
    
    private var cardHeight: CGFloat {
        return result.cardType.appleWalletStyle.layout == .boardingPass ? 200 : 180
    }
    
    @ViewBuilder
    private func boardingPassLayout(style: AppleWalletCardStyle) -> some View {
        HStack(spacing: 0) {
            // Left section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: result.cardType.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    Text(result.cardType.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(1)
                }
                
                if let memberName = result.memberName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ПАССАЖИР")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        Text(memberName.uppercased())
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(0.5)
                    }
                }
                
                if let company = result.companyName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("РЕЙС")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        Text(company)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Perforated edge
            VStack(spacing: 8) {
                ForEach(0..<8, id: \.self) { _ in
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 8)
            
            // Right section (stub)
            VStack(spacing: 8) {
                Image(systemName: "qrcode")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
                
                if let expiryDate = result.expiryDate {
                    Text(expiryDate)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(width: 80)
            .padding(.vertical, 16)
        }
    }
    
    @ViewBuilder
    private func eventTicketLayout(style: AppleWalletCardStyle) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: result.cardType.icon)
                    .foregroundColor(.white)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.cardType.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(1)
                    
                    if let company = result.companyName {
                        Text(company)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                if style.hasBarcode {
                    Image(systemName: "barcode")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Content
            HStack {
                if let memberName = result.memberName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ВЛАДЕЛЕЦ")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        Text(memberName)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                if let expiryDate = result.expiryDate {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("ДАТА")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        Text(expiryDate)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func storeCardLayout(style: AppleWalletCardStyle) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: result.cardType.icon)
                    .foregroundColor(.white)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.cardType.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(1)
                    
                    if let company = result.companyName {
                        Text(company)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            
            // Member info
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    if let memberName = result.memberName {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("УЧАСТНИК")
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1)
                            Text(memberName)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        if let points = result.points {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("БАЛЛЫ")
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1)
                                Text("\(points)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let level = result.membershipLevel {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("УРОВЕНЬ")
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1)
                                Text(level.rawValue.uppercased())
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func couponLayout(style: AppleWalletCardStyle) -> some View {
        HStack(spacing: 0) {
            // Main content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: result.cardType.icon)
                        .foregroundColor(.white)
                        .font(.title2)
                    
                    Text(result.cardType.rawValue.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .tracking(1)
                    
                    Spacer()
                }
                
                if let company = result.companyName {
                    Text(company)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                
                if let memberName = result.memberName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ВЛАДЕЛЕЦ")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        Text(memberName)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Barcode section
            if style.hasBarcode {
                VStack(spacing: 8) {
                    Image(systemName: "barcode")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.8))
                        .rotationEffect(.degrees(90))
                    
                    if let expiryDate = result.expiryDate {
                        Text(expiryDate)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .rotationEffect(.degrees(90))
                    }
                }
                .frame(width: 60)
                .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Supporting Views

struct LYStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    @State private var animateValue = false
    
    var body: some View {
        LYGradientCard(gradient: gradient) {
            VStack(spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(value)
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .scaleEffect(animateValue ? 1.1 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateValue)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .onAppear {
            animateValue = true
        }
    }
}

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