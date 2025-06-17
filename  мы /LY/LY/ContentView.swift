//
//  ContentView.swift
//  LY
//
//  Created by Armen on 15/06/2025.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import Combine
import PassKit

// MARK: - QR Code Generation Utilities
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
    
    func generateHighQualityQRCode(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let scaleX = size.width / outputImage.extent.width
            let scaleY = size.height / outputImage.extent.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

// MARK: - Company Management Models
struct Company: Identifiable {
    let id = UUID()
    let name: String
    let logo: String?
    let adminEmail: String
    var loyaltyPrograms: [LoyaltyProgram] = []
    let createdAt: Date = Date()
}

struct LoyaltyProgram: Identifiable {
    let id = UUID()
    let companyId: UUID
    let name: String
    let template: CardTemplate
    let inviteLink: String
    var users: [User] = []
    let createdAt: Date = Date()
}

struct User: Identifiable {
    let id = UUID()
    var name: String
    let birthday: Date?
    let phone: String?
    let email: String?
    var points: Int = 0
    let registeredAt: Date = Date()
    var walletPassUrl: String?
}

// MARK: - Dynamic Field System
struct DynamicField: Identifiable {
    let id = UUID()
    let type: FieldType
    let label: String
    let position: CGPoint
    let style: TextStyle
    let isRequired: Bool
}

enum FieldType: String, CaseIterable {
    case userName = "Имя пользователя"
    case points = "Баллы"
    case membershipLevel = "Уровень"
    case expiryDate = "Срок действия"
    case memberID = "ID участника"
    case qrCode = "QR-код"
    
    var icon: String {
        switch self {
        case .userName: return "person"
        case .points: return "star.circle"
        case .membershipLevel: return "crown"
        case .expiryDate: return "calendar"
        case .memberID: return "number"
        case .qrCode: return "qrcode"
        }
    }
}

struct TextStyle {
    let font: Font
    let color: Color
    let alignment: TextAlignment
}

enum LogoPosition: String, CaseIterable {
    case topLeft = "Верх слева"
    case topRight = "Верх справа"
    case center = "По центру"
    case bottomLeft = "Низ слева"
    case bottomRight = "Низ справа"
}

// MARK: - Original Card Template (Enhanced)
enum CardTemplate: String, CaseIterable {
    case loyalty = "Карта лояльности"
    case ticket = "Билет"
    case coupon = "Купон"
    case membership = "Членская карта"
    case giftCard = "Подарочная карта"
    
    var icon: String {
        switch self {
        case .loyalty: return "creditcard"
        case .ticket: return "ticket"
        case .coupon: return "tag"
        case .membership: return "person.card"
        case .giftCard: return "gift"
        }
    }
    
    var defaultGradient: [Color] {
        switch self {
        case .loyalty: return [.blue, .purple]
        case .ticket: return [.orange, .red]
        case .coupon: return [.green, .teal]
        case .membership: return [.purple, .pink]
        case .giftCard: return [.red, .orange]
        }
    }
}

enum CardBlock: String, CaseIterable {
    case logo = "Логотип"
    case title = "Заголовок"
    case subtitle = "Подзаголовок"
    case barcode = "Штрих-код"
    case qrcode = "QR-код"
    case points = "Баллы"
    case balance = "Баланс"
    case expiry = "Срок действия"
    case memberID = "ID участника"
    
    var icon: String {
        switch self {
        case .logo: return "building.2"
        case .title: return "textformat"
        case .subtitle: return "text.alignleft"
        case .barcode: return "barcode"
        case .qrcode: return "qrcode"
        case .points: return "star.circle"
        case .balance: return "dollarsign.circle"
        case .expiry: return "calendar"
        case .memberID: return "number"
        }
    }
}

struct CardDesign {
    var template: CardTemplate
    var primaryColor: Color
    var secondaryColor: Color
    var backgroundColor: Color
    var textColor: Color
    var blocks: [CardBlock]
    var logoImage: String?
    var backgroundPattern: String?
    
    // 🆕 Enhanced fields for full loyalty system
    var dynamicFields: [DynamicField] = []
    var logoPosition: LogoPosition = .topLeft
    var qrCodeEnabled: Bool = true
    var gradientStyle: GradientStyle = .linear
    var cornerRadius: CGFloat = 16
    var shadowEnabled: Bool = true
}

enum GradientStyle: String, CaseIterable {
    case linear = "Линейный"
    case radial = "Радиальный" 
    case angular = "Угловой"
    
    var icon: String {
        switch self {
        case .linear: return "rectangle.split.3x1"
        case .radial: return "circle.grid.2x2"
        case .angular: return "rays"
        }
    }
}

// MARK: - Link Generation & Wallet Integration
struct InviteLink {
    let id = UUID()
    let programId: UUID
    let shortCode: String
    let fullUrl: String
    let isActive: Bool
    let expiresAt: Date?
    let usageCount: Int
    let maxUsage: Int?
    
    static func generateLink(for program: LoyaltyProgram) -> InviteLink {
        let shortCode = String(UUID().uuidString.prefix(8)).uppercased()
        let fullUrl = "https://loyalty.app/join/\(shortCode)"
        
        return InviteLink(
            programId: program.id,
            shortCode: shortCode,
            fullUrl: fullUrl,
            isActive: true,
            expiresAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            usageCount: 0,
            maxUsage: nil
        )
    }
}

struct WalletPass {
    let id = UUID()
    let userId: UUID
    let programId: UUID
    let passTypeId: String
    let serialNumber: String
    let passUrl: String
    let qrCodeData: String
    let issuedAt: Date = Date()
    
    static func generatePass(for user: User, program: LoyaltyProgram) -> WalletPass {
        let serialNumber = "\(program.id.uuidString.prefix(8))-\(user.id.uuidString.prefix(8))"
        let passUrl = "https://loyalty.app/wallet/\(serialNumber).pkpass"
        let qrCodeData = "loyalty://user/\(user.id.uuidString)?program=\(program.id.uuidString)"
        
        return WalletPass(
            userId: user.id,
            programId: program.id,
            passTypeId: "pass.com.loyalty.card",
            serialNumber: serialNumber,
            passUrl: passUrl,
            qrCodeData: qrCodeData
        )
    }
}

// MARK: - Registration Form Data
struct RegistrationData {
    var name: String = ""
    var birthday: Date?
    var phone: String = ""
    var email: String = ""
    var acceptsMarketing: Bool = false
    
    var isValid: Bool {
        !name.isEmpty && (!phone.isEmpty || !email.isEmpty)
    }
}

// MARK: - Pass Template Models (Walletsio Style)
struct PassTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let passType: PassType
    let presetFields: [PassFieldTemplate]
}

struct PassFieldTemplate {
    let key: String
    let label: String
    let placeholder: String
}

struct PassCreationData {
    var organizationName: String = ""
    var passDescription: String = ""
    var logoImage: String = ""
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var labelColor: Color = .white
    var customFields: [PassField] = []
    var barcodeMessage: String = ""
}

// MARK: - Apple Wallet Pass Models
struct WalletPassData: Identifiable {
    let id = UUID()
    let passTypeIdentifier: String
    let teamIdentifier: String
    let organizationName: String
    let description: String
    let logoText: String?
    let foregroundColor: String
    let backgroundColor: String
    let labelColor: String?
    let serialNumber: String
    let webServiceURL: String?
    let authenticationToken: String?
    
    var headerFields: [PassField] = []
    var primaryFields: [PassField] = []
    var secondaryFields: [PassField] = []
    var auxiliaryFields: [PassField] = []
    var backFields: [PassField] = []
    
    let passType: PassType
    let barcodeMessage: String
    let barcodeFormat: String
    let barcodeMessageEncoding: String
    
    var relevantDate: Date?
    var maxDistance: Double?
    var locations: [PassLocation]?
    
    init(passType: PassType, organizationName: String, description: String, serialNumber: String) {
        self.passType = passType
        self.passTypeIdentifier = "pass.com.loyaltyplatform.\(passType.rawValue.lowercased())"
        self.teamIdentifier = "YOUR_TEAM_ID"
        self.organizationName = organizationName
        self.description = description
        self.serialNumber = serialNumber
        self.logoText = organizationName
        self.foregroundColor = "rgb(255, 255, 255)"
        self.backgroundColor = "rgb(25, 118, 210)"
        self.labelColor = "rgb(255, 255, 255)"
        self.webServiceURL = "https://api.loyaltyplatform.com/"
        self.authenticationToken = UUID().uuidString
        self.barcodeMessage = serialNumber
        self.barcodeFormat = "PKBarcodeFormatQR"
        self.barcodeMessageEncoding = "iso-8859-1"
    }
}

