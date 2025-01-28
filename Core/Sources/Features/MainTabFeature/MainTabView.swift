import SwiftUI
import Entities
import CoreProtocols
import Components

public struct MainTabView<Dependency: DependencyProtocol>: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    @State private var preferredColumn = NavigationSplitViewColumn.detail
    public init() {
        
    }
    public var body: some View {
        TabView {
            NavigationStack {
                Dependency.noteListView()
            }
                .tabItem {
                    Label("ノートリスト", systemImage: "magazine")
                }
            NavigationStack {
                Text("テンプレート")
            }
                .tabItem {
                    Label("テンプレート", systemImage: "tray")
                }
            NavigationStack {
                Text("設定")
            }
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
        }
    }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .none {
                // iPhone用レイアウト (TabView)
                iPhoneLayout()
            } else {
                // iPad用レイアウト (Sidebar + カラム)
                iPadLayout()
            }
        }
    }

    // iPhone用レイアウト
    @ViewBuilder
    private func iPhoneLayout() -> some View {
        TabView {
            FeatureView1()
                .tabItem {
                    Label("機能1", systemImage: "square.and.pencil")
                }
                .badge(1)
            FeatureView2()
                .tabItem {
                    Label("機能2", systemImage: "person")
                }
            FeatureView3()
                .tabItem {
                    Label("機能3", systemImage: "gear")
                }
        }
    }

    // iPad用レイアウト
    @ViewBuilder
    private func iPadLayout() -> some View {
        NavigationSplitView {
            List {
                NavigationLink(destination: FeatureView1()) {
                    Label("機能1", systemImage: "square.and.pencil")
                }
                NavigationLink(destination: FeatureView2()) {
                    Label("機能2", systemImage: "person")
                }
                NavigationLink(destination: FeatureView3()) {
                    Label("機能3", systemImage: "gear")
                }
            }
            .navigationTitle("メニュー")
        } detail: {
            Text("機能を選択してください")
                .font(.title)
        }
    }
}

// 機能ごとのView
struct FeatureView1: View {
    var body: some View {
        Text("機能1の内容")
    }
}

struct FeatureView2: View {
    var body: some View {
        Text("機能2の内容")
    }
}

struct FeatureView3: View {
    var body: some View {
        Text("機能3の内容")
    }
}

// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    MainTabView<DummyDependency>()
}
