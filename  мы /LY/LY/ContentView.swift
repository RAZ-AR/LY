//
//  ContentView.swift
//  LY
//
//  Created by Armen on 15/06/2025.
//

import SwiftUI

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
    @State private var loyaltyCards: [LoyaltyCard] = [
        LoyaltyCard(title: "Премиум клиенты", description: "VIP программа лояльности", color: .purple, membersCount: 1250, revenue: "₽2,500,000"),
        LoyaltyCard(title: "Базовые клиенты", description: "Стандартная программа", color: .blue, membersCount: 8930, revenue: "₽1,200,000")
    ]
    @State private var selectedTab = 0
    @State private var showingAddCard = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Главная вкладка
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(loyaltyCards) { card in
                            LoyaltyCardView(card: card)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Админ панель")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddCard = true
                        } label: {
                            Image(systemName: "plus")
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
                Image(systemName: "house")
                Text("Главная")
            }
            .tag(0)
            
            // Аналитика
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Аналитика")
                }
                .tag(1)
            
            // Биллинг
            BillingView()
                .tabItem {
                    Image(systemName: "creditcard")
                    Text("Биллинг")
                }
                .tag(2)
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

#Preview {
    ContentView()
}