struct PassField: Identifiable {
    let id = UUID()
    let key: String
    let label: String?
    let value: String
    let textAlignment: String?
    let changeMessage: String?
    
    init(key: String, label: String? = nil, value: String, textAlignment: String? = nil, changeMessage: String? = nil) {
        self.key = key
        self.label = label
        self.value = value
        self.textAlignment = textAlignment
        self.changeMessage = changeMessage
    }
}

struct PassLocation {
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let relevantText: String?
}

enum PassType: String, CaseIterable {
    case boardingPass = "Boarding Pass"
    case coupon = "Coupon"
    case eventTicket = "Event Ticket"
    case generic = "Generic"
    case storeCard = "Store Card"
    
    var icon: String {
        switch self {
        case .boardingPass: return "airplane"
        case .coupon: return "tag.fill"
        case .eventTicket: return "ticket.fill"
        case .generic: return "rectangle.fill"
        case .storeCard: return "creditcard.fill"
        }
    }
    
    var description: String {
        switch self {
        case .boardingPass: return "Посадочный талон"
        case .coupon: return "Купон"
        case .eventTicket: return "Билет на мероприятие"
        case .generic: return "Общий пасс"
        case .storeCard: return "Карта лояльности"
        }
    }
}

// MARK: - PassKit Manager
class PassKitManager: NSObject, ObservableObject {
    @Published var passes: [WalletPassData] = []
    @Published var isCreatingPass = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        loadDemoPasses()
    }
    
    func createPass(from passData: WalletPassData) -> PKPass? {
        // В реальном приложении здесь была бы генерация .pkpass файла
        // Для демо возвращаем nil и показываем сообщение
        print("Создание пасса: \(passData.description)")
        print("Serial: \(passData.serialNumber)")
        print("Type: \(passData.passType.rawValue)")
        
        DispatchQueue.main.async {
            self.errorMessage = "Демо-режим: пасс создан успешно!"
        }
        
        return nil
    }
    
    func addPassToWallet(_ passData: WalletPassData) {
        guard let pass = createPass(from: passData) else {
            print("Не удалось создать пасс")
            return
        }
        
        let passLibrary = PKPassLibrary()
        let addPassViewController = PKAddPassesViewController(pass: pass)
        
        // В реальном приложении здесь был бы показ PKAddPassesViewController
        print("Добавление пасса в Wallet")
    }
    
    func savePass(_ passData: WalletPassData) {
        if let index = passes.firstIndex(where: { $0.id == passData.id }) {
            passes[index] = passData
        } else {
            passes.append(passData)
        }
    }
    
    func deletePass(_ passData: WalletPassData) {
        passes.removeAll { $0.id == passData.id }
    }
    
    private func loadDemoPasses() {
        let demoPass1 = WalletPassData(
            passType: .storeCard,
            organizationName: "Кофейня 'Дом'",
            description: "Карта лояльности",
            serialNumber: "LC001234567"
        )
        
        let demoPass2 = WalletPassData(
            passType: .coupon,
            organizationName: "Ресторан 'Вкус'",
            description: "Скидочный купон",
            serialNumber: "CP001234567"
        )
        
        passes = [demoPass1, demoPass2]
    }
}

// MARK: - Points System
struct PointTransaction: Identifiable {
    let id = UUID()
    let userId: UUID
    let programId: UUID
    let type: TransactionType
    let amount: Int
    let description: String
    let timestamp: Date = Date()
    let adminId: String?
    
    enum TransactionType: String, CaseIterable {
        case earned = "Начисление"
        case redeemed = "Списание"
        case bonus = "Бонус"
        case refund = "Возврат"
        case adjustment = "Корректировка"
        
        var icon: String {
            switch self {
            case .earned: return "plus.circle.fill"
            case .redeemed: return "minus.circle.fill"
            case .bonus: return "gift.fill"
            case .refund: return "arrow.clockwise.circle.fill"
            case .adjustment: return "pencil.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .earned, .bonus, .refund: return .green
            case .redeemed: return .red
            case .adjustment: return .orange
            }
        }
    }
}

struct PointsRule {
    let id = UUID()
    let programId: UUID
    let name: String
    let description: String
    let pointsPerAction: Int
    let actionType: ActionType
    let isActive: Bool
    
    enum ActionType: String, CaseIterable {
        case purchase = "Покупка"
        case visit = "Посещение"
        case referral = "Приведение друга"
        case birthday = "День рождения"
        case registration = "Регистрация"
        case socialShare = "Репост в соцсетях"
        
        var icon: String {
            switch self {
            case .purchase: return "cart.fill"
            case .visit: return "location.fill"
            case .referral: return "person.2.fill"
            case .birthday: return "gift.fill"
            case .registration: return "person.badge.plus"
            case .socialShare: return "square.and.arrow.up"
            }
        }
    }
}

class PointsManager: ObservableObject {
    @Published var transactions: [PointTransaction] = []
    @Published var rules: [PointsRule] = []
    
    init() {
        loadDemoData()
    }
    
    func addPoints(to user: inout User, amount: Int, description: String, type: PointTransaction.TransactionType = .earned, programId: UUID, adminId: String? = nil) {
        user.points += amount
        
        let transaction = PointTransaction(
            userId: user.id,
            programId: programId,
            type: type,
            amount: amount,
            description: description,
            adminId: adminId
        )
        
        transactions.append(transaction)
    }
    
    func deductPoints(from user: inout User, amount: Int, description: String, programId: UUID, adminId: String? = nil) -> Bool {
        guard user.points >= amount else { return false }
        
        user.points -= amount
        
        let transaction = PointTransaction(
            userId: user.id,
            programId: programId,
            type: .redeemed,
            amount: -amount,
            description: description,
            adminId: adminId
        )
        
        transactions.append(transaction)
        return true
    }
    
    func getTransactions(forUser userId: UUID) -> [PointTransaction] {
        return transactions.filter { $0.userId == userId }.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getTransactions(forProgram programId: UUID) -> [PointTransaction] {
        return transactions.filter { $0.programId == programId }.sorted { $0.timestamp > $1.timestamp }
    }
    
    private func loadDemoData() {
        // Демо-правила начисления баллов
        rules = [
            PointsRule(programId: UUID(), name: "Покупка", description: "1 балл за каждые 100₽", pointsPerAction: 1, actionType: .purchase, isActive: true),
            PointsRule(programId: UUID(), name: "Посещение", description: "10 баллов за каждое посещение", pointsPerAction: 10, actionType: .visit, isActive: true),
            PointsRule(programId: UUID(), name: "День рождения", description: "100 баллов в подарок", pointsPerAction: 100, actionType: .birthday, isActive: true),
            PointsRule(programId: UUID(), name: "Регистрация", description: "50 баллов при регистрации", pointsPerAction: 50, actionType: .registration, isActive: true)
        ]
    }
}

struct LoyaltyCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let design: CardDesign
    let membersCount: Int
    let revenue: String
    
    init(title: String, description: String, design: CardDesign, membersCount: Int? = nil, revenue: String? = nil) {
        self.title = title
        self.description = description
        self.design = design
        self.membersCount = membersCount ?? Int.random(in: 100...5000)
        
        if let revenue = revenue {
            self.revenue = revenue
        } else {
            let revenue1 = Int.random(in: 100...999)
            let revenue2 = Int.random(in: 100...999)
            self.revenue = "₽\(revenue1),\(revenue2)"
        }
    }
    
    // Конструктор для быстрого создания с цветом (обратная совместимость)
    init(title: String, description: String, color: Color, membersCount: Int? = nil, revenue: String? = nil) {
        let design = CardDesign(
            template: .loyalty,
            primaryColor: color,
            secondaryColor: color.opacity(0.7),
            backgroundColor: .white,
            textColor: .white,
            blocks: [.logo, .title, .subtitle, .points, .memberID],
            logoImage: nil,
            backgroundPattern: nil
        )
        self.init(title: title, description: description, design: design, membersCount: membersCount, revenue: revenue)
    }
}

