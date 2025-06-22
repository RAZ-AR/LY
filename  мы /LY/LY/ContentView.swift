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

// MARK: - Color Utilities
extension Color {
    static func fromRGBString(_ rgbString: String) -> Color {
        // Parse "rgb(r, g, b)" format
        let cleanString = rgbString.replacingOccurrences(of: "rgb(", with: "").replacingOccurrences(of: ")", with: "")
        let components = cleanString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        guard components.count == 3,
              let red = Double(components[0]),
              let green = Double(components[1]),
              let blue = Double(components[2]) else {
            return Color.blue // fallback color
        }
        
        return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
    }
}

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
struct Company: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let logo: String?
    let adminEmail: String
    var loyaltyPrograms: [LoyaltyProgram] = []
    let createdAt: Date = Date()
}

struct LoyaltyProgram: Identifiable, Hashable {
    let id = UUID()
    let companyId: UUID
    let name: String
    let template: CardTemplate
    let inviteLink: String
    var users: [User] = []
    let createdAt: Date = Date()
}

struct User: Identifiable, Hashable {
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

// MARK: - Pass Template Models
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
    let createdAt: Date
    
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
        self.createdAt = Date()
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
    
    var displayName: String {
        return description
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
        
        _ = PKPassLibrary()
        _ = PKAddPassesViewController(pass: pass)
        
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
        // Store Card with proper field hierarchy
        var demoPass1 = WalletPassData(
            passType: .storeCard,
            organizationName: "Кофейня 'Дом'",
            description: "Карта лояльности",
            serialNumber: "LC001234567"
        )
        
        // Header fields (visible in stack)
        demoPass1.headerFields = [
            PassField(key: "points", label: "Баллы", value: "1,250")
        ]
        
        // Primary fields (most prominent)
        demoPass1.primaryFields = [
            PassField(key: "balance", label: "Баланс", value: "1,250 ₽"),
            PassField(key: "level", label: "Уровень", value: "Gold")
        ]
        
        // Secondary fields
        demoPass1.secondaryFields = [
            PassField(key: "member", label: "Участник с", value: "Янв 2024"),
            PassField(key: "visits", label: "Посещений", value: "42"),
            PassField(key: "expires", label: "Действует до", value: "Дек 2025")
        ]
        
        // Auxiliary fields
        demoPass1.auxiliaryFields = [
            PassField(key: "cardNumber", label: "Номер карты", value: "****4567"),
            PassField(key: "phone", label: "Телефон", value: "+7 999 123 45 67")
        ]
        
        // Back fields
        demoPass1.backFields = [
            PassField(key: "address", label: "Адрес", value: "ул. Тверская, 12, Москва"),
            PassField(key: "hours", label: "Часы работы", value: "Пн-Вс: 8:00-22:00"),
            PassField(key: "website", label: "Сайт", value: "www.coffeehouse.ru"),
            PassField(key: "support", label: "Поддержка", value: "+7 800 555 35 35")
        ]
        
        // Coupon with different structure
        var demoPass2 = WalletPassData(
            passType: .coupon,
            organizationName: "Ресторан 'Вкус'",
            description: "Скидочный купон",
            serialNumber: "CP001234567"
        )
        
        demoPass2.headerFields = [
            PassField(key: "discount", label: "Скидка", value: "25%")
        ]
        
        demoPass2.primaryFields = [
            PassField(key: "offer", label: "Предложение", value: "25% скидка"),
            PassField(key: "minOrder", label: "От суммы", value: "1,500 ₽")
        ]
        
        demoPass2.secondaryFields = [
            PassField(key: "validUntil", label: "Действует до", value: "31 Дек 2024"),
            PassField(key: "category", label: "Категория", value: "Основные блюда")
        ]
        
        demoPass2.auxiliaryFields = [
            PassField(key: "terms", label: "Условия", value: "Не суммируется с другими акциями")
        ]
        
        demoPass2.backFields = [
            PassField(key: "description", label: "Описание", value: "Скидка действует на все основные блюда из меню"),
            PassField(key: "restrictions", label: "Ограничения", value: "Не действует на напитки и десерты"),
            PassField(key: "location", label: "Адрес", value: "ул. Арбат, 25, Москва")
        ]
        
        // Event Ticket
        var demoPass3 = WalletPassData(
            passType: .eventTicket,
            organizationName: "Театр 'Современник'",
            description: "Билет на спектакль",
            serialNumber: "ET001234567"
        )
        
        demoPass3.headerFields = [
            PassField(key: "event", label: "Спектакль", value: "Гамлет")
        ]
        
        demoPass3.primaryFields = [
            PassField(key: "showTime", label: "Время", value: "19:00"),
            PassField(key: "seat", label: "Место", value: "Ряд 5, М. 12")
        ]
        
        demoPass3.secondaryFields = [
            PassField(key: "date", label: "Дата", value: "25 Дек 2024"),
            PassField(key: "hall", label: "Зал", value: "Большой зал"),
            PassField(key: "price", label: "Цена", value: "2,500 ₽")
        ]
        
        passes = [demoPass1, demoPass2, demoPass3]
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
                            // Feature Announcement Banner
                            featureAnnouncementBanner
                            
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
            
            // Пассы - управление
            PassesManagementView(passKitManager: passKitManager)
                .tabItem {
                    Image(systemName: "wallet.pass.fill")
                    Text("Пассы")
                }
                .tag(3)
                .badge("NEW")
            
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
    @State private var selectedCompany: Company?
    @State private var selectedProgram: LoyaltyProgram?
    @State private var companies: [Company] = [
        Company(name: "Кофейня 'Дом'", logo: nil, adminEmail: "admin@coffee.com"),
        Company(name: "Демо-компания", logo: nil, adminEmail: "demo@example.com")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Selectors
                selectorsSection
                
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
            }
            .navigationTitle("Аналитика")
        }
    }
    
    private var selectorsSection: some View {
        VStack(spacing: 12) {
            // Company Selector
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Компания:")
                        .font(.subheadline.bold())
                    Spacer()
                }
                
                Picker("Выберите компанию", selection: $selectedCompany) {
                    Text("Все компании").tag(Company?.none)
                    ForEach(companies) { company in
                        Text(company.name).tag(Company?.some(company))
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Program Selector (только если выбрана компания)
            if let selectedCompany = selectedCompany {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Программа лояльности:")
                            .font(.subheadline.bold())
                        Spacer()
                    }
                    
                    if selectedCompany.loyaltyPrograms.isEmpty {
                        Text("У компании нет программ лояльности")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Picker("Выберите программу", selection: $selectedProgram) {
                            Text("Все программы").tag(LoyaltyProgram?.none)
                            ForEach(selectedCompany.loyaltyPrograms) { program in
                                Text(program.name).tag(LoyaltyProgram?.some(program))
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
            
            // Current Selection Info
            currentSelectionInfo
            
            Divider()
        }
        .padding()
        .background(.gray.opacity(0.05))
        .onChange(of: selectedCompany) {
            selectedProgram = nil
        }
    }
    
    private var currentSelectionInfo: some View {
        Group {
            if let selectedProgram = selectedProgram {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Аналитика для: \(selectedProgram.name)")
                            .font(.caption.bold())
                        Text("\(selectedProgram.users.count) пользователей")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(8)
                .background(.blue.opacity(0.1))
                .cornerRadius(6)
            } else if let selectedCompany = selectedCompany {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Аналитика для: \(selectedCompany.name)")
                            .font(.caption.bold())
                        Text("\(selectedCompany.loyaltyPrograms.count) программ")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(8)
                .background(.green.opacity(0.1))
                .cornerRadius(6)
            } else {
                HStack {
                    Image(systemName: "chart.pie")
                        .foregroundColor(.purple)
                    Text("Общая аналитика по всем компаниям")
                        .font(.caption.bold())
                    Spacer()
                }
                .padding(8)
                .background(.purple.opacity(0.1))
                .cornerRadius(6)
            }
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
    @State private var selectedTab = 0
    @State private var selectedCompany: Company?
    @State private var showingTopUp = false
    @State private var companies: [Company] = [
        Company(name: "Кофейня 'Дом'", logo: nil, adminEmail: "admin@coffee.com"),
        Company(name: "Демо-компания", logo: nil, adminEmail: "demo@example.com")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment Control
                Picker("Режим", selection: $selectedTab) {
                    Text("Общий биллинг").tag(0)
                    Text("По компаниям").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                switch selectedTab {
                case 0:
                    generalBillingView
                case 1:
                    companyBillingView
                default:
                    generalBillingView
                }
            }
            .navigationTitle("Биллинг")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTopUp = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingTopUp) {
                TopUpView(selectedCompany: selectedTab == 1 ? selectedCompany : nil)
            }
        }
    }
    
    private var generalBillingView: some View {
        List {
            // Общий баланс
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Общий баланс")
                            .font(.headline)
                        Text("Доступно для всех компаний")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("₽125,450")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }
                .padding(.vertical, 8)
            }
                
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
                ForEach(1...5, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(index == 1 ? "Пополнение баланса" : "Ежемесячная подписка")
                                .font(.subheadline)
                            Text("\(15 - index) мая 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(index == 1 ? "+₽50,000" : "-₽49,900")
                            .font(.subheadline.bold())
                            .foregroundColor(index == 1 ? .green : .primary)
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
                
                HStack {
                    Text("Количество компаний")
                    Spacer()
                    Text("\(companies.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var companyBillingView: some View {
        VStack(spacing: 0) {
            // Company Selector
            if !companies.isEmpty {
                companySelector
            }
            
            List {
                if let company = selectedCompany {
                    companyBillingContent(for: company)
                } else {
                    companyBillingOverview
                }
            }
        }
    }
    
    private var companySelector: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Компания:")
                    .font(.subheadline.bold())
                Spacer()
            }
            
            Picker("Выберите компанию", selection: $selectedCompany) {
                Text("Обзор по всем").tag(Company?.none)
                ForEach(companies) { company in
                    Text(company.name).tag(Company?.some(company))
                }
            }
            .pickerStyle(.segmented)
            
            Divider()
        }
        .padding()
        .background(.gray.opacity(0.05))
    }
    
    private var companyBillingOverview: some View {
        ForEach(companies) { company in
            Section(company.name) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Баланс компании")
                            .font(.subheadline)
                        Text(company.adminEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("₽\(Int.random(in: 5000...25000))")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Программы лояльности")
                    Spacer()
                    Text("\(company.loyaltyPrograms.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Последний платеж")
                    Spacer()
                    Text("\(Int.random(in: 1...30)) мая 2025")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func companyBillingContent(for company: Company) -> some View {
        Group {
            Section("Баланс \(company.name)") {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Доступный баланс")
                            .font(.headline)
                        Text("Последнее пополнение: 12 мая 2025")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("₽\(Int.random(in: 10000...50000))")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }
                .padding(.vertical, 8)
            }
            
            Section("Статистика расходов") {
                HStack {
                    Text("За текущий месяц")
                    Spacer()
                    Text("₽\(Int.random(in: 5000...15000))")
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Средний расход в день")
                    Spacer()
                    Text("₽\(Int.random(in: 200...800))")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Активные программы")
                    Spacer()
                    Text("\(company.loyaltyPrograms.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("История транзакций") {
                ForEach(1...4, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(index % 2 == 0 ? "Начисление баллов" : "Списание за API")
                                .font(.subheadline)
                            Text("\(25 - index * 2) мая 2025")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(index % 2 == 0 ? "+₽\(Int.random(in: 100...500))" : "-₽\(Int.random(in: 50...200))")
                            .font(.subheadline.bold())
                            .foregroundColor(index % 2 == 0 ? .green : .red)
                    }
                }
            }
        }
    }
}

// MARK: - Top Up View

struct TopUpView: View {
    let selectedCompany: Company?
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var selectedMethod = "Банковская карта"
    @State private var showingSuccess = false
    
    let paymentMethods = ["Банковская карта", "Банковский перевод", "Электронные деньги", "Криптовалюта"]
    let quickAmounts = [5000, 10000, 25000, 50000, 100000]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Пополнение баланса")
                                .font(.headline)
                            if let company = selectedCompany {
                                Text("Для компании: \(company.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Общий баланс")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Сумма пополнения") {
                    HStack {
                        Text("₽")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        TextField("0", text: $amount)
                            .font(.title2)
                            .keyboardType(.numberPad)
                    }
                    .padding(.vertical, 4)
                    
                    // Quick amount buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(quickAmounts, id: \.self) { quickAmount in
                            Button("₽\(quickAmount.formatted())") {
                                amount = String(quickAmount)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Способ оплаты") {
                    Picker("Способ оплаты", selection: $selectedMethod) {
                        ForEach(paymentMethods, id: \.self) { method in
                            HStack {
                                Image(systemName: iconForPaymentMethod(method))
                                Text(method)
                            }
                            .tag(method)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if !amount.isEmpty, let amountValue = Int(amount), amountValue > 0 {
                    Section("Итого к оплате") {
                        HStack {
                            Text("Сумма")
                            Spacer()
                            Text("₽\(amountValue.formatted())")
                        }
                        
                        HStack {
                            Text("Комиссия")
                            Spacer()
                            Text("₽\(Int(Double(amountValue) * 0.02).formatted())")
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("К списанию")
                                .font(.headline)
                            Spacer()
                            Text("₽\(Int(Double(amountValue) * 1.02).formatted())")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Пополнение")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Пополнить") {
                        performTopUp()
                    }
                    .disabled(amount.isEmpty || Int(amount) == nil || Int(amount) ?? 0 <= 0)
                }
            }
            .alert("Успешно!", isPresented: $showingSuccess) {
                Button("ОК") {
                    dismiss()
                }
            } message: {
                Text("Баланс пополнен на ₽\(amount). Средства будут зачислены в течение 15 минут.")
            }
        }
    }
    
    private func iconForPaymentMethod(_ method: String) -> String {
        switch method {
        case "Банковская карта":
            return "creditcard"
        case "Банковский перевод":
            return "building.columns"
        case "Электронные деньги":
            return "wallet.pass"
        case "Криптовалюта":
            return "bitcoinsign.circle"
        default:
            return "creditcard"
        }
    }
    
    private func performTopUp() {
        // В реальном приложении здесь будет интеграция с платежной системой
        showingSuccess = true
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
    
    private var featureAnnouncementBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Новый Apple Wallet конструктор!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Создавайте профессиональные пассы")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Попробовать") {
                    selectedTab = 1 // Переключаемся на вкладку Apple Wallet
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
        .background(.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.blue.opacity(0.3), lineWidth: 1)
        )
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
    @State private var showingProgramDetails = false
    @State private var showingEditProgram = false
    
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
                    Button("Аналитика и статистика") {
                        showingProgramDetails = true
                    }
                    Button("Редактировать программу") {
                        showingEditProgram = true
                    }
                    Divider()
                    Button("Посмотреть ссылку") {
                        showInviteLink(program)
                    }
                    Button("Копировать ссылку") {
                        copyToClipboard(program.inviteLink)
                    }
                    Button("Предпросмотр карты") {
                        showCardPreview(program)
                    }
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
        .onTapGesture {
            showingProgramDetails = true
        }
        .sheet(isPresented: $showingInviteLink) {
            InviteLinkView(program: program)
        }
        .sheet(isPresented: $showingCardPreview) {
            CardPreviewView(program: program)
        }
        .sheet(isPresented: $showingProgramDetails) {
            ProgramAnalyticsView(program: program)
        }
        .sheet(isPresented: $showingEditProgram) {
            EditLoyaltyProgramView(program: program)
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
    @State private var showingRegistration = false
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
                            showingRegistration = true
                        } label: {
                            Label("Протестировать регистрацию", systemImage: "person.badge.plus")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green.opacity(0.2))
                                .foregroundColor(.green)
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
            .sheet(isPresented: $showingRegistration) {
                CustomerRegistrationView(program: program)
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
    @State private var selectedCompany: Company?
    @State private var companies: [Company] = [
        Company(name: "Кофейня 'Дом'", logo: nil, adminEmail: "admin@coffee.com"),
        Company(name: "Демо-компания", logo: nil, adminEmail: "demo@example.com")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Company Selector
                companySelector
                
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
    
    private var companySelector: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Компания:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Picker("Выберите компанию", selection: $selectedCompany) {
                Text("Все компании").tag(Company?.none)
                ForEach(companies) { company in
                    Text(company.name).tag(Company?.some(company))
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            if let selectedCompany = selectedCompany {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.blue)
                    Text(selectedCompany.name)
                        .font(.headline)
                    Spacer()
                    if !selectedCompany.loyaltyPrograms.isEmpty {
                        Text("\(selectedCompany.loyaltyPrograms.count) программ")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            
            Divider()
        }
        .background(.gray.opacity(0.05))
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
    @State private var showingEditPass = false
    @State private var searchText = ""
    @State private var selectedPassType: PassType? = nil
    @State private var selectedCompany: String? = nil
    @State private var quickPassType: PassType? = nil
    @State private var showingQuickCreator = false
    
    // Filter options
    let passTypes: [PassType] = [.storeCard, .coupon, .eventTicket, .boardingPass, .generic]
    let companies = ["Все компании", "Кофейня 'Дом'", "Демо-компания", "SportClub", "BeautySalon"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filters Section
                filtersSection
                
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
            }
            .navigationTitle("Управление пассами")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreatePass = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                            Text("Создать")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.blue)
                        )
                    }
                }
            }
            .sheet(isPresented: $showingCreatePass) {
                PassBuilderModeSelector(passKitManager: passKitManager)
            }
            .sheet(isPresented: $showingQuickCreator) {
                QuickPassCreatorForType(passKitManager: passKitManager, passType: quickPassType)
            }
            .sheet(isPresented: $showingPassPreview) {
                if let pass = selectedPass {
                    PassPreviewView(passData: pass, passKitManager: passKitManager)
                }
            }
            .sheet(isPresented: $showingEditPass) {
                if let pass = selectedPass {
                    EditPassView(passData: pass, passKitManager: passKitManager)
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
                if !filteredPasses.isEmpty {
                    Text("\(filteredPasses.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            if filteredPasses.isEmpty {
                if passKitManager.passes.isEmpty {
                    emptyPassesView
                } else {
                    emptyFilteredView
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredPasses) { pass in
                        PassCardView(passData: pass) {
                            selectedPass = pass
                            showingPassPreview = true
                        }
                        .contextMenu {
                            Button("Просмотр") {
                                selectedPass = pass
                                showingPassPreview = true
                            }
                            
                            Button("Редактировать") {
                                selectedPass = pass
                                showingEditPass = true
                            }
                            
                            Divider()
                            
                            Button("Дублировать", role: .none) {
                                // Логика дублирования пасса
                            }
                            
                            Button("Удалить", role: .destructive) {
                                // Логика удаления пасса
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptyPassesView: some View {
        VStack(spacing: 24) {
            // Feature Announcement
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Конструктор")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Режим помощник")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.blue)
                }
                
                Text("Создавайте Apple Wallet пассы за несколько простых шагов с новым интуитивным интерфейсом")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // CTA Button
            Button {
                showingCreatePass = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                    Text("Конструктор")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        )
    }
    
    private var emptyFilteredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Ничего не найдено")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Попробуйте изменить фильтры или условия поиска")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                selectedPassType = nil
                selectedCompany = nil
                searchText = ""
            } label: {
                Label("Очистить фильтры", systemImage: "xmark.circle")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(.blue.opacity(0.1))
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
    
    private var filtersSection: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Поиск пассов...", text: $searchText)
            }
            .padding(10)
            .background(.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Filter chips
            HStack {
                Text("Фильтры:")
                    .font(.subheadline.bold())
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Pass Type Filter
                    Menu {
                        Button("Все типы") {
                            selectedPassType = nil
                        }
                        ForEach(passTypes, id: \.self) { type in
                            Button(type.displayName) {
                                selectedPassType = type
                            }
                        }
                    } label: {
                        FilterChip(
                            title: selectedPassType?.displayName ?? "Тип пасса",
                            isSelected: selectedPassType != nil
                        )
                    }
                    
                    // Company Filter
                    Menu {
                        ForEach(companies, id: \.self) { company in
                            Button(company) {
                                selectedCompany = company == "Все компании" ? nil : company
                            }
                        }
                    } label: {
                        FilterChip(
                            title: selectedCompany ?? "Компания",
                            isSelected: selectedCompany != nil
                        )
                    }
                    
                    // Clear filters
                    if selectedPassType != nil || selectedCompany != nil || !searchText.isEmpty {
                        Button("Очистить") {
                            selectedPassType = nil
                            selectedCompany = nil
                            searchText = ""
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.red.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
            
            // Results count
            HStack {
                Text("Найдено: \(filteredPasses.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Divider()
        }
        .padding()
        .background(.white)
    }
    
    private var filteredPasses: [WalletPassData] {
        var passes = passKitManager.passes
        
        // Filter by search text
        if !searchText.isEmpty {
            passes = passes.filter { pass in
                pass.organizationName.localizedCaseInsensitiveContains(searchText) ||
                pass.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by pass type
        if let selectedType = selectedPassType {
            passes = passes.filter { $0.passType == selectedType }
        }
        
        // Filter by company
        if let selectedCompany = selectedCompany {
            passes = passes.filter { $0.organizationName == selectedCompany }
        }
        
        return passes
    }
    
    private func createQuickPass(type: PassType) {
        // Создание быстрого пасса с предустановленными настройками
        quickPassType = type
        showingQuickCreator = true
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

// MARK: - Quick Pass Creation

struct QuickPassTemplate {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let passType: PassType
}

struct PassBuilderModeSelector: View {
    @ObservedObject var passKitManager: PassKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: BuilderMode = .quick
    @State private var showingQuickMode = false
    @State private var showingAdvancedMode = false
    
    enum BuilderMode {
        case quick, advanced
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header - Enhanced Apple Style
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .blue.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                    
                    VStack(spacing: 8) {
                        Text("Конструктор")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        
                        Text("Режим помощник - выберите режим создания")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 30)
                
                // Mode Cards
                VStack(spacing: 20) {
                    ModeCard(
                        title: "⚡ Быстрое создание",
                        description: "Создайте пасс за 3 простых шага в режиме помощник",
                        icon: "bolt.fill",
                        color: .blue,
                        features: ["3 шага", "Готовые шаблоны", "Мгновенный результат", "NEW"],
                        isSelected: selectedMode == .quick
                    ) {
                        selectedMode = .quick
                    }
                    
                    ModeCard(
                        title: "🔧 Продвинутый режим",
                        description: "Полная настройка всех элементов",
                        icon: "gearshape.fill",
                        color: .orange,
                        features: ["5 шагов", "Drag & Drop", "Все опции"],
                        isSelected: selectedMode == .advanced
                    ) {
                        selectedMode = .advanced
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button {
                    if selectedMode == .quick {
                        showingQuickMode = true
                    } else {
                        showingAdvancedMode = true
                    }
                } label: {
                    HStack {
                        Image(systemName: selectedMode == .quick ? "bolt.fill" : "gearshape.fill")
                        Text("Продолжить")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedMode == .quick ? .blue : .orange)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingQuickMode) {
                QuickPassCreator(passKitManager: passKitManager)
            }
            .fullScreenCover(isPresented: $showingAdvancedMode) {
                PassBuilderView(passKitManager: passKitManager)
            }
        }
    }
}

struct ModeCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let features: [String]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Enhanced Icon with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.2), color.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Spacer()
                    
                    // Enhanced selection indicator
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(color)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(isSelected ? 1.0 : 0.8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Enhanced Features with better styling
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(features, id: \.self) { feature in
                            HStack(spacing: 4) {
                                if feature == "NEW" {
                                    Image(systemName: "sparkles")
                                        .font(.caption2)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2)
                                }
                                
                                Text(feature)
                                    .font(.caption.weight(.medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(feature == "NEW" ? .green.opacity(0.1) : color.opacity(0.1))
                            )
                            .foregroundColor(feature == "NEW" ? .green : color)
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(isSelected ? 0.15 : 0.08), radius: isSelected ? 20 : 10, x: 0, y: isSelected ? 8 : 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? [color.opacity(0.6), color.opacity(0.2)] : [.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct QuickPassCreator: View {
    @ObservedObject var passKitManager: PassKitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTemplate: QuickPassTemplate?
    @State private var organizationName = ""
    @State private var description = ""
    @State private var selectedColor = Color.blue
    @State private var showingPreview = false
    
    // Quick templates (simplified)
    let quickTemplates: [QuickPassTemplate] = [
        QuickPassTemplate(
            id: "loyalty",
            name: "Карта лояльности",
            description: "Программа лояльности",
            icon: "creditcard.fill",
            color: .blue,
            passType: .storeCard
        ),
        QuickPassTemplate(
            id: "coupon",
            name: "Купон скидки",
            description: "Скидочный купон",
            icon: "tag.fill",
            color: .orange,
            passType: .coupon
        ),
        QuickPassTemplate(
            id: "ticket",
            name: "Билет",
            description: "Билет на мероприятие",
            icon: "ticket.fill",
            color: .green,
            passType: .eventTicket
        ),
        QuickPassTemplate(
            id: "membership",
            name: "Членская карта",
            description: "Карта участника",
            icon: "person.card.fill",
            color: .purple,
            passType: .generic
        )
    ]
    
    let quickColors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Быстрое создание")
                            .font(.title.bold())
                        
                        Text("3 простых шага до готового пасса")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 32) {
                        // Step 1: Template Selection
                        QuickStepCard(
                            stepNumber: 1,
                            title: "Выберите тип пасса",
                            isCompleted: selectedTemplate != nil
                        ) {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(quickTemplates, id: \.id) { template in
                                    QuickTemplateButton(
                                        template: template,
                                        isSelected: selectedTemplate?.id == template.id
                                    ) {
                                        selectedTemplate = template
                                        selectedColor = template.color
                                        
                                        // Haptic feedback
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                    }
                                }
                            }
                        }
                        
                        // Step 2: Basic Info
                        QuickStepCard(
                            stepNumber: 2,
                            title: "Основная информация",
                            isCompleted: !organizationName.isEmpty
                        ) {
                            VStack(spacing: 16) {
                                TextField("Название организации", text: $organizationName)
                                    .font(.headline)
                                    .padding()
                                    .background(.gray.opacity(0.1))
                                    .cornerRadius(12)
                                
                                TextField("Описание (необязательно)", text: $description, axis: .vertical)
                                    .lineLimit(2...4)
                                    .padding()
                                    .background(.gray.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Step 3: Color Selection
                        QuickStepCard(
                            stepNumber: 3,
                            title: "Выберите цвет",
                            isCompleted: true
                        ) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(quickColors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Circle()
                                                .stroke(.white, lineWidth: selectedColor == color ? 4 : 0)
                                        )
                                        .shadow(color: selectedColor == color ? color.opacity(0.5) : .clear, radius: 8)
                                        .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3), value: selectedColor)
                                        .onTapGesture {
                                            selectedColor = color
                                            
                                            // Haptic feedback
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                            impactFeedback.impactOccurred()
                                        }
                                }
                            }
                        }
                        
                        // Live Preview
                        if selectedTemplate != nil && !organizationName.isEmpty {
                            VStack(spacing: 12) {
                                Text("Предпросмотр")
                                    .font(.headline)
                                
                                QuickPassPreview(
                                    template: selectedTemplate!,
                                    organizationName: organizationName,
                                    description: description,
                                    color: selectedColor
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                            .animation(.spring(response: 0.5), value: organizationName)
                            .animation(.spring(response: 0.5), value: selectedColor)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Назад") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Продвинутый") {
                        // Switch to advanced mode
                    }
                    .font(.caption)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Create Button
                Button {
                    createQuickPass()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Создать пасс")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canCreatePass ? selectedColor : .gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .disabled(!canCreatePass)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
    }
    
    var canCreatePass: Bool {
        selectedTemplate != nil && !organizationName.isEmpty
    }
    
    func createQuickPass() {
        guard let template = selectedTemplate else { return }
        
        // Create pass with minimal configuration
        let passData = WalletPassData(
            passType: template.passType,
            organizationName: organizationName,
            description: description.isEmpty ? template.description : description,
            serialNumber: "LY\(String(format: "%06d", Int.random(in: 100000...999999)))"
        )
        
        // Add to PassKit manager
        passKitManager.passes.append(passData)
        
        // Success feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismiss()
    }
}

struct QuickStepCard<Content: View>: View {
    let stepNumber: Int
    let title: String
    let isCompleted: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Step number
                ZStack {
                    Circle()
                        .fill(isCompleted ? .green : .blue)
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    } else {
                        Text("\(stepNumber)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                }
                
                Text(title)
                    .font(.headline)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct QuickTemplateButton: View {
    let template: QuickPassTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(template.color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: template.icon)
                        .font(.title)
                        .foregroundColor(template.color)
                }
                
                VStack(spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? template.color.opacity(0.1) : .gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? template.color : .gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(16)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

struct QuickPassPreview: View {
    let template: QuickPassTemplate
    let organizationName: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            // Top section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(organizationName)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    if !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text(template.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                Image(systemName: template.icon)
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding()
            .background(color.gradient)
            
            // Bottom section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Номер карты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("LY001234")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // QR Code placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(.black)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "qrcode")
                            .foregroundColor(.white)
                            .font(.title3)
                    )
            }
            .padding()
            .background(.white)
        }
        .frame(width: 300, height: 180)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 8)
    }
}

struct PassBuilderView: View {
    @ObservedObject var passKitManager: PassKitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var selectedTemplate: PassTemplate?
    @State private var passData = PassCreationData()
    @State private var showingPreview = false
    @State private var showFullSizePreview = false
    @State private var isCreatingPass = false
    @State private var showingRegistrationFlow = false
    @State private var createdPassURL: String?
    @State private var showingPointsManager = false
    @State private var showingImagePicker = false
    @State private var selectedLogoImage: UIImage?
    
    // Available templates
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
                PassFieldTemplate(key: "level", label: "Уровень", placeholder: "Базовый"),
                PassFieldTemplate(key: "memberID", label: "ID участника", placeholder: "LY001234"),
                PassFieldTemplate(key: "balance", label: "Баланс", placeholder: "₽1,500"),
                PassFieldTemplate(key: "expiryDate", label: "Действует до", placeholder: "31.12.2025"),
                PassFieldTemplate(key: "website", label: "Веб-сайт", placeholder: "company.com"),
                PassFieldTemplate(key: "phone", label: "Телефон", placeholder: "+7 999 123 45 67"),
                PassFieldTemplate(key: "email", label: "Email", placeholder: "info@company.com"),
                PassFieldTemplate(key: "location", label: "Адрес", placeholder: "Москва, ул. Примерная 123"),
                PassFieldTemplate(key: "socialMedia", label: "Instagram", placeholder: "@company_official"),
                PassFieldTemplate(key: "barcode", label: "Штрих-код", placeholder: "123456789012")
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
            .sheet(isPresented: $showFullSizePreview) {
                if let template = selectedTemplate {
                    FullSizePassPreview(template: template, passData: passData)
                }
            }
            .sheet(isPresented: $showingRegistrationFlow) {
                if let passURL = createdPassURL {
                    RegistrationFlowView(passURL: passURL, onDismiss: {
                        showingRegistrationFlow = false
                        dismiss()
                    })
                }
            }
            .sheet(isPresented: $showingPointsManager) {
                PointsManagementView(pointsManager: PointsManager())
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedLogoImage) {
                    if let image = selectedLogoImage {
                        passData.logoImage = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() ?? ""
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
                            if let selectedImage = selectedLogoImage {
                                VStack(spacing: 8) {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 60)
                                        .cornerRadius(8)
                                    
                                    HStack {
                                        Button("Изменить") {
                                            showingImagePicker = true
                                        }
                                        .foregroundColor(.blue)
                                        
                                        Spacer()
                                        
                                        Button("Удалить") {
                                            selectedLogoImage = nil
                                            passData.logoImage = ""
                                        }
                                        .foregroundColor(.red)
                                    }
                                    .font(.caption)
                                }
                                .padding()
                                .background(.gray.opacity(0.05))
                                .cornerRadius(12)
                            } else {
                                Button {
                                    showingImagePicker = true
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
                // Interactive Final Preview
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Финальный предпросмотр")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Button {
                            // Toggle edit mode
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                Text("Редактировать")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Так ваш пасс будет выглядеть в Apple Wallet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if let template = selectedTemplate {
                        VStack(spacing: 20) {
                            // Interactive Editable Preview with Enhanced Animations
                            InteractiveEditablePassPreview(
                                template: template, 
                                passData: $passData,
                                onFieldEdit: { field, newValue in
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        updateFieldValue(key: field.key, value: newValue, label: field.label)
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .slide),
                                removal: .scale(scale: 1.1).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: passData.organizationName)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: passData.passDescription)
                            
                            // Drag & Drop Layout Editor
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "hand.draw")
                                        .foregroundColor(.blue)
                                    Text("Редактор расположения полей")
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text("Перетащите поля")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                DraggableFieldContainer(
                                    template: template,
                                    passData: $passData,
                                    onFieldEdit: { field, newValue in
                                        updateFieldValue(key: field.key, value: newValue, label: field.label)
                                    }
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.gray.opacity(0.05))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                
                                HStack {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Text("Нажмите и перетащите поля для изменения их расположения")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Quick Actions
                VStack(spacing: 16) {
                    Text("Быстрые действия")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionCard(
                            title: "Реальный размер",
                            icon: "eye.fill",
                            color: .blue
                        ) {
                            showFullSizePreview = true
                        }
                        
                        QuickActionCard(
                            title: "Тестовые данные",
                            icon: "testtube.2",
                            color: .orange
                        ) {
                            fillWithTestData()
                        }
                        
                        QuickActionCard(
                            title: "Очистить поля",
                            icon: "eraser.fill",
                            color: .red
                        ) {
                            clearAllFields()
                        }
                        
                        QuickActionCard(
                            title: "Копировать настройки",
                            icon: "doc.on.doc.fill",
                            color: .green
                        ) {
                            // Copy settings action
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Pass Statistics
                VStack(alignment: .leading, spacing: 16) {
                    Text("Статистика пасса")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(
                            title: "Заполнено полей",
                            value: "\(passData.customFields.filter { !$0.value.isEmpty }.count)/\(selectedTemplate?.presetFields.count ?? 0)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Символов",
                            value: "\(passData.customFields.reduce(0) { $0 + $1.value.count })",
                            icon: "textformat.abc",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Готовность",
                            value: "\(Int(completionPercentage))%",
                            icon: "chart.pie.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Create Button with Progress
                VStack(spacing: 12) {
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Готовность к созданию")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(Int(completionPercentage))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(.gray.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * (completionPercentage / 100), height: 8)
                                    .cornerRadius(4)
                                    .animation(.easeInOut(duration: 0.5), value: completionPercentage)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal)
                    
                    // Create Button
                    Button {
                        createPass()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: isCreatingPass ? "hourglass" : (isFormValid ? "wallet.pass.fill" : "exclamationmark.triangle.fill"))
                                .font(.title3)
                                .scaleEffect(isCreatingPass ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.6).repeatForever(), value: isCreatingPass)
                            
                            Text(isCreatingPass ? "Создание пасса..." : (isFormValid ? "Создать пасс" : "Заполните обязательные поля"))
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: isCreatingPass ? [.green, .blue] : (isFormValid ? [.blue, .purple] : [.gray, .gray.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(radius: isFormValid ? 8 : 4)
                        .scaleEffect(isFormValid ? 1.0 : 0.98)
                        .animation(.spring(response: 0.3), value: isFormValid)
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid || isCreatingPass)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Helper Properties and Computed Values
    
    private var completionPercentage: Double {
        guard let template = selectedTemplate else { return 0 }
        
        let requiredFieldsCount = template.presetFields.count
        let filledFieldsCount = passData.customFields.filter { !$0.value.isEmpty }.count
        let organizationFilled = !passData.organizationName.isEmpty
        let descriptionFilled = !passData.passDescription.isEmpty
        
        let totalRequired = requiredFieldsCount + 2 // org name + description
        let totalFilled = filledFieldsCount + (organizationFilled ? 1 : 0) + (descriptionFilled ? 1 : 0)
        
        return min(100, Double(totalFilled) / Double(totalRequired) * 100)
    }
    
    private func fillWithTestData() {
        guard let template = selectedTemplate else { return }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            passData.organizationName = "Кофейня 'Утро'"
            passData.passDescription = "Карта постоянного клиента"
            
            // Fill with realistic test data based on field type
            for fieldTemplate in template.presetFields {
                let testValue: String
                switch fieldTemplate.key {
                case "member", "customerName":
                    testValue = "Иван Петров"
                case "points":
                    testValue = "1250"
                case "level":
                    testValue = "Золотой"
                case "memberID":
                    testValue = "LY001234"
                case "expiryDate":
                    testValue = "31.12.2025"
                case "balance":
                    testValue = "₽850"
                case "website":
                    testValue = "loyaltyclub.ru"
                case "phone":
                    testValue = "+7 999 123 45 67"
                case "email":
                    testValue = "info@loyaltyclub.ru"
                case "location":
                    testValue = "Москва, ул. Тверская 10"
                case "socialMedia":
                    testValue = "@loyaltyclub_official"
                case "barcode":
                    testValue = "4607812345678"
                case "discount":
                    testValue = "15%"
                case "expires":
                    testValue = "31.12.2025"
                case "code":
                    testValue = "SAVE15"
                case "event":
                    testValue = "Концерт группы XYZ"
                case "date":
                    testValue = "25 июня 2025, 19:00"
                case "seat":
                    testValue = "Партер, ряд 5, место 12"
                case "passenger":
                    testValue = "Петров И.И."
                case "flight":
                    testValue = "SU 1234"
                case "gate":
                    testValue = "A12"
                case "id":
                    testValue = "123456"
                case "status":
                    testValue = "Активен"
                case "amount":
                    testValue = "5,000 ₽"
                default:
                    testValue = fieldTemplate.placeholder
                }
                updateFieldValue(key: fieldTemplate.key, value: testValue, label: fieldTemplate.label)
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func clearAllFields() {
        withAnimation(.easeInOut(duration: 0.3)) {
            passData.customFields.removeAll()
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
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

// MARK: - Template Components

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

struct DraggableFieldContainer: View {
    let template: PassTemplate
    @Binding var passData: PassCreationData
    let onFieldEdit: (PassFieldTemplate, String) -> Void
    
    @State private var draggedField: PassFieldTemplate?
    @State private var fieldPositions: [String: CGPoint] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Pass Shape
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [passData.backgroundColor, passData.backgroundColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                
                // Draggable Fields
                ForEach(template.presetFields, id: \.key) { fieldTemplate in
                    DraggableFieldView(
                        fieldTemplate: fieldTemplate,
                        currentValue: getFieldValue(for: fieldTemplate.key),
                        position: fieldPositions[fieldTemplate.key] ?? getDefaultPosition(for: fieldTemplate, in: geometry.size),
                        isDragging: draggedField?.key == fieldTemplate.key,
                        onEdit: { newValue in
                            onFieldEdit(fieldTemplate, newValue)
                        },
                        onDragChanged: { value in
                            fieldPositions[fieldTemplate.key] = value.location
                        },
                        onDragEnded: { value in
                            draggedField = nil
                            fieldPositions[fieldTemplate.key] = value.location
                        }
                    )
                    .onTapGesture {
                        draggedField = fieldTemplate
                    }
                }
            }
        }
        .frame(height: 200)
        .onAppear {
            initializeFieldPositions()
        }
    }
    
    private func getFieldValue(for key: String) -> String {
        return passData.customFields.first(where: { $0.key == key })?.value ?? ""
    }
    
    private func getDefaultPosition(for field: PassFieldTemplate, in size: CGSize) -> CGPoint {
        let spacing: CGFloat = 30
        let startY: CGFloat = 60
        
        switch field.key {
        case "customerName": return CGPoint(x: 20, y: startY)
        case "points": return CGPoint(x: size.width - 100, y: startY)
        case "level": return CGPoint(x: 20, y: startY + spacing)
        case "memberID": return CGPoint(x: size.width - 100, y: startY + spacing)
        case "expiryDate": return CGPoint(x: 20, y: startY + spacing * 2)
        case "balance": return CGPoint(x: size.width - 100, y: startY + spacing * 2)
        default: return CGPoint(x: 20, y: startY + spacing * 3)
        }
    }
    
    private func initializeFieldPositions() {
        for field in template.presetFields {
            if fieldPositions[field.key] == nil {
                fieldPositions[field.key] = getDefaultPosition(for: field, in: CGSize(width: 350, height: 200))
            }
        }
    }
}

struct DraggableFieldView: View {
    let fieldTemplate: PassFieldTemplate
    let currentValue: String
    let position: CGPoint
    let isDragging: Bool
    let onEdit: (String) -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: (DragGesture.Value) -> Void
    
    @State private var isEditing = false
    @State private var editValue = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(fieldTemplate.label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            if isEditing {
                TextField(fieldTemplate.placeholder, text: $editValue)
                    .focused($isFocused)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                    .frame(width: 120)
                    .onSubmit {
                        onEdit(editValue)
                        isEditing = false
                    }
                    .onAppear {
                        editValue = currentValue
                        isFocused = true
                    }
            } else {
                Text(currentValue.isEmpty ? fieldTemplate.placeholder : currentValue)
                    .font(.caption.bold())
                    .foregroundColor(currentValue.isEmpty ? .white.opacity(0.5) : .white)
                    .italic(currentValue.isEmpty)
                    .frame(width: 120, alignment: .leading)
                    .onTapGesture {
                        isEditing = true
                    }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(isDragging ? 0.3 : 0.15))
                .shadow(color: .black.opacity(isDragging ? 0.3 : 0.1), radius: isDragging ? 8 : 4)
        )
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .position(position)
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
        .animation(.spring(response: 0.3), value: isDragging)
    }
}

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
        case "member", "customerName": return "person.fill"
        case "points": return "star.fill"
        case "level": return "crown.fill"
        case "memberID": return "number"
        case "expiryDate": return "calendar"
        case "balance": return "dollarsign.circle.fill"
        case "website": return "globe"
        case "phone": return "phone.fill"
        case "email": return "envelope.fill"
        case "location": return "location.fill"
        case "socialMedia": return "camera.fill"
        case "barcode": return "barcode"
        case "discount": return "percent"
        case "expires": return "clock.fill"
        case "code": return "qrcode"
        case "event": return "calendar.badge.exclamationmark"
        case "date": return "calendar.circle"
        case "seat": return "chair.fill"
        case "passenger": return "person.circle"
        case "flight": return "airplane"
        case "gate": return "door.left.hand.open"
        case "id": return "creditcard"
        case "status": return "checkmark.shield"
        case "amount": return "banknote"
        default: return "text.alignleft"
        }
    }
    
    private func getFieldColor() -> Color {
        switch fieldTemplate.key {
        case "member", "customerName": return .blue
        case "points": return .orange
        case "level": return .purple
        case "memberID": return .green
        case "expiryDate": return .red
        case "balance": return .mint
        case "website": return .blue
        case "phone": return .green
        case "email": return .blue
        case "location": return .red
        case "socialMedia": return .purple
        case "barcode": return .black
        case "discount": return .orange
        case "expires": return .red
        case "code": return .blue
        case "event": return .purple
        case "date": return .blue
        case "seat": return .brown
        case "passenger": return .blue
        case "flight": return .blue
        case "gate": return .green
        case "id": return .gray
        case "status": return .green
        case "amount": return .green
        default: return .gray
        }
    }
}

// MARK: - Interactive Editable Pass Preview

struct InteractiveEditablePassPreview: View {
    let template: PassTemplate
    @Binding var passData: PassCreationData
    let onFieldEdit: (PassFieldTemplate, String) -> Void
    
    @State private var isEditMode = false
    @State private var editingField: String? = nil
    @State private var tempFieldValues: [String: String] = [:]
    
    var body: some View {
        VStack(spacing: 20) {
            // Pass Preview with Edit Capability
            VStack(alignment: .leading, spacing: 16) {
                // Header Section - Editable
                HStack {
                    Image(systemName: template.icon)
                        .foregroundColor(.white)
                        .font(.title)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(.white.opacity(0.2)))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        EditableTextField(
                            text: passData.organizationName.isEmpty ? "Название организации" : passData.organizationName,
                            placeholder: "Название организации",
                            isEditing: editingField == "organization"
                        ) { newValue in
                            passData.organizationName = newValue
                            editingField = nil
                        } onEdit: {
                            editingField = "organization"
                        }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        
                        EditableTextField(
                            text: passData.passDescription.isEmpty ? "Описание пасса" : passData.passDescription,
                            placeholder: "Описание пасса",
                            isEditing: editingField == "description"
                        ) { newValue in
                            passData.passDescription = newValue
                            editingField = nil
                        } onEdit: {
                            editingField = "description"
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Interactive QR Code with Animation
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.1), radius: 2)
                        
                        VStack(spacing: 2) {
                            ForEach(0..<4) { row in
                                HStack(spacing: 2) {
                                    ForEach(0..<4) { col in
                                        Rectangle()
                                            .fill(.black)
                                            .frame(width: 4, height: 4)
                                            .opacity(Double.random(in: 0.3...1.0))
                                            .animation(
                                                .easeInOut(duration: Double.random(in: 1.5...3.0))
                                                .repeatForever(autoreverses: true),
                                                value: passData.customFields.count
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                
                Divider()
                    .background(.white.opacity(0.4))
                
                // Editable Fields Section
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(template.presetFields, id: \.key) { fieldTemplate in
                        let currentValue = getFieldValue(for: fieldTemplate.key)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(.white.opacity(currentValue.isEmpty ? 0.3 : 0.8))
                                        .frame(width: 6, height: 6)
                                        .scaleEffect(currentValue.isEmpty ? 1.0 : 1.3)
                                        .animation(.easeInOut(duration: 0.3), value: currentValue)
                                    
                                    Text("\(fieldTemplate.label):")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                if editingField == fieldTemplate.key {
                                    HStack(spacing: 8) {
                                        Button("✓") {
                                            if let tempValue = tempFieldValues[fieldTemplate.key] {
                                                onFieldEdit(fieldTemplate, tempValue)
                                            }
                                            editingField = nil
                                            tempFieldValues.removeValue(forKey: fieldTemplate.key)
                                        }
                                        .foregroundColor(.green)
                                        .font(.caption.bold())
                                        
                                        Button("✕") {
                                            editingField = nil
                                            tempFieldValues.removeValue(forKey: fieldTemplate.key)
                                        }
                                        .foregroundColor(.red)
                                        .font(.caption.bold())
                                    }
                                }
                            }
                            
                            // Editable Field Value
                            EditableFieldValue(
                                fieldTemplate: fieldTemplate,
                                currentValue: currentValue,
                                isEditing: editingField == fieldTemplate.key,
                                tempValue: Binding(
                                    get: { tempFieldValues[fieldTemplate.key] ?? currentValue },
                                    set: { tempFieldValues[fieldTemplate.key] = $0 }
                                )
                            ) {
                                editingField = fieldTemplate.key
                                tempFieldValues[fieldTemplate.key] = currentValue
                            }
                        }
                    }
                }
                
                // Pass Footer
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Серийный номер")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text(generateDisplaySerialNumber())
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Создан")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                        Text(Date(), style: .date)
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [passData.backgroundColor, passData.backgroundColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: passData.backgroundColor.opacity(0.4), radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(1.02)
            .onTapGesture {
                editingField = nil
                tempFieldValues.removeAll()
            }
            
            // Edit Instructions
            if editingField == nil {
                HStack {
                    Image(systemName: "hand.tap")
                        .foregroundColor(.blue)
                    Text("Нажмите на любое поле для редактирования")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .opacity(0.8)
            } else {
                HStack {
                    Image(systemName: "keyboard")
                        .foregroundColor(.blue)
                    Text("Введите новое значение и нажмите ✓ для сохранения")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getFieldValue(for key: String) -> String {
        return passData.customFields.first(where: { $0.key == key })?.value ?? ""
    }
    
    private func generateDisplaySerialNumber() -> String {
        let prefix = template.passType.rawValue.prefix(2).uppercased()
        return "\(prefix)••••••"
    }
}

struct EditableTextField: View {
    let text: String
    let placeholder: String
    let isEditing: Bool
    let onSave: (String) -> Void
    let onEdit: () -> Void
    
    @State private var editText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Group {
            if isEditing {
                TextField(placeholder, text: $editText)
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSave(editText)
                    }
                    .onAppear {
                        editText = text == placeholder ? "" : text
                        isFocused = true
                    }
            } else {
                Text(text)
                    .onTapGesture {
                        onEdit()
                    }
                    .overlay(
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                    )
            }
        }
    }
}

struct EditableFieldValue: View {
    let fieldTemplate: PassFieldTemplate
    let currentValue: String
    let isEditing: Bool
    @Binding var tempValue: String
    let onEdit: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            if isEditing {
                TextField(fieldTemplate.placeholder, text: $tempValue)
                    .focused($isFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.9))
                    .cornerRadius(6)
                    .foregroundColor(.black)
                    .onAppear {
                        isFocused = true
                    }
            } else {
                Text(currentValue.isEmpty ? fieldTemplate.placeholder : currentValue)
                    .font(.subheadline.bold())
                    .foregroundColor(currentValue.isEmpty ? .white.opacity(0.5) : .white)
                    .italic(currentValue.isEmpty)
                    .onTapGesture {
                        onEdit()
                    }
                
                Spacer()
                
                if currentValue.isEmpty {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                        .onTapGesture {
                            onEdit()
                        }
                } else {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                        .onTapGesture {
                            onEdit()
                        }
                }
            }
        }
    }
}

// MARK: - Quick Action Cards

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var animateIcon = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                animateIcon = true
            }
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateIcon = false
                }
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .scaleEffect(animateIcon ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateIcon)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title2)
                        .scaleEffect(animateIcon ? 1.2 : 1.0)
                        .rotationEffect(.degrees(animateIcon ? 360 : 0))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateIcon)
                    
                    // Ripple Effect
                    if animateIcon {
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .scaleEffect(animateIcon ? 2.0 : 1.0)
                            .opacity(animateIcon ? 0 : 1)
                            .animation(.easeOut(duration: 0.6), value: animateIcon)
                    }
                }
                
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .scaleEffect(animateIcon ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3), value: animateIcon)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.05), radius: isPressed ? 8 : 4, x: 0, y: isPressed ? 4 : 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Full Size Pass Preview

struct FullSizePassPreview: View {
    let template: PassTemplate
    let passData: PassCreationData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        // Full Size Pass (actual iOS Wallet dimensions)
                        VStack(alignment: .leading, spacing: 20) {
                            // Pass Header
                            HStack {
                                Image(systemName: template.icon)
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(Circle().fill(.white.opacity(0.3)))
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(passData.organizationName.isEmpty ? "Название организации" : passData.organizationName)
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                    Text(passData.passDescription.isEmpty ? "Описание пасса" : passData.passDescription)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                // Large QR Code
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white)
                                        .frame(width: 80, height: 80)
                                    
                                    VStack(spacing: 3) {
                                        ForEach(0..<5) { row in
                                            HStack(spacing: 3) {
                                                ForEach(0..<5) { col in
                                                    Rectangle()
                                                        .fill(.black)
                                                        .frame(width: 6, height: 6)
                                                        .opacity(Double.random(in: 0.3...1.0))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                                .background(.white.opacity(0.4))
                            
                            // All Fields Display
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(template.presetFields, id: \.key) { fieldTemplate in
                                    let value = getFieldValue(for: fieldTemplate.key)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: getFieldIcon(for: fieldTemplate.key))
                                                .foregroundColor(.white.opacity(0.8))
                                                .font(.caption)
                                            Text(fieldTemplate.label)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Text(value.isEmpty ? fieldTemplate.placeholder : value)
                                            .font(.subheadline.bold())
                                            .foregroundColor(value.isEmpty ? .white.opacity(0.6) : .white)
                                            .italic(value.isEmpty)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.white.opacity(0.1))
                                    )
                                }
                            }
                            
                            // Pass Footer
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Серийный номер")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("LY\(String(format: "%06d", Int.random(in: 100000...999999)))")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Создан")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(Date(), style: .date)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(24)
                        .frame(width: min(375, geometry.size.width - 40)) // iPhone width
                        .frame(height: 220) // Standard pass height
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        colors: [passData.backgroundColor, passData.backgroundColor.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: passData.backgroundColor.opacity(0.4), radius: 15, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Size Information
                        VStack(spacing: 12) {
                            Text("Реальный размер пасса в Apple Wallet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("Ширина")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("375 пт")
                                        .font(.caption.bold())
                                }
                                
                                VStack {
                                    Text("Высота")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("220 пт")
                                        .font(.caption.bold())
                                }
                                
                                VStack {
                                    Text("Соотношение")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("1.7:1")
                                        .font(.caption.bold())
                                }
                            }
                            .padding()
                            .background(.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Предпросмотр в реальном размере")
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
    
    private func getFieldValue(for key: String) -> String {
        return passData.customFields.first(where: { $0.key == key })?.value ?? ""
    }
    
    private func getFieldIcon(for key: String) -> String {
        switch key {
        case "member", "customerName": return "person.fill"
        case "points": return "star.fill"
        case "level": return "crown.fill"
        case "memberID": return "number"
        case "expiryDate": return "calendar"
        case "balance": return "dollarsign.circle.fill"
        case "website": return "globe"
        case "phone": return "phone.fill"
        case "email": return "envelope.fill"
        default: return "text.alignleft"
        }
    }
}

// MARK: - Registration Flow Views

struct RegistrationFlowView: View {
    let passURL: String
    let onDismiss: () -> Void
    @State private var showingQRCode = false
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 16) {
                    Text("Пасс создан!")
                        .font(.title.bold())
                    
                    Text("Теперь отправьте ссылку клиентам для регистрации")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Registration URL
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ссылка для регистрации:")
                        .font(.headline)
                    
                    HStack {
                        Text(passURL)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(8)
                        
                        Button {
                            UIPasteboard.general.string = passURL
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Actions
                VStack(spacing: 12) {
                    Button {
                        showingQRCode = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Показать QR-код")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        shareRegistrationLink()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Поделиться ссылкой")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Пасс создан")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        onDismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingQRCode) {
            NavigationView {
                QRCodeView(text: passURL)
                    .navigationTitle("QR-код для регистрации")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Готово") {
                                showingQRCode = false
                            }
                        }
                    }
            }
        }
    }
    
    private func shareRegistrationLink() {
        let activityVC = UIActivityViewController(
            activityItems: [passURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Customer Registration Views (Web)

struct WebCustomerRegistrationView: View {
    let passURL: String
    @State private var registrationData = CustomerRegistrationData()
    @State private var isRegistering = false
    @State private var showingSuccess = false
    @State private var createdUser: User?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.card.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Регистрация")
                            .font(.title2.bold())
                        
                        Text("Присоединяйтесь к программе лояльности")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Registration Form
                    VStack(spacing: 16) {
                        CustomTextField(
                            title: "Имя*",
                            text: $registrationData.name,
                            placeholder: "Введите ваше имя"
                        )
                        
                        CustomTextField(
                            title: "Телефон",
                            text: $registrationData.phone,
                            placeholder: "+7 999 123 45 67"
                        )
                        
                        CustomTextField(
                            title: "Email",
                            text: $registrationData.email,
                            placeholder: "example@mail.com"
                        )
                        
                        // Birthday picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Дата рождения")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                // Show date picker
                            } label: {
                                HStack {
                                    Text(registrationData.birthday?.formatted(date: .abbreviated, time: .omitted) ?? "Выберите дату")
                                        .foregroundColor(registrationData.birthday == nil ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(.gray.opacity(0.05))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Register Button
                    Button {
                        registerCustomer()
                    } label: {
                        HStack {
                            if isRegistering {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            
                            Text(isRegistering ? "Регистрация..." : "Зарегистрироваться")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? .blue : .gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isRegistering)
                }
                .padding()
            }
            .navigationTitle("Новый участник")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingSuccess) {
            if let user = createdUser {
                WebCustomerSuccessView(user: user, passURL: passURL)
            }
        }
    }
    
    private var isFormValid: Bool {
        !registrationData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func registerCustomer() {
        isRegistering = true
        
        Task {
            try await Task.sleep(for: .seconds(1.5))
            
            await MainActor.run {
                let user = User(
                    name: registrationData.name,
                    birthday: registrationData.birthday,
                    phone: registrationData.phone.isEmpty ? nil : registrationData.phone,
                    email: registrationData.email.isEmpty ? nil : registrationData.email,
                    points: 0
                )
                
                createdUser = user
                isRegistering = false
                showingSuccess = true
            }
        }
    }
}

struct CustomerRegistrationData {
    var name: String = ""
    var phone: String = ""
    var email: String = ""
    var birthday: Date?
}

struct WebCustomerSuccessView: View {
    let user: User
    let passURL: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Success Animation
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                
                VStack(spacing: 16) {
                    Text("Добро пожаловать!")
                        .font(.largeTitle.bold())
                    
                    Text("Вы успешно зарегистрированы в программе лояльности")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // User Card Preview
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Ваша карта")
                            .font(.headline)
                        Spacer()
                        Text("Баллы: \(user.points)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .font(.title3.bold())
                        
                        if let phone = user.phone {
                            Text(phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let email = user.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Add to Wallet Button
                Button {
                    addToWallet()
                } label: {
                    HStack {
                        Image(systemName: "wallet.pass.fill")
                        Text("Добавить в Apple Wallet")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Регистрация завершена")
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
    
    private func addToWallet() {
        // Add pass to Apple Wallet
        print("Adding to wallet: \(passURL)")
    }
}

// MARK: - Points Management System

class PointsUpdateManager: ObservableObject {
    @Published var passUpdates: [String: PassUpdate] = [:]
    
    private let updateTimer = Timer.publish(every: 24 * 60 * 60, on: .main, in: .common).autoconnect() // Daily
    
    init() {
        // Listen for daily updates
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("DailyPassUpdate"),
            object: nil,
            queue: .main
        ) { _ in
            self.triggerDailyUpdate()
        }
    }
    
    func addPoints(to userId: String, amount: Int, description: String) {
        let update = PassUpdate(
            userId: userId,
            pointsAdded: amount,
            description: description,
            timestamp: Date()
        )
        
        passUpdates[userId] = update
        schedulePassUpdate(for: userId)
    }
    
    func updatePassDesign(masterDesign: PassDesignUpdate) {
        // Update all passes with new design
        for userId in passUpdates.keys {
            schedulePassUpdate(for: userId)
        }
    }
    
    private func triggerDailyUpdate() {
        // Send updates to all passes once per day
        for (userId, update) in passUpdates {
            sendPassUpdate(userId: userId, update: update)
        }
        
        // Clear pending updates
        passUpdates.removeAll()
    }
    
    private func schedulePassUpdate(for userId: String) {
        // Schedule update for next daily sync
        print("Scheduled update for user: \(userId)")
    }
    
    private func sendPassUpdate(userId: String, update: PassUpdate) {
        // Send push notification to update pass
        print("Sending pass update for \(userId): +\(update.pointsAdded) points")
    }
}

struct PassUpdate {
    let userId: String
    let pointsAdded: Int
    let description: String
    let timestamp: Date
}

struct PassDesignUpdate {
    let backgroundColor: Color
    let textColor: Color
    let logoUrl: String?
    let templateChanges: [String: Any]
}

// MARK: - Apple Wallet Style Card Stack

struct WalletStackView: View {
    @StateObject private var passKitManager = PassKitManager()
    @State private var selectedCardIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var isExpanded: Bool = false
    
    let maxVisibleCards = 3
    let cardSpacing: CGFloat = 6          // Tighter spacing like real Wallet
    let stackedCardOffset: CGFloat = 12   // Offset for stacked cards
    let cardHeight: CGFloat = 200
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if passKitManager.passes.isEmpty {
                    emptyStateView
                } else {
                    ZStack {
                        ForEach(Array(zip(passKitManager.passes.indices, passKitManager.passes)), id: \.0) { index, pass in
                            WalletCardView(
                                pass: pass, 
                                isSelected: index == selectedCardIndex,
                                isInStack: !isExpanded && index != selectedCardIndex
                            )
                                .frame(height: cardHeight)
                                .scaleEffect(scaleForCard(at: index))
                                .offset(y: offsetForCard(at: index))
                                .zIndex(Double(passKitManager.passes.count - index))
                                .opacity(opacityForCard(at: index))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        if index == selectedCardIndex && !isExpanded {
                                            isExpanded = true
                                        } else {
                                            selectedCardIndex = index
                                            isExpanded = false
                                        }
                                    }
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(pass.organizationName) \(pass.description)")
                                .accessibilityValue(pass.headerFields.first?.value ?? "")
                                .accessibilityHint(index == selectedCardIndex ? "Дважды коснитесь для просмотра деталей" : "Коснитесь для выбора карты")
                                .accessibilityAddTraits(index == selectedCardIndex ? .isSelected : [])
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if index == selectedCardIndex {
                                                dragOffset = value.translation
                                            }
                                        }
                                        .onEnded { value in
                                            if index == selectedCardIndex {
                                                handleSwipeGesture(value: value)
                                            }
                                        }
                                )
                        }
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedCardIndex)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
                }
                
                if isExpanded && !passKitManager.passes.isEmpty {
                    expandedCardDetails
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Add new card action
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .accessibilityLabel("Добавить новую карту")
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Cards")
                .font(.title2.bold())
            
            Text("Your loyalty cards will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var expandedCardDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Details")
                .font(.headline)
            
            let selectedPass = passKitManager.passes[selectedCardIndex]
            
            VStack(alignment: .leading, spacing: 8) {
                Label(selectedPass.organizationName, systemImage: "building.2")
                Label(selectedPass.description, systemImage: "doc.text")
                Label("Serial: \(selectedPass.serialNumber)", systemImage: "number")
                Label(selectedPass.passType.description, systemImage: "creditcard")
            }
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(12)
            
            HStack(spacing: 12) {
                Button {
                    // Show QR code
                } label: {
                    Label("QR Code", systemImage: "qrcode")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button {
                    // Share card
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(radius: 2)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private func scaleForCard(at index: Int) -> CGFloat {
        if isExpanded && index == selectedCardIndex {
            return 1.0
        }
        
        let distance = abs(index - selectedCardIndex)
        if distance == 0 {
            return 1.0
        } else if distance <= maxVisibleCards {
            // More subtle scaling like real Apple Wallet
            return 1.0 - (CGFloat(distance) * 0.03)
        } else {
            return 0.90
        }
    }
    
    private func offsetForCard(at index: Int) -> CGFloat {
        if isExpanded && index == selectedCardIndex {
            return dragOffset.height
        }
        
        let distance = index - selectedCardIndex
        
        if distance == 0 {
            return dragOffset.height
        } else if distance > 0 && distance <= maxVisibleCards {
            // Cards below selected card - stacked with increasing offset
            return CGFloat(distance) * stackedCardOffset + dragOffset.height
        } else if distance < 0 && abs(distance) <= maxVisibleCards {
            // Cards above selected card - smaller offset for peek effect
            return CGFloat(distance) * cardSpacing + dragOffset.height
        } else {
            // Cards beyond visible range
            return CGFloat(distance > 0 ? maxVisibleCards : -maxVisibleCards) * stackedCardOffset
        }
    }
    
    private func opacityForCard(at index: Int) -> Double {
        let distance = abs(index - selectedCardIndex)
        if distance == 0 {
            return 1.0
        } else if distance <= maxVisibleCards {
            // More gradual opacity fade
            return 1.0 - (Double(distance) * 0.15)
        } else {
            return 0.0
        }
    }
    
    private func handleSwipeGesture(value: DragGesture.Value) {
        let threshold: CGFloat = 100
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if value.translation.height < -threshold && selectedCardIndex > 0 {
                selectedCardIndex -= 1
            } else if value.translation.height > threshold && selectedCardIndex < passKitManager.passes.count - 1 {
                selectedCardIndex += 1
            }
            
            dragOffset = .zero
            isExpanded = false
        }
    }
}

struct WalletCardView: View {
    let pass: WalletPassData
    let isSelected: Bool
    let isInStack: Bool
    @State private var isFlipped: Bool = false
    
    var body: some View {
        ZStack {
            if isFlipped {
                // Back of card
                cardBackView
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                // Front of card
                cardFrontView
            }
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture(count: 2) {
            // Double tap to flip card
            if !isInStack {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            }
        }
    }
    
    private var cardFrontView: some View {
        ZStack {
            // Card Background - Vivid colors as per Apple guidelines
            backgroundGradient
            
            if isInStack {
                // Stack View - Only header fields visible
                stackHeaderView
            } else {
                // Full View - All field hierarchy visible
                fullCardView
            }
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(
            color: .black.opacity(isSelected ? 0.4 : 0.2),
            radius: isSelected ? 12 : 6,
            x: 0,
            y: isSelected ? 10 : 5
        )
    }
    
    private var cardBackView: some View {
        ZStack {
            // Back background - darker version of front
            LinearGradient(
                colors: vividGradientColors.map { $0.opacity(0.8) },
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            
            VStack(alignment: .leading, spacing: 16) {
                // Back header
                HStack {
                    Text("Дополнительная информация")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                            isFlipped = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Back fields
                if !pass.backFields.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(pass.backFields) { field in
                            VStack(alignment: .leading, spacing: 4) {
                                if let label = field.label {
                                    Text(label.uppercased())
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Text(field.value)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                } else {
                    // Default back content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Условия использования:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("• Карта действительна только при предъявлении\n• Не подлежит обмену на денежные средства\n• Срок действия указан на лицевой стороне")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(2)
                    }
                }
                
                Spacer()
                
                // QR Code section
                VStack(spacing: 8) {
                    Text("QR-код для сканирования")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "qrcode")
                                .font(.system(size: 40))
                                .foregroundColor(.black)
                        )
                    
                    Text(pass.serialNumber)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(20)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(
            color: .black.opacity(0.3),
            radius: 8,
            x: 0,
            y: 6
        )
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: vividGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Subtle pattern overlay for depth
            LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.clear,
                    Color.black.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var stackHeaderView: some View {
        VStack(spacing: 0) {
            // Logo/Organization area - always visible in stack
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let logoText = pass.logoText {
                        Text(logoText)
                            .font(.system(.footnote, design: .default, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Header fields - most important info visible in stack
                    ForEach(pass.headerFields.prefix(1)) { field in
                        if let label = field.label {
                            Text(label.uppercased())
                                .font(.system(.caption2, design: .default, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Text(field.value)
                            .font(.system(.body, design: .default, weight: .bold))
                            .foregroundColor(.white)
                            .dynamicTypeSize(.medium ... .accessibility2)
                    }
                }
                
                Spacer()
                
                // Pass type icon
                Image(systemName: passTypeIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Spacer()
        }
    }
    
    private var fullCardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header section with logo
            headerSection
            
            Spacer()
            
            // Primary fields - most prominent
            if !pass.primaryFields.isEmpty {
                primaryFieldsSection
            }
            
            // Secondary and auxiliary fields
            bottomFieldsSection
        }
        .padding(20)
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let logoText = pass.logoText {
                    Text(logoText)
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundColor(.white)
                        .dynamicTypeSize(.medium ... .accessibility1)
                }
                
                Text(pass.description)
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .dynamicTypeSize(.medium ... .accessibility1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: passTypeIcon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private var primaryFieldsSection: some View {
        HStack(spacing: 20) {
            ForEach(pass.primaryFields.prefix(2)) { field in
                VStack(alignment: .leading, spacing: 2) {
                    if let label = field.label {
                        Text(label.uppercased())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Text(field.value)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8)
                }
                
                if field.id != pass.primaryFields.prefix(2).last?.id {
                    Spacer()
                }
            }
        }
    }
    
    private var bottomFieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Secondary fields
            if !pass.secondaryFields.isEmpty {
                HStack(spacing: 16) {
                    ForEach(pass.secondaryFields.prefix(3)) { field in
                        VStack(alignment: .leading, spacing: 2) {
                            if let label = field.label {
                                Text(label.uppercased())
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Text(field.value)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        if field.id != pass.secondaryFields.prefix(3).last?.id {
                            Spacer()
                        }
                    }
                }
            }
            
            // Auxiliary fields (smallest)
            if !pass.auxiliaryFields.isEmpty {
                HStack(spacing: 12) {
                    ForEach(pass.auxiliaryFields.prefix(4)) { field in
                        VStack(alignment: .leading, spacing: 1) {
                            if let label = field.label {
                                Text(label.uppercased())
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Text(field.value)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        if field.id != pass.auxiliaryFields.prefix(4).last?.id {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    // Vivid gradient colors as per Apple Wallet guidelines
    private var vividGradientColors: [Color] {
        switch pass.passType {
        case .storeCard:
            return [
                Color(red: 0.0, green: 0.4, blue: 0.8),      // Deep Blue
                Color(red: 0.3, green: 0.0, blue: 0.8),      // Deep Purple
                Color(red: 0.0, green: 0.2, blue: 0.6)       // Navy
            ]
        case .coupon:
            return [
                Color(red: 1.0, green: 0.3, blue: 0.0),      // Vivid Orange
                Color(red: 0.9, green: 0.0, blue: 0.2),      // Deep Red
                Color(red: 0.8, green: 0.1, blue: 0.4)       // Magenta
            ]
        case .eventTicket:
            return [
                Color(red: 0.0, green: 0.6, blue: 0.3),      // Forest Green
                Color(red: 0.0, green: 0.8, blue: 0.6),      // Teal
                Color(red: 0.0, green: 0.4, blue: 0.7)       // Ocean Blue
            ]
        case .boardingPass:
            return [
                Color(red: 0.1, green: 0.2, blue: 0.6),      // Deep Blue
                Color(red: 0.0, green: 0.4, blue: 0.8),      // Sky Blue
                Color(red: 0.2, green: 0.0, blue: 0.5)       // Indigo
            ]
        case .generic:
            return [
                Color(red: 0.2, green: 0.2, blue: 0.2),      // Dark Gray
                Color(red: 0.1, green: 0.1, blue: 0.1),      // Almost Black
                Color(red: 0.3, green: 0.3, blue: 0.3)       // Medium Gray
            ]
        }
    }
    
    private var passTypeIcon: String {
        switch pass.passType {
        case .storeCard:
            return "creditcard.fill"
        case .coupon:
            return "percent"
        case .eventTicket:
            return "ticket.fill"
        case .boardingPass:
            return "airplane"
        case .generic:
            return "doc.fill"
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let onImageSelected: () -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.onImageSelected()
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Program Analytics View

struct ProgramAnalyticsView: View {
    let program: LoyaltyProgram
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Основная статистика
                    analyticsOverviewSection
                    
                    // Пользователи
                    usersAnalyticsSection
                    
                    // Транзакции баллов
                    pointsTransactionsSection
                    
                    // Активность по времени
                    timeActivitySection
                }
                .padding()
            }
            .navigationTitle("Аналитика: \(program.name)")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var analyticsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Обзор")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AnalyticsCard(
                    title: "Всего пользователей",
                    value: "\(program.users.count)",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Активные карты",
                    value: "\(program.users.filter { $0.points > 0 }.count)",
                    icon: "creditcard.fill",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Всего баллов",
                    value: "\(program.users.reduce(0) { $0 + $1.points })",
                    icon: "star.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Средний баланс",
                    value: program.users.isEmpty ? "0" : "\(program.users.reduce(0) { $0 + $1.points } / program.users.count)",
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
        }
    }
    
    private var usersAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Пользователи")
                .font(.headline)
            
            if program.users.isEmpty {
                emptyUsersView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(program.users.prefix(5)) { user in
                        UserAnalyticsRow(user: user)
                    }
                    
                    if program.users.count > 5 {
                        Button("Показать всех (\(program.users.count))") {
                            // Действие для показа всех пользователей
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private var pointsTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Транзакции баллов")
                .font(.headline)
            
            // Здесь можно добавить график или список последних транзакций
            Text("Функция в разработке")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var timeActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Активность по времени")
                .font(.headline)
            
            // Здесь можно добавить график активности
            Text("График активности в разработке")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var emptyUsersView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Пока нет пользователей")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct UserAnalyticsRow: View {
    let user: User
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.subheadline.bold())
                
                Text("Регистрация: \(formattedDate(user.registeredAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(user.points)")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                
                Text("баллов")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Edit Loyalty Program View

struct EditLoyaltyProgramView: View {
    let program: LoyaltyProgram
    @Environment(\.dismiss) private var dismiss
    
    @State private var programName: String
    @State private var programDescription: String
    @State private var pointsPerPurchase: Int
    @State private var rewardThreshold: Int
    
    init(program: LoyaltyProgram) {
        self.program = program
        _programName = State(initialValue: program.name)
        _programDescription = State(initialValue: "Описание программы \(program.name)")
        _pointsPerPurchase = State(initialValue: 1)
        _rewardThreshold = State(initialValue: 100)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Основная информация") {
                    TextField("Название программы", text: $programName)
                    TextField("Описание", text: $programDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Настройки баллов") {
                    HStack {
                        Text("Баллов за покупку")
                        Spacer()
                        TextField("0", value: $pointsPerPurchase, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Порог для награды")
                        Spacer()
                        TextField("0", value: $rewardThreshold, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                }
                
                Section("Дополнительные настройки") {
                    Toggle("Автоматическое начисление баллов", isOn: .constant(true))
                    Toggle("Уведомления о новых баллах", isOn: .constant(true))
                    Toggle("Экспирация баллов", isOn: .constant(false))
                }
                
                Section("Статистика") {
                    HStack {
                        Text("Всего пользователей")
                        Spacer()
                        Text("\(program.users.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Активные карты")
                        Spacer()
                        Text("\(program.users.filter { $0.points > 0 }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Дата создания")
                        Spacer()
                        Text(formattedDate(program.createdAt))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Редактировать программу")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveProgram()
                    }
                    .disabled(programName.isEmpty)
                }
            }
        }
    }
    
    private func saveProgram() {
        // Здесь будет логика сохранения изменений программы
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Filter Components

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? .blue : .gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
    }
}

// MARK: - Edit Pass View

struct EditPassView: View {
    let passData: WalletPassData
    @ObservedObject var passKitManager: PassKitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var organizationName: String
    @State private var description: String
    @State private var passType: PassType
    @State private var backgroundColor: Color
    @State private var foregroundColor: Color
    
    init(passData: WalletPassData, passKitManager: PassKitManager) {
        self.passData = passData
        self.passKitManager = passKitManager
        _organizationName = State(initialValue: passData.organizationName)
        _description = State(initialValue: passData.description)
        _passType = State(initialValue: passData.passType)
        _backgroundColor = State(initialValue: Color.fromRGBString(passData.backgroundColor))
        _foregroundColor = State(initialValue: Color.fromRGBString(passData.foregroundColor))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Основная информация") {
                    TextField("Название организации", text: $organizationName)
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Тип пасса") {
                    Picker("Тип пасса", selection: $passType) {
                        ForEach(PassType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Дизайн") {
                    ColorPicker("Цвет фона", selection: $backgroundColor)
                    ColorPicker("Цвет текста", selection: $foregroundColor)
                }
                
                Section("Информация о пассе") {
                    HStack {
                        Text("Серийный номер")
                        Spacer()
                        Text(passData.serialNumber)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Дата создания")
                        Spacer()
                        Text(formattedDate(passData.createdAt))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Статус")
                        Spacer()
                        Text("Активен")
                            .foregroundColor(.green)
                    }
                }
                
                Section("Предпросмотр") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: passType.icon)
                                .foregroundColor(.white)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(organizationName.isEmpty ? "Организация" : organizationName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(description.isEmpty ? "Описание" : description)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Дата создания: \(formattedDate(passData.createdAt))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                    }
                    .padding()
                    .background(backgroundColor.gradient)
                    .cornerRadius(12)
                }
            }
            .navigationTitle("Редактировать пасс")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveChanges()
                    }
                    .disabled(organizationName.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        // В реальном приложении здесь будет логика сохранения изменений
        print("Сохранение изменений пасса: \(organizationName)")
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}



// MARK: - Quick Pass Creator For Specific Type
struct QuickPassCreatorForType: View {
    @ObservedObject var passKitManager: PassKitManager
    let passType: PassType?
    @Environment(\.dismiss) private var dismiss
    
    @State private var organizationName = ""
    @State private var description = ""
    @State private var selectedColor: Color = .blue
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: passType?.icon ?? "creditcard")
                            .font(.system(size: 50))
                            .foregroundColor(selectedColor)
                        
                        Text("Быстрое создание")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(passType?.displayName ?? "Пасс")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Название организации")
                                .font(.headline)
                            TextField("Введите название", text: $organizationName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Описание")
                                .font(.headline)
                            TextField("Краткое описание пасса", text: $description)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Цвет")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach([Color.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal], id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Preview
                    if !organizationName.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Предпросмотр")
                                .font(.headline)
                            
                            QuickPassPreviewCard(
                                organizationName: organizationName,
                                description: description.isEmpty ? (passType?.defaultDescription ?? "Пасс") : description,
                                color: selectedColor,
                                passType: passType ?? .generic
                            )
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Новый пасс")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createPass()
                    }
                    .disabled(organizationName.isEmpty || isCreating)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func createPass() {
        guard let passType = passType else { return }
        
        isCreating = true
        
        let passData = WalletPassData(
            passType: passType,
            organizationName: organizationName,
            description: description.isEmpty ? passType.defaultDescription : description,
            serialNumber: "LY\(String(format: "%06d", Int.random(in: 100000...999999)))"
        )
        
        // Add to PassKit manager
        passKitManager.passes.append(passData)
        
        // Success feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCreating = false
            dismiss()
        }
    }
}

struct QuickPassPreviewCard: View {
    let organizationName: String
    let description: String
    let color: Color
    let passType: PassType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: passType.icon)
                    .foregroundColor(.white)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(organizationName)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "qrcode")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.title2)
            }
            
            Divider()
                .background(.white.opacity(0.3))
            
            HStack {
                Text("Серийный номер")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("LY######")
                    .font(.caption.monospaced())
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}

// MARK: - PassType Extensions
extension PassType {
    var defaultDescription: String {
        switch self {
        case .coupon: return "Скидочный купон"
        case .storeCard: return "Карта магазина"  
        case .eventTicket: return "Билет на мероприятие"
        case .boardingPass: return "Посадочный талон"
        case .generic: return "Универсальный пасс"
        }
    }
}
