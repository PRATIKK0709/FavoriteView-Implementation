import SwiftUI

struct Item: Identifiable, Decodable, Encodable {
    let id = UUID()
    let name: String
    var isFavorite: Bool
}


let demoItems: [Item] = [
    Item(name: "Item 1", isFavorite: false),
    Item(name: "Item 2", isFavorite: false),
    Item(name: "Item 3", isFavorite: false),
    Item(name: "Item 4", isFavorite: false),
]

@main
struct DemoApp: App {
    @AppStorage("favorites", store: UserDefaults.standard) var favoritesData: Data?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FavoriteStore(favoritesData: $favoritesData))
        }
    }
}

class FavoriteStore: ObservableObject {
    @Published var favorites: [Item]

    init(favoritesData: Binding<Data?>) {
        if let data = try? favoritesData.wrappedValue,
           let decodedFavorites = try? JSONDecoder().decode([Item].self, from: data) {
            self.favorites = decodedFavorites
        } else {
            self.favorites = []
        }
    }

    func saveFavorites() {
        if let encodedData = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encodedData, forKey: "favorites")
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var favoriteStore: FavoriteStore

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(demoItems) { item in
                        NavigationLink(destination: ItemDetail(item: item)) {
                            GridItemView(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Favorite Prototype")
            .toolbar {
                NavigationLink(destination: FavoritesView()) {
                    Image(systemName: "heart.fill")
                }
            }
        }
    }
}

struct GridItemView: View {
    let item: Item

    var body: some View {
        VStack {
            Spacer()
            Text(item.name)
                .font(.headline)
                .foregroundColor(item.isFavorite ? .yellow : .gray)
            Spacer()
        }
    }
}

struct ItemDetail: View {
    let item: Item
    @EnvironmentObject var favoriteStore: FavoriteStore

    var body: some View {
        VStack {
            Text(item.name)
                .font(.title)
            Button(action: {
                if let index = favoriteStore.favorites.firstIndex(where: { $0.id == item.id }) {
                    favoriteStore.favorites.remove(at: index)
                } else {
                    favoriteStore.favorites.append(item)
                }
                favoriteStore.saveFavorites()
            }) {
                Text(item.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct FavoritesView: View {
    @EnvironmentObject var favoriteStore: FavoriteStore

    var body: some View {
        List {
            ForEach(favoriteStore.favorites) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Button(action: {
                        if let index = favoriteStore.favorites.firstIndex(where: { $0.id == item.id }) {
                            favoriteStore.favorites.remove(at: index)
                            favoriteStore.saveFavorites()
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Favorites")
    }
}