struct ContentView: View {
    // 🆕 Новая архитектура с компаниями
    @State private var companies: [Company] = [
        Company(name: "Кофейня 'Дом'", logo: nil, adminEmail: "admin@coffee.com")
    ]
    @State private var selectedCompany: Company?
    @State private var selectedTab = 0
    @State private var showingCreateCompany = false
    @State private var showingCreateProgram = false
    
    // 🆕 Система баллов
    @StateObject private var pointsManager = PointsManager()
    
    // 🆕 PassKit Manager
    @StateObject private var passKitManager = PassKitManager()
    
    // Демо-данные для обратной совместимости
    @State private var loyaltyCards: [LoyaltyCard] = [
        LoyaltyCard(title: "Премиум клиенты", description: "VIP программа лояльности", color: .purple, membersCount: 1250, revenue: "₽2,500,000"),
        LoyaltyCard(title: "Базовые клиенты", description: "Стандартная программа", color: .blue, membersCount: 8930, revenue: "₽1,200,000")
    ]
    @State private var showingAddCard = false
    
    init() {
        // Инициализация с демо-программами
        let demoCompany = Company(name: "Демо-компания", logo: nil, adminEmail: "demo@example.com")
        _selectedCompany = State(initialValue: demoCompany)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 🆕 Главная вкладка - Управление компаниями
            NavigationView {
                VStack(spacing: 0) {
                    // Хедер с выбором компании
                    companyHeaderView
                    
                    // Основной контент
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Программы лояльности
                            loyaltyProgramsSection
                            
                            // Старые карты (для демо)
                            if !loyaltyCards.isEmpty {
                                legacyCardsSection
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Платформа лояльности")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingCreateCompany = true
                        } label: {
                            Image(systemName: "building.2.crop.circle.badge.plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingCreateProgram = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                .sheet(isPresented: $showingCreateCompany) {
                    CreateCompanyView { newCompany in
                        companies.append(newCompany)
                        selectedCompany = newCompany
                    }
                }
                .sheet(isPresented: $showingCreateProgram) {
                    if let company = selectedCompany {
                        CreateLoyaltyProgramView(company: company) { newProgram in
                            // Добавить программу к компании
                            if let index = companies.firstIndex(where: { $0.id == company.id }) {
                                companies[index].loyaltyPrograms.append(newProgram)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddCard) {
                    AddCardView { newCard in
                        loyaltyCards.append(newCard)
                    }
                }
            }
            .tabItem {
                Image(systemName: "building.2")
                Text("Компании")
            }
            .tag(0)
            
            // Система баллов
            PointsManagementView(pointsManager: pointsManager)
                .tabItem {
                    Image(systemName: "star.circle")
                    Text("Баллы")
                }
                .tag(1)
            
            // Аналитика
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Аналитика")
                }
                .tag(2)
            
            // Пассы
            PassesManagementView(passKitManager: passKitManager)
                .tabItem {
                    Image(systemName: "wallet.pass")
                    Text("Пассы")
                }
                .tag(3)
            
            // Биллинг
            BillingView()
                .tabItem {
                    Image(systemName: "creditcard")
                    Text("Биллинг")
                }
                .tag(4)
        }
    }
}

struct LoyaltyCardView: View {
    let card: LoyaltyCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: card.design.template.icon)
                            .foregroundColor(card.design.textColor)
                        Text(card.title)
                            .font(.headline)
                            .foregroundColor(card.design.textColor)
                    }
                    Text(card.description)
                        .font(.caption)
                        .foregroundColor(card.design.textColor.opacity(0.8))
                }
                Spacer()
                Image(systemName: "person.3.fill")
                    .foregroundColor(card.design.textColor)
            }
            
            Divider()
                .background(card.design.textColor.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Участники:")
                        .font(.caption)
                        .foregroundColor(card.design.textColor.opacity(0.8))
                    Spacer()
                    Text("\(card.membersCount)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(card.design.textColor)
                }
                
                HStack {
                    Text("Доход:")
                        .font(.caption)
                        .foregroundColor(card.design.textColor.opacity(0.8))
                    Spacer()
                    Text(card.revenue)
                        .font(.caption)
                        .bold()
                        .foregroundColor(card.design.textColor)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [card.design.primaryColor, card.design.secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct AddCardView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var selectedColor = Color.green
    @Environment(\.dismiss) private var dismiss
    let onSave: (LoyaltyCard) -> Void
    
    let colors: [Color] = [.green, .red, .orange, .pink, .indigo, .teal]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название карты", text: $title)
                    TextField("Описание", text: $description)
                }
                
                Section("Цвет") {
                    colorSelectionGrid
                }
            }
            .navigationTitle("Новая карта")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    private var colorSelectionGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(colors, id: \.self) { color in
                colorCircle(for: color)
            }
        }
        .padding(.vertical)
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: 3)
    }
    
    private func colorCircle(for color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 50, height: 50)
            .overlay(
                Circle()
                    .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
            )
            .onTapGesture {
                selectedColor = color
            }
    }
    
    private var saveButton: some View {
        Button("Сохранить") {
            let newCard = LoyaltyCard(
                title: title,
                description: description,
                color: selectedColor
            )
            onSave(newCard)
            dismiss()
        }
        .disabled(title.isEmpty)
    }
}

struct AnalyticsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Метрики
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        MetricCard(title: "Всего пользователей", value: "10,180", icon: "person.3", color: .blue)
                        MetricCard(title: "Активные карты", value: "8,940", icon: "creditcard", color: .green)
                        MetricCard(title: "Общий доход", value: "₽3,7M", icon: "chart.line.uptrend.xyaxis", color: .purple)
                        MetricCard(title: "Рост за месяц", value: "+15%", icon: "arrow.up.right", color: .orange)
                    }
                    .padding()
                    
                    // График (заглушка)
                    VStack(alignment: .leading) {
                        Text("Статистика по месяцам")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Text("График будет здесь")
                                    .foregroundColor(.secondary)
                            )
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Аналитика")
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.title2.bold())
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct BillingView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Текущий план") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Профессиональный")
                                .font(.headline)
                            Text("До 50,000 пользователей")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("₽49,900/мес")
                            .font(.title3.bold())
                    }
                    .padding(.vertical, 4)
                }
                
                Section("История платежей") {
                    ForEach(1...3, id: \.self) { _ in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Ежемесячная подписка")
                                    .font(.subheadline)
                                Text("15 мая 2025")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("₽49,900")
                                .font(.subheadline.bold())
                        }
                    }
                }
                
                Section("Статистика использования") {
                    HStack {
                        Text("Активные пользователи")
                        Spacer()
                        Text("10,180 / 50,000")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("API запросы в месяц")
                        Spacer()
                        Text("234,567 / ∞")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Биллинг")
        }
    }
    
}

// MARK: - Helper Views для новой архитектуры
extension ContentView {
    private var companyHeaderView: some View {
        VStack(spacing: 12) {
            if let company = selectedCompany {
                HStack {
                    VStack(alignment: .leading) {
                        Text(company.name)
                            .font(.title2.bold())
                        Text(company.adminEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    // Переключатель компаний
                    Menu {
                        ForEach(companies) { company in
                            Button(company.name) {
                                selectedCompany = company
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down.circle")
                            .font(.title2)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
    
    private var loyaltyProgramsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Программы лояльности")
                    .font(.headline)
                Spacer()
                if let company = selectedCompany, !company.loyaltyPrograms.isEmpty {
                    Text("\(company.loyaltyPrograms.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if let company = selectedCompany {
                if company.loyaltyPrograms.isEmpty {
                    emptyProgramsView
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(company.loyaltyPrograms) { program in
                            LoyaltyProgramCardView(program: program)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyProgramsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Нет программ лояльности")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Создайте первую программу лояльности для своих клиентов")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreateProgram = true
            } label: {
                Label("Создать программу", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var legacyCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Демо-карты")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddCard = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(loyaltyCards) { card in
                    LoyaltyCardView(card: card)
                }
            }
        }
    }
}

// MARK: - New Views для полноценной платформы

struct LoyaltyProgramCardView: View {
    let program: LoyaltyProgram
    @State private var showingInviteLink = false
    @State private var showingCardPreview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: program.template.icon)
                    .foregroundColor(.white)
                
                Text(program.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    Button("Посмотреть ссылку") {
                        showInviteLink(program)
                    }
                    Button("Копировать ссылку") {
                        copyToClipboard(program.inviteLink)
                    }
                    Button("Предпросмотр карты") {
                        showCardPreview(program)
                    }
                    Button("Статистика") { }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                }
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Пользователи:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(program.users.count)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Ссылка:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("Активна")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: program.template.defaultGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 4)
        .sheet(isPresented: $showingInviteLink) {
            InviteLinkView(program: program)
        }
        .sheet(isPresented: $showingCardPreview) {
            CardPreviewView(program: program)
        }
    }
    
    private func showInviteLink(_ program: LoyaltyProgram) {
        showingInviteLink = true
    }
    
    private func showCardPreview(_ program: LoyaltyProgram) {
        showingCardPreview = true
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

struct CreateCompanyView: View {
    @State private var companyName = ""
    @State private var adminEmail = ""
    @State private var logoUrl = ""
    @Environment(\.dismiss) private var dismiss
    let onSave: (Company) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Информация о компании") {
                    TextField("Название компании", text: $companyName)
                    TextField("Email администратора", text: $adminEmail)
                        .keyboardType(.emailAddress)
                }
                
                Section("Логотип (опционально)") {
                    TextField("URL логотипа", text: $logoUrl)
                        .keyboardType(.URL)
                }
            }
            .navigationTitle("Новая компания")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        let newCompany = Company(
                            name: companyName,
                            logo: logoUrl.isEmpty ? nil : logoUrl,
                            adminEmail: adminEmail
                        )
                        onSave(newCompany)
                        dismiss()
                    }
                    .disabled(companyName.isEmpty || adminEmail.isEmpty)
                }
            }
        }
    }
}

struct CreateLoyaltyProgramView: View {
    let company: Company
    @State private var programName = ""
    @State private var selectedTemplate = CardTemplate.loyalty
    @State private var dynamicFields: [DynamicField] = []
    @Environment(\.dismiss) private var dismiss
    let onSave: (LoyaltyProgram) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название программы", text: $programName)
                    
                    Picker("Шаблон карты", selection: $selectedTemplate) {
                        ForEach(CardTemplate.allCases, id: \.self) { template in
                            Label(template.rawValue, systemImage: template.icon)
                        }
                    }
                }
                
                Section("Динамические поля") {
                    ForEach(FieldType.allCases, id: \.self) { fieldType in
                        HStack {
                            Label(fieldType.rawValue, systemImage: fieldType.icon)
                            Spacer()
                            Button("Добавить") {
                                addDynamicField(type: fieldType)
                            }
                            .font(.caption)
                        }
                    }
                }
                
                if !dynamicFields.isEmpty {
                    Section("Добавленные поля") {
                        ForEach(dynamicFields) { field in
                            HStack {
                                Label(field.label, systemImage: field.type.icon)
                                Spacer()
                                Button("Удалить") {
                                    removeDynamicField(field)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Новая программа")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createProgram()
                    }
                    .disabled(programName.isEmpty)
                }
            }
        }
    }
    
    private func addDynamicField(type: FieldType) {
        let newField = DynamicField(
            type: type,
            label: type.rawValue,
            position: CGPoint(x: 20, y: 50 + Double(dynamicFields.count) * 30),
            style: TextStyle(font: .subheadline, color: .white, alignment: .leading),
            isRequired: type == .userName
        )
        dynamicFields.append(newField)
    }
    
    private func removeDynamicField(_ field: DynamicField) {
        dynamicFields.removeAll { $0.id == field.id }
    }
    
    private func createProgram() {
        let inviteLink = InviteLink.generateLink(for: LoyaltyProgram(
            companyId: company.id,
            name: programName,
            template: selectedTemplate,
            inviteLink: ""
        ))
        
        let newProgram = LoyaltyProgram(
            companyId: company.id,
            name: programName,
            template: selectedTemplate,
            inviteLink: inviteLink.fullUrl
        )
        
        onSave(newProgram)
        dismiss()
    }
}

// MARK: - Customer Registration Views

struct CustomerRegistrationView: View {
    let program: LoyaltyProgram
    @State private var registrationData = RegistrationData()
    @State private var showDatePicker = false
    @State private var showSuccessView = false
    @State private var generatedUser: User?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Личная информация") {
                    TextField("Полное имя *", text: $registrationData.name)
                    
                    HStack {
                        Text("Дата рождения")
                        Spacer()
                        if let birthday = registrationData.birthday {
                            Text(birthday, style: .date)
                                .foregroundColor(.blue)
                        } else {
                            Text("Не указана")
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showDatePicker = true
                    }
                }
                
                Section("Контактная информация") {
                    TextField("Телефон", text: $registrationData.phone)
                        .keyboardType(.phonePad)
                    
                    TextField("Email", text: $registrationData.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Согласия") {
                    Toggle("Получать маркетинговые уведомления", isOn: $registrationData.acceptsMarketing)
                }
                
                Section {
                    Button("Зарегистрироваться") {
                        registerUser()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!registrationData.isValid)
                }
            }
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerView(selectedDate: $registrationData.birthday)
            }
            .fullScreenCover(isPresented: $showSuccessView) {
                if let user = generatedUser {
                    RegistrationSuccessView(user: user, program: program)
                }
            }
        }
    }
    
    private func registerUser() {
        let newUser = User(
            name: registrationData.name,
            birthday: registrationData.birthday,
            phone: registrationData.phone.isEmpty ? nil : registrationData.phone,
            email: registrationData.email.isEmpty ? nil : registrationData.email
        )
        
        generatedUser = newUser
        showSuccessView = true
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date?
    @State private var tempDate = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Дата рождения", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Дата рождения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        selectedDate = tempDate
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RegistrationSuccessView: View {
    let user: User
    let program: LoyaltyProgram
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("Добро пожаловать!")
                    .font(.largeTitle.bold())
                
                Text("Вы успешно зарегистрированы в программе лояльности «\(program.name)»")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            // User Info Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ваша карта лояльности")
                        .font(.headline)
                    Spacer()
                    Text("ID: \(String(user.id.uuidString.prefix(8)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Label(user.name, systemImage: "person")
                    
                    if let phone = user.phone {
                        Label(phone, systemImage: "phone")
                    }
                    
                    if let email = user.email {
                        Label(email, systemImage: "envelope")
                    }
                    
                    Label("\(user.points) баллов", systemImage: "star.circle")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button {
                    addToWallet()
                } label: {
                    Label("Добавить в Wallet", systemImage: "wallet.pass")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(12)
                }
                
                Button {
                    shareCard()
                } label: {
                    Label("Поделиться картой", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button("Готово") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.blue)
        }
        .padding()
    }
    
    private func addToWallet() {
        let walletPass = WalletPass.generatePass(for: user, program: program)
        // В реальном приложении здесь была бы интеграция с PassKit
        print("Генерация .pkpass файла: \(walletPass.passUrl)")
    }
    
    private func shareCard() {
        // Функция для шаринга карты
        print("Поделиться картой пользователя: \(user.name)")
    }
}

// MARK: - Link Sharing View

struct InviteLinkView: View {
    let program: LoyaltyProgram
    @State private var inviteLink: InviteLink
    @State private var showingQRCode = false
    @Environment(\.dismiss) private var dismiss
    
    init(program: LoyaltyProgram) {
        self.program = program
        self._inviteLink = State(initialValue: InviteLink.generateLink(for: program))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: program.template.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(program.name)
                            .font(.title2.bold())
                        
                        Text("Пригласительная ссылка")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Link Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ссылка для клиентов")
                            .font(.headline)
                        
                        HStack {
                            Text(inviteLink.fullUrl)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.blue)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Button {
                                copyToClipboard()
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Link Stats
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Переходы")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(inviteLink.usageCount)")
                                    .font(.title3.bold())
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Активна до")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let expiresAt = inviteLink.expiresAt {
                                    Text(expiresAt, style: .date)
                                        .font(.caption.bold())
                                } else {
                                    Text("Бессрочно")
                                        .font(.caption.bold())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            showingQRCode = true
                        } label: {
                            Label("Показать QR-код", systemImage: "qrcode")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            shareLink()
                        } label: {
                            Label("Поделиться ссылкой", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        Button {
                            regenerateLink()
                        } label: {
                            Label("Создать новую ссылку", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Пригласительная ссылка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingQRCode) {
                QRCodeView(text: inviteLink.fullUrl)
            }
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = inviteLink.fullUrl
    }
    
    private func shareLink() {
        // Поделиться ссылкой через system share sheet
        print("Поделиться ссылкой: \(inviteLink.fullUrl)")
    }
    
    private func regenerateLink() {
        inviteLink = InviteLink.generateLink(for: program)
    }
}

struct QRCodeView: View {
    let text: String
    @State private var qrCodeImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Real QR Code
                VStack {
                    if let qrCodeImage = qrCodeImage {
                        Image(uiImage: qrCodeImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .background(.white)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray.opacity(0.2))
                            .frame(width: 250, height: 250)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                }
                
                Text("Покажите этот QR-код клиентам для регистрации")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("QR-код")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Поделиться") {
                        shareQRCode()
                    }
                    .disabled(qrCodeImage == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateQRCode()
            }
        }
    }
    
    private func generateQRCode() {
        Task {
            await MainActor.run {
                qrCodeImage = QRCodeGenerator.shared.generateHighQualityQRCode(
                    from: text,
                    size: CGSize(width: 250, height: 250)
                )
            }
        }
    }
    
    private func shareQRCode() {
        guard let qrCodeImage = qrCodeImage else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [qrCodeImage, text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            
            // Для iPad
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true)
        }
    }
}

// MARK: - Card Preview View

struct CardPreviewView: View {
    let program: LoyaltyProgram
    @State private var sampleUser = User(
        name: "Иван Петров",
        birthday: Calendar.current.date(byAdding: .year, value: -30, to: Date()),
        phone: "+7 999 123 45 67",
        email: "ivan@example.com"
    )
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: program.template.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Предпросмотр карты")
                            .font(.title2.bold())
                        
                        Text(program.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Card Preview
                    DynamicLoyaltyCardView(program: program, user: sampleUser)
                        .padding(.horizontal)
                    
                    // User Data Editor
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Тестовые данные пользователя")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Имя:")
                                    .frame(width: 80, alignment: .leading)
                                TextField("Имя", text: $sampleUser.name)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Баллы:")
                                    .frame(width: 80, alignment: .leading)
                                Stepper("\(sampleUser.points)", value: $sampleUser.points, in: 0...10000, step: 100)
                            }
                            
                            if let phone = sampleUser.phone {
                                HStack {
                                    Text("Телефон:")
                                        .frame(width: 80, alignment: .leading)
                                    Text(phone)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Info
                    Text("Это предпросмотр того, как будет выглядеть карта у ваших клиентов")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Предпросмотр")
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

struct DynamicLoyaltyCardView: View {
    let program: LoyaltyProgram
    let user: User
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header с логотипом
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: program.template.icon)
                            .foregroundColor(.white)
                        Text(program.name)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Text("Карта лояльности")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                
                // Real QR Code
                Group {
                    if let qrCodeImage = qrCodeImage {
                        Image(uiImage: qrCodeImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .background(.white)
                            .cornerRadius(8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(.white)
                            )
                    }
                }
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Динамические поля
            VStack(alignment: .leading, spacing: 12) {
                // Имя пользователя (всегда отображается)
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 20)
                    Text(user.name)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // Баллы
                HStack {
                    Image(systemName: "star.circle")
                        .foregroundColor(.orange)
                        .frame(width: 20)
                    Text("Баллы:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(user.points)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                
                // Уровень членства (пример)
                HStack {
                    Image(systemName: "crown")
                        .foregroundColor(.yellow)
                        .frame(width: 20)
                    Text("Уровень:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text(membershipLevel)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                
                // ID участника
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 20)
                    Text("ID:")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text(String(user.id.uuidString.prefix(8)).uppercased())
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: program.template.defaultGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(radius: 8)
        .onAppear {
            generateCardQRCode()
        }
    }
    
    private func generateCardQRCode() {
        let qrData = "loyalty://user/\(user.id.uuidString)?program=\(program.id.uuidString)&name=\(user.name)&points=\(user.points)"
        
        Task {
            await MainActor.run {
                qrCodeImage = QRCodeGenerator.shared.generateHighQualityQRCode(
                    from: qrData,
                    size: CGSize(width: 60, height: 60)
                )
            }
        }
    }
    
    private var membershipLevel: String {
        switch user.points {
        case 0..<100: return "Начинающий"
        case 100..<500: return "Серебряный"
        case 500..<1000: return "Золотой"
        default: return "Платиновый"
        }
    }
}

// MARK: - Points Management View

struct PointsManagementView: View {
    @ObservedObject var pointsManager: PointsManager
    @State private var selectedSegment = 0
    @State private var showingAddPoints = false
    @State private var showingPointsRules = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment Control
                Picker("Режим", selection: $selectedSegment) {
                    Text("Транзакции").tag(0)
                    Text("Правила").tag(1)
                    Text("Статистика").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                switch selectedSegment {
                case 0:
                    transactionsView
                case 1:
                    rulesView
                case 2:
                    statisticsView
                default:
                    transactionsView
                }
            }
            .navigationTitle("Управление баллами")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if selectedSegment == 0 {
                            showingAddPoints = true
                        } else if selectedSegment == 1 {
                            showingPointsRules = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPoints) {
                AddPointsView(pointsManager: pointsManager)
            }
            .sheet(isPresented: $showingPointsRules) {
                PointsRulesView(pointsManager: pointsManager)
            }
        }
    }
    
    private var transactionsView: some View {
        List {
            ForEach(pointsManager.transactions.prefix(50), id: \.id) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
        .listStyle(.plain)
    }
    
    private var rulesView: some View {
        List {
            ForEach(pointsManager.rules, id: \.id) { rule in
                PointsRuleRowView(rule: rule)
            }
        }
        .listStyle(.plain)
    }
    
    private var statisticsView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Статистика по баллам
                PointsStatsView(pointsManager: pointsManager)
            }
            .padding()
        }
    }
}

struct TransactionRowView: View {
    let transaction: PointTransaction
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: transaction.type.icon)
                .foregroundColor(transaction.type.color)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing) {
                Text("\(transaction.amount > 0 ? "+" : "")\(transaction.amount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.type.color)
                
                Text(transaction.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PointsRuleRowView: View {
    let rule: PointsRule
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: rule.actionType.icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(rule.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing) {
                Text("+\(rule.pointsPerAction)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Circle()
                    .fill(rule.isActive ? .green : .gray)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PointsStatsView: View {
    @ObservedObject var pointsManager: PointsManager
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Всего начислено",
                value: "\(totalEarned)",
                icon: "plus.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Всего списано", 
                value: "\(totalRedeemed)",
                icon: "minus.circle.fill",
                color: .red
            )
            
            StatCard(
                title: "Транзакций сегодня",
                value: "\(todayTransactions)",
                icon: "calendar",
                color: .blue
            )
            
            StatCard(
                title: "Активных правил",
                value: "\(activeRules)",
                icon: "gear",
                color: .orange
            )
        }
    }
    
    private var totalEarned: Int {
        pointsManager.transactions
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalRedeemed: Int {
        abs(pointsManager.transactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + $1.amount })
    }
    
    private var todayTransactions: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return pointsManager.transactions
            .filter { Calendar.current.startOfDay(for: $0.timestamp) == today }
            .count
    }
    
    private var activeRules: Int {
        pointsManager.rules.filter { $0.isActive }.count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
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

struct AddPointsView: View {
    @ObservedObject var pointsManager: PointsManager
    @State private var selectedUser = "Выберите пользователя"
    @State private var pointsAmount = ""
    @State private var description = ""
    @State private var transactionType = PointTransaction.TransactionType.earned
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Пользователь") {
                    Picker("Пользователь", selection: $selectedUser) {
                        Text("Иван Петров (ID: 12345)").tag("Иван Петров")
                        Text("Мария Сидорова (ID: 67890)").tag("Мария Сидорова")
                        Text("Демо пользователь").tag("Демо пользователь")
                    }
                }
                
                Section("Транзакция") {
                    Picker("Тип операции", selection: $transactionType) {
                        ForEach(PointTransaction.TransactionType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                        }
                    }
                    
                    TextField("Количество баллов", text: $pointsAmount)
                        .keyboardType(.numberPad)
                    
                    TextField("Описание операции", text: $description)
                }
            }
            .navigationTitle("Операция с баллами")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Выполнить") {
                        performTransaction()
                    }
                    .disabled(selectedUser == "Выберите пользователя" || pointsAmount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func performTransaction() {
        guard let amount = Int(pointsAmount) else { return }
        
        // В реальном приложении здесь была бы логика работы с настоящими пользователями
        let transaction = PointTransaction(
            userId: UUID(),
            programId: UUID(),
            type: transactionType,
            amount: transactionType == .redeemed ? -amount : amount,
            description: description,
            adminId: "admin@example.com"
        )
        
        pointsManager.transactions.append(transaction)
        dismiss()
    }
}

struct PointsRulesView: View {
    @ObservedObject var pointsManager: PointsManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(pointsManager.rules, id: \.id) { rule in
                    PointsRuleRowView(rule: rule)
                }
            }
            .navigationTitle("Правила начисления")
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

// MARK: - Apple Wallet Pass Views

struct PassesManagementView: View {
    @ObservedObject var passKitManager: PassKitManager
    @State private var showingCreatePass = false
    @State private var selectedPass: WalletPassData?
    @State private var showingPassPreview = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header Stats
                    passStatsSection
                    
                    // Passes Grid
                    passesGridSection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Управление пассами")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreatePass = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingCreatePass) {
                PassBuilderView(passKitManager: passKitManager)
            }
            .sheet(isPresented: $showingPassPreview) {
                if let pass = selectedPass {
                    PassPreviewView(passData: pass, passKitManager: passKitManager)
                }
            }
        }
    }
    
    private var passStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Всего пассов",
                value: "\(passKitManager.passes.count)",
                icon: "wallet.pass.fill",
                color: .blue
            )
            
            StatCard(
                title: "Типов пассов",
                value: "\(Set(passKitManager.passes.map { $0.passType }).count)",
                icon: "rectangle.stack.fill",
                color: .green
            )
        }
    }
    
    private var passesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Мои пассы")
                    .font(.headline)
                Spacer()
                if !passKitManager.passes.isEmpty {
                    Text("\(passKitManager.passes.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if passKitManager.passes.isEmpty {
                emptyPassesView
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(passKitManager.passes) { pass in
                        PassCardView(passData: pass) {
                            selectedPass = pass
                            showingPassPreview = true
                        }
                    }
                }
            }
        }
    }
    
    private var emptyPassesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Нет созданных пассов")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Создайте свой первый Apple Wallet пасс для клиентов")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingCreatePass = true
            } label: {
                Label("Создать пасс", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Быстрые действия")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickActionButton(
                    title: "Создать купон",
                    icon: "tag.fill",
                    color: .orange
                ) {
                    createQuickPass(type: .coupon)
                }
                
                QuickActionButton(
                    title: "Карта лояльности",
                    icon: "creditcard.fill",
                    color: .purple
                ) {
                    createQuickPass(type: .storeCard)
                }
                
                QuickActionButton(
                    title: "Билет на событие",
                    icon: "ticket.fill",
                    color: .green
                ) {
                    createQuickPass(type: .eventTicket)
                }
                
                QuickActionButton(
                    title: "Общий пасс",
                    icon: "rectangle.fill",
                    color: .blue
                ) {
                    createQuickPass(type: .generic)
                }
            }
        }
    }
    
    private func createQuickPass(type: PassType) {
        // Создание быстрого пасса с предустановленными настройками
        showingCreatePass = true
    }
}

struct PassCardView: View {
    let passData: WalletPassData
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: passData.passType.icon)
                    .foregroundColor(.white)
                
                Text(passData.description)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
            }
            
            Text(passData.organizationName)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
            
            Divider()
                .background(.white.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Тип")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(passData.passType.description)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ID")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(passData.serialNumber.suffix(6)))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(radius: 4)
        .onTapGesture {
            onTap()
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct PassBuilderView: View {
    @ObservedObject var passKitManager: PassKitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var selectedTemplate: PassTemplate?
    @State private var passData = PassCreationData()
    @State private var showingPreview = false
    
    // Templates like Walletsio
    let templates: [PassTemplate] = [
        PassTemplate(
            id: "loyalty-card",
            name: "Карта лояльности",
            description: "Программа лояльности для постоянных клиентов",
            icon: "creditcard.fill",
            color: .blue,
            passType: .storeCard,
            presetFields: [
                PassFieldTemplate(key: "member", label: "Участник", placeholder: "Имя клиента"),
                PassFieldTemplate(key: "points", label: "Баллы", placeholder: "0"),
                PassFieldTemplate(key: "level", label: "Уровень", placeholder: "Базовый")
            ]
        ),
        PassTemplate(
            id: "discount-coupon",
            name: "Скидочный купон",
            description: "Купон со скидкой на товары или услуги",
            icon: "tag.fill",
            color: .orange,
            passType: .coupon,
            presetFields: [
                PassFieldTemplate(key: "discount", label: "Скидка", placeholder: "10%"),
                PassFieldTemplate(key: "expires", label: "Действует до", placeholder: "31.12.2025"),
                PassFieldTemplate(key: "code", label: "Код", placeholder: "SAVE10")
            ]
        ),
        PassTemplate(
            id: "event-ticket",
            name: "Билет на мероприятие",
            description: "Входной билет на концерт, спектакль или конференцию",
            icon: "ticket.fill",
            color: .purple,
            passType: .eventTicket,
            presetFields: [
                PassFieldTemplate(key: "event", label: "Мероприятие", placeholder: "Название события"),
                PassFieldTemplate(key: "date", label: "Дата", placeholder: "25 июня 2025"),
                PassFieldTemplate(key: "seat", label: "Место", placeholder: "Ряд 5, место 12")
            ]
        ),
        PassTemplate(
            id: "boarding-pass",
            name: "Посадочный талон",
            description: "Билет на самолет, поезд или автобус",
            icon: "airplane",
            color: .green,
            passType: .boardingPass,
            presetFields: [
                PassFieldTemplate(key: "passenger", label: "Пассажир", placeholder: "Иван Иванов"),
                PassFieldTemplate(key: "flight", label: "Рейс", placeholder: "SU 1234"),
                PassFieldTemplate(key: "gate", label: "Выход", placeholder: "A12")
            ]
        ),
        PassTemplate(
            id: "membership-card",
            name: "Членская карта",
            description: "Карта члена клуба, спортзала или организации",
            icon: "person.card.fill",
            color: .indigo,
            passType: .generic,
            presetFields: [
                PassFieldTemplate(key: "member", label: "Участник", placeholder: "Имя участника"),
                PassFieldTemplate(key: "id", label: "ID", placeholder: "123456"),
                PassFieldTemplate(key: "status", label: "Статус", placeholder: "Активен")
            ]
        ),
        PassTemplate(
            id: "gift-card",
            name: "Подарочная карта",
            description: "Подарочный сертификат на определенную сумму",
            icon: "gift.fill",
            color: .pink,
            passType: .storeCard,
            presetFields: [
                PassFieldTemplate(key: "amount", label: "Сумма", placeholder: "5000 ₽"),
                PassFieldTemplate(key: "code", label: "Код", placeholder: "GIFT2025"),
                PassFieldTemplate(key: "expires", label: "Действует до", placeholder: "31.12.2025")
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                
                // Content based on step
                switch currentStep {
                case 0:
                    templateSelectionView
                case 1:
                    basicInfoView
                case 2:
                    designCustomizationView
                case 3:
                    fieldsCustomizationView
                case 4:
                    previewAndCreateView
                default:
                    templateSelectionView
                }
                
                // Bottom navigation
                bottomNavigationBar
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Step Views
    
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? .blue : .gray.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Выберите шаблон"
        case 1: return "Основная информация"
        case 2: return "Дизайн"
        case 3: return "Настройка полей"
        case 4: return "Предпросмотр"
        default: return "Создание пасса"
        }
    }
    
    private var templateSelectionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Выберите тип пасса")
                        .font(.title2.bold())
                    
                    Text("Начните с готового шаблона, который подходит для вашего бизнеса")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Templates Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(templates) { template in
                        TemplateCardView(
                            template: template,
                            isSelected: selectedTemplate?.id == template.id
                        ) {
                            selectedTemplate = template
                            passData.backgroundColor = template.color
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var basicInfoView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Selected template preview
                if let template = selectedTemplate {
                    SelectedTemplatePreview(template: template)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: "Информация об организации") {
                        VStack(spacing: 16) {
                            CustomTextField(
                                title: "Название организации",
                                text: $passData.organizationName,
                                placeholder: "Например: Кофейня 'Утро'"
                            )
                            
                            CustomTextField(
                                title: "Описание пасса",
                                text: $passData.passDescription,
                                placeholder: "Например: Карта постоянного клиента"
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var designCustomizationView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Live Preview
                if let template = selectedTemplate {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Предпросмотр")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        PassPreviewCard(
                            template: template,
                            passData: passData
                        )
                        .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: "Цвета") {
                        VStack(spacing: 16) {
                            ColorPickerRow(
                                title: "Цвет фона",
                                color: $passData.backgroundColor
                            )
                            
                            ColorPickerRow(
                                title: "Цвет текста",
                                color: $passData.foregroundColor
                            )
                        }
                    }
                    
                    FormSection(title: "Логотип (опционально)") {
                        VStack(spacing: 12) {
                            Button {
                                // Image picker action
                            } label: {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                        .foregroundColor(.blue)
                                    Text("Добавить логотип")
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .padding()
                                .background(.gray.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var fieldsCustomizationView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Настройте поля пасса")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("Добавьте информацию, которая будет отображаться на пассе")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                if let template = selectedTemplate {
                    // Live Preview Section
                    VStack(spacing: 16) {
                        Text("Предпросмотр в реальном времени")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Interactive Pass Preview
                        InteractivePassPreview(template: template, passData: passData)
                            .padding(.horizontal)
                    }
                    
                    // Visual Field Editor
                    VStack(spacing: 20) {
                        Text("Редактор полей")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                            ForEach(Array(template.presetFields.enumerated()), id: \.offset) { index, fieldTemplate in
                                VisualFieldCustomizationCard(
                                    fieldTemplate: fieldTemplate,
                                    value: getFieldValue(for: fieldTemplate.key),
                                    onValueChange: { newValue in
                                        updateFieldValue(key: fieldTemplate.key, value: newValue, label: fieldTemplate.label)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private var previewAndCreateView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Final Preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Готовый пасс")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if let template = selectedTemplate {
                        FinalPassPreview(template: template, passData: passData)
                            .padding(.horizontal)
                    }
                }
                
                // Pass Information Summary
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: "Сводка") {
                        VStack(spacing: 12) {
                            InfoRow(title: "Тип пасса", value: selectedTemplate?.name ?? "")
                            InfoRow(title: "Организация", value: passData.organizationName)
                            InfoRow(title: "Описание", value: passData.passDescription)
                            InfoRow(title: "Полей", value: "\(passData.customFields.count)")
                        }
                    }
                }
                .padding()
                
                // Create Button
                Button {
                    createPass()
                } label: {
                    HStack {
                        Image(systemName: "wallet.pass.fill")
                        Text("Создать пасс")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(radius: 4)
                }
                .padding()
                .disabled(!isFormValid)
            }
        }
    }
    
    private var bottomNavigationBar: some View {
        HStack {
            if currentStep > 0 {
                Button("Назад") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            if currentStep < 4 {
                Button("Далее") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.blue)
                .cornerRadius(25)
                .disabled(!canProceedToNextStep)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Helper Properties and Methods
    
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 0: return selectedTemplate != nil
        case 1: return !passData.organizationName.isEmpty && !passData.passDescription.isEmpty
        case 2: return true
        case 3: return true
        case 4: return isFormValid
        default: return false
        }
    }
    
    private var isFormValid: Bool {
        !passData.organizationName.isEmpty && 
        !passData.passDescription.isEmpty && 
        selectedTemplate != nil
    }
    
    private func getFieldValue(for key: String) -> String {
        return passData.customFields.first(where: { $0.key == key })?.value ?? ""
    }
    
    private func updateFieldValue(key: String, value: String, label: String) {
        if let index = passData.customFields.firstIndex(where: { $0.key == key }) {
            passData.customFields[index] = PassField(key: key, label: label, value: value)
        } else {
            passData.customFields.append(PassField(key: key, label: label, value: value))
        }
    }
    
    private func createPass() {
        guard let template = selectedTemplate else { return }
        
        var walletPassData = WalletPassData(
            passType: template.passType,
            organizationName: passData.organizationName,
            description: passData.passDescription,
            serialNumber: generateSerialNumber()
        )
        
        walletPassData.primaryFields = passData.customFields
        
        passKitManager.savePass(walletPassData)
        dismiss()
    }
    
    private func generateSerialNumber() -> String {
        let prefix = selectedTemplate?.passType.rawValue.prefix(2).uppercased() ?? "GP"
        let randomSuffix = String(format: "%06d", Int.random(in: 100000...999999))
        return "\(prefix)\(randomSuffix)"
    }
    
}


struct PassPreviewView: View {
    let passData: WalletPassData
    @ObservedObject var passKitManager: PassKitManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Pass Preview Card
                    passPreviewCard
                    
                    // Pass Information
                    passInfoSection
                    
                    // Actions
                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Предпросмотр пасса")
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
    
    private var passPreviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: passData.passType.icon)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(passData.organizationName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(passData.description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Fields Preview
            VStack(alignment: .leading, spacing: 12) {
                if !passData.primaryFields.isEmpty {
                    ForEach(passData.primaryFields) { field in
                        fieldPreview(field)
                    }
                }
                
                if !passData.secondaryFields.isEmpty {
                    HStack {
                        ForEach(passData.secondaryFields) { field in
                            fieldPreview(field)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            
            // Barcode
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("QR")
                            .font(.caption)
                            .foregroundColor(.black)
                    )
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(radius: 8)
    }
    
    private func fieldPreview(_ field: PassField) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let label = field.label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(field.value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
    
    private var passInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Информация о пассе")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoRow(title: "Тип", value: passData.passType.description)
                InfoRow(title: "Организация", value: passData.organizationName)
                InfoRow(title: "Описание", value: passData.description)
                InfoRow(title: "Серийный номер", value: passData.serialNumber)
                InfoRow(title: "Полей", value: "\(getTotalFieldsCount())")
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                passKitManager.addPassToWallet(passData)
            } label: {
                Label("Добавить в Wallet", systemImage: "wallet.pass")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .cornerRadius(12)
            }
            
            Button {
                sharePass()
            } label: {
                Label("Поделиться пассом", systemImage: "square.and.arrow.up")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            
            Button {
                passKitManager.deletePass(passData)
                dismiss()
            } label: {
                Label("Удалить пасс", systemImage: "trash")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    private func getTotalFieldsCount() -> Int {
        return passData.headerFields.count + 
               passData.primaryFields.count + 
               passData.secondaryFields.count + 
               passData.auxiliaryFields.count
    }
    
    private func sharePass() {
        print("Поделиться пассом: \(passData.description)")
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Walletsio Style Components

struct TemplateCardView: View {
    let template: PassTemplate
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 20) {
                // Enhanced Visual Pass Preview
                ZStack {
                    // Background Card Shape
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [template.color, template.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                        .shadow(color: template.color.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    // Mini Pass Content
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: template.icon)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Text(template.name)
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer()
                            }
                            
                            // Mini fields preview
                            ForEach(0..<min(2, template.presetFields.count), id: \.self) { index in
                                HStack {
                                    Circle()
                                        .fill(.white.opacity(0.3))
                                        .frame(width: 2, height: 2)
                                    Rectangle()
                                        .fill(.white.opacity(0.5))
                                        .frame(width: 30, height: 2)
                                        .cornerRadius(1)
                                    Spacer()
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Mini QR placeholder
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white.opacity(0.8))
                            .frame(width: 16, height: 16)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                
                // Template Info
                VStack(spacing: 6) {
                    Text(template.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Selection Indicator
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(template.color)
                            .font(.caption)
                        Text("Выбрано")
                            .font(.caption2.bold())
                            .foregroundColor(template.color)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(template.color.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? template.color : .gray.opacity(0.2), lineWidth: isSelected ? 3 : 1)
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: isSelected ? 12 : 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedTemplatePreview: View {
    let template: PassTemplate
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Выбранный шаблон")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                Image(systemName: template.icon)
                    .font(.title)
                    .foregroundColor(template.color)
                    .frame(width: 50, height: 50)
                    .background(template.color.opacity(0.2))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(.gray.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

struct EnhancedSelectedTemplatePreview: View {
    let template: PassTemplate
    
    var body: some View {
        VStack(spacing: 20) {
            // Template Header with Stats
            HStack(spacing: 16) {
                // Enhanced Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [template.color, template.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: template.color.opacity(0.3), radius: 4)
                    
                    Image(systemName: template.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Template Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(template.name)
                        .font(.title3.bold())
                    
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Usage Stats
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("Популярный")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.stack.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(template.presetFields.count) полей")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Selection Badge
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    Text("Выбрано")
                        .font(.caption2.bold())
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(template.color.opacity(0.3), lineWidth: 2)
            )
            
            // Preview Fields
            VStack(alignment: .leading, spacing: 12) {
                Text("Предустановленные поля:")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(template.presetFields, id: \.key) { field in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(template.color.opacity(0.2))
                                .frame(width: 6, height: 6)
                            
                            Text(field.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .background(.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(.gray.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.bold())
            
            Spacer()
            
            ColorPicker("", selection: $color)
                .labelsHidden()
                .frame(width: 40, height: 40)
        }
    }
}

struct PassPreviewCard: View {
    let template: PassTemplate
    let passData: PassCreationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: template.icon)
                    .foregroundColor(.white)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(passData.organizationName.isEmpty ? template.name : passData.organizationName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(passData.passDescription.isEmpty ? template.description : passData.passDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Sample Fields
            VStack(alignment: .leading, spacing: 8) {
                ForEach(template.presetFields.prefix(3), id: \.key) { fieldTemplate in
                    HStack {
                        Text("\\(fieldTemplate.label):")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text(getPreviewValue(for: fieldTemplate))
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [passData.backgroundColor, passData.backgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(radius: 8)
    }
    
    private func getPreviewValue(for fieldTemplate: PassFieldTemplate) -> String {
        let customValue = passData.customFields.first(where: { $0.key == fieldTemplate.key })?.value
        return customValue?.isEmpty == false ? customValue! : fieldTemplate.placeholder
    }
}

struct FieldCustomizationRow: View {
    let fieldTemplate: PassFieldTemplate
    let value: String
    let onValueChange: (String) -> Void
    
    @State private var localValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(fieldTemplate.label)
                .font(.subheadline.bold())
            
            TextField(fieldTemplate.placeholder, text: $localValue)
                .padding()
                .background(.gray.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                )
                .onAppear {
                    localValue = value
                }
                .onChange(of: localValue) {
                    onValueChange(localValue)
                }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

struct FinalPassPreview: View {
    let template: PassTemplate
    let passData: PassCreationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with organization info
            HStack {
                Image(systemName: template.icon)
                    .foregroundColor(.white)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(passData.organizationName)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(passData.passDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // QR Code placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("QR")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                    )
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            // All custom fields
            VStack(alignment: .leading, spacing: 12) {
                ForEach(passData.customFields, id: \.key) { field in
                    if !field.value.isEmpty {
                        HStack {
                            Text("\\(field.label ?? field.key):")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text(field.value)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // If no custom fields, show placeholders
                if passData.customFields.isEmpty || passData.customFields.allSatisfy({ $0.value.isEmpty }) {
                    ForEach(template.presetFields, id: \.key) { fieldTemplate in
                        HStack {
                            Text("\\(fieldTemplate.label):")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text(fieldTemplate.placeholder)
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.6))
                                .italic()
                        }
                    }
                }
            }
            
            // Pass metadata
            HStack {
                VStack(alignment: .leading) {
                    Text("Тип пасса")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text(template.name)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Создан")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text(Date(), style: .date)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [passData.backgroundColor, passData.backgroundColor.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(radius: 12)
    }
}

// MARK: - Enhanced Visual Components

struct InteractivePassPreview: View {
    let template: PassTemplate
    let passData: PassCreationData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with organization info
            HStack {
                Image(systemName: template.icon)
                    .foregroundColor(.white)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.white.opacity(0.2)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(passData.organizationName.isEmpty ? "Название организации" : passData.organizationName)
                        .font(.headline)
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: passData.organizationName)
                    Text(passData.passDescription.isEmpty ? "Описание пасса" : passData.passDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .animation(.easeInOut(duration: 0.3), value: passData.passDescription)
                }
                
                Spacer()
                
                // Animated QR Code
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .frame(width: 50, height: 50)
                    
                    VStack(spacing: 2) {
                        ForEach(0..<3) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<3) { col in
                                    Rectangle()
                                        .fill(.black)
                                        .frame(width: 3, height: 3)
                                        .opacity(Double.random(in: 0.3...1.0))
                                        .animation(.easeInOut(duration: 2.0).repeatForever(), value: passData.customFields.count)
                                }
                            }
                        }
                    }
                }
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            // Dynamic Fields Preview
            VStack(alignment: .leading, spacing: 12) {
                ForEach(template.presetFields, id: \.key) { fieldTemplate in
                    let value = getFieldValue(for: fieldTemplate.key, from: passData)
                    
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(value.isEmpty ? .white.opacity(0.3) : .white.opacity(0.6))
                                .frame(width: 4, height: 4)
                                .animation(.easeInOut(duration: 0.3), value: value)
                            
                            Text("\(fieldTemplate.label):")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Text(value.isEmpty ? fieldTemplate.placeholder : value)
                            .font(.caption.bold())
                            .foregroundColor(value.isEmpty ? .white.opacity(0.5) : .white)
                            .italic(value.isEmpty)
                            .animation(.easeInOut(duration: 0.3), value: value)
                    }
                }
            }
            
            // Visual Effects
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Тип")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                    Text(template.name)
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Pulse animation for active editing
                if !passData.customFields.isEmpty {
                    Circle()
                        .fill(.white.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 1.0).repeatForever(), value: passData.customFields.count)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [passData.backgroundColor, passData.backgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: passData.backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func getFieldValue(for key: String, from passData: PassCreationData) -> String {
        return passData.customFields.first(where: { $0.key == key })?.value ?? ""
    }
}

struct VisualFieldCustomizationCard: View {
    let fieldTemplate: PassFieldTemplate
    let value: String
    let onValueChange: (String) -> Void
    
    @State private var localValue: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Field Header with Icon
            HStack {
                ZStack {
                    Circle()
                        .fill(getFieldColor().opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: getFieldIcon())
                        .foregroundColor(getFieldColor())
                        .font(.system(size: 16, weight: .medium))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(fieldTemplate.label)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    
                    Text(fieldTemplate.placeholder)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Indicator
                Image(systemName: localValue.isEmpty ? "circle" : "checkmark.circle.fill")
                    .foregroundColor(localValue.isEmpty ? .gray : .green)
                    .font(.system(size: 16))
                    .animation(.easeInOut(duration: 0.3), value: localValue)
            }
            
            // Input Field with Enhanced Styling
            VStack(alignment: .leading, spacing: 8) {
                TextField(fieldTemplate.placeholder, text: $localValue)
                    .focused($isFieldFocused)
                    .padding()
                    .background(isEditing ? .blue.opacity(0.1) : .gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEditing ? .blue : .gray.opacity(0.2), lineWidth: isEditing ? 2 : 1)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isEditing)
                    .onTapGesture {
                        isFieldFocused = true
                    }
                
                // Character Count and Status
                HStack {
                    if !localValue.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Заполнено")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    }
                    
                    Spacer()
                    
                    Text("\(localValue.count) символов")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .animation(.easeInOut(duration: 0.3), value: localValue)
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(isEditing ? 0.1 : 0.05), radius: isEditing ? 8 : 4)
        .scaleEffect(isEditing ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditing)
        .onAppear {
            localValue = value
        }
        .onChange(of: localValue) {
            onValueChange(localValue)
        }
        .onChange(of: isFieldFocused) {
            isEditing = isFieldFocused
        }
    }
    
    private func getFieldIcon() -> String {
        switch fieldTemplate.key {
        case "customerName": return "person.fill"
        case "points": return "star.fill"
        case "level": return "crown.fill"
        case "memberID": return "number"
        case "expiryDate": return "calendar"
        case "balance": return "dollarsign.circle.fill"
        default: return "text.alignleft"
        }
    }
    
    private func getFieldColor() -> Color {
        switch fieldTemplate.key {
        case "customerName": return .blue
        case "points": return .orange
        case "level": return .purple
        case "memberID": return .green
        case "expiryDate": return .red
        case "balance": return .mint
        default: return .gray
        }
    }
}

#Preview {
    ContentView()
}
