# ccusage メニューバーアプリ 仕様書と実装方針

## 1. アプリケーション概要

### 1.1 目的
ccusage CLIツールの出力をmacOSメニューバーに常駐表示し、Claude Codeの使用状況をリアルタイムで確認できるネイティブアプリケーションを開発する。

### 1.2 背景
- ccusageは、Claude Codeのトークン使用量とコストを分析するCLIツール
- コマンドラインでの実行が必要で、継続的な監視には不便
- メニューバーアプリ化により、常時使用状況を把握可能に

## 2. 機能仕様

### 2.1 メニューバー表示機能
- **表示内容**
  - 今日の使用金額(USD)
  - 設定で選択した間隔で定期的に最新の情報を取得して表示を更新
- **表示形式オプション**
  - テキスト表示（例: "$45.32"）

### 2.2 ドロップダウンメニュー機能
メニューバーアイコンをクリックした際に表示される項目：

1. **本日の使用状況**
   - 使用トークン数
   - 推定コスト（USD）

2. **レポート表示**
   - 月次レポート（当月の累計）

3. **アクション項目**
   - 今すぐ更新
   - 設定を開く
   - ccusageについて
   - 終了

### 2.3 自動更新機能
- **更新間隔**: 1分、3分、5分、10分から選択可能
- **更新トリガー**
  - 定期的な自動更新
  - JSONLファイルの変更検知（オプション）
  - 手動更新

### 2.4 設定画面
- **一般設定**
  - 起動時の自動起動
  - メニューバー表示形式
  - 更新間隔
- **データ設定**
  - JSONLファイルパス（デフォルト: ~/.claude/code/usage_logs）
  - ccusageコマンドパス

## 3. 技術仕様

### 3.1 開発環境
- **プログラミング言語**: Swift 5.9+
- **UI Framework**: SwiftUI（メイン） + AppKit（メニューバー統合）
- **最小対応OS**: macOS 13.0 (Ventura)以降
- **開発ツール**: Xcode 15.0+

### 3.2 アーキテクチャ設計

#### 3.2.1 全体構成
```
┌─────────────────┐
│  MenuBarExtra   │ ← SwiftUI/AppKit
├─────────────────┤
│  View Layer     │ ← SwiftUI Views
├─────────────────┤
│ ViewModel Layer │ ← ObservableObject
├─────────────────┤
│ Service Layer   │ ← Business Logic
├─────────────────┤
│   Data Layer    │ ← Models & Storage
└─────────────────┘
```

#### 3.2.2 主要コンポーネント
1. **MenuBarExtra**: macOS 13+の新しいメニューバーAPI
2. **Process**: ccusageコマンドの実行
3. **Timer/Combine**: 定期更新の管理
4. **UserDefaults**: 設定の永続化

### 3.3 データモデル

```swift
// 日次使用量データ
struct DailyUsageData {
    let date: Date
    let totalTokens: Int
    let totalCost: Double
    let modelBreakdown: [ModelUsage]
}

// モデル別使用量
struct ModelUsage {
    let modelName: String
    let tokens: Int
    let cost: Double
}

// 月次使用量データ
struct MonthlyUsageData {
    let month: Date
    let totalTokens: Int
    let totalCost: Double
    let dailyUsage: [DailyUsageData]
}

// アプリ設定
struct AppSettings {
    var updateInterval: TimeInterval
    var autoLaunchAtLogin: Bool
    var jsonlFilePath: String
    var ccusageCommandPath: String
}
```

### 3.4 外部依存関係
- ccusageコマンド（インストール済みを前提）
- システム標準フレームワークのみ使用（外部ライブラリなし）

### 3.5 ccusageコマンドの使用
- `ccusage daily --json`: 今日の使用量データを取得
- `ccusage monthly --json`: 今月の使用量データを取得
- JSON出力をパースしてアプリで表示

## 4. 実装方針

### 4.1 プロジェクト構造
```
ccusage-menu-bar-extra/
├── CCUsageMenuBarApp.swift          # @main アプリエントリーポイント
├── Views/
│   ├── MenuBarView.swift           # メニューバー表示View
│   ├── MenuContentView.swift       # ドロップダウンメニュー
│   ├── ReportViews/
│   │   ├── DailyReportView.swift   # 日次レポート
│   │   └── MonthlyReportView.swift # 月次レポート
│   └── SettingsView.swift          # 設定画面
├── ViewModels/
│   ├── MenuBarViewModel.swift      # メインViewModel
│   └── SettingsViewModel.swift     # 設定ViewModel
├── Models/
│   ├── DailyUsageData.swift       # 日次データモデル
│   ├── MonthlyUsageData.swift     # 月次データモデル
│   └── AppSettings.swift          # 設定モデル
├── Services/
│   ├── CCUsageService.swift       # ccusageコマンド実行
│   └── FileWatcherService.swift   # ファイル監視（オプション）
├── Utilities/
│   ├── DateFormatter+.swift       # 日付フォーマット拡張
│   └── NumberFormatter+.swift     # 数値フォーマット拡張
├── Resources/
│   ├── Assets.xcassets           # アイコン、画像
│   └── Localizable.strings       # ローカライズ（将来対応）
└── Info.plist                    # アプリ設定
```

### 4.2 実装優先順位

#### Phase 1: MVP（最小機能版）
1. 基本的なメニューバー表示
2. ccusage daily --jsonの実行と解析
3. 今日の使用金額表示
4. 手動更新機能

#### Phase 2: 基本機能
1. 自動更新（Timer実装）
2. ドロップダウンメニュー
3. 基本的な設定画面
4. 月次レポート表示

#### Phase 3: 拡張機能
1. 詳細な設定オプション
2. ファイル監視による自動更新
3. エラー通知
4. 使用量トレンド表示

#### Phase 4: 改善
1. パフォーマンス最適化
2. UI/UXの改善
3. エラーハンドリングの強化
4. ローカライズ対応

### 4.3 開発上の考慮事項

1. **パフォーマンス**
   - ccusageコマンドの実行は非同期で行う
   - 不要な再描画を避ける

2. **前提条件**
   - ccusageがインストール済み
   - JSONLファイルが存在する（~/.claude/code/usage_logs）
   - ccusageコマンドが正常に動作する

3. **ユーザビリティ**
   - 直感的なUI
   - 適切なデフォルト値（更新間隔: 5分）

## 5. テスト計画

### 5.1 単体テスト
- データモデルのパース処理
- 使用率計算ロジック
- 日付・時刻処理

### 5.2 統合テスト
- ccusageコマンドとの連携
- 設定の保存・読み込み
- 自動更新機能

### 5.3 UIテスト
- メニューバー表示
- 設定画面の動作
- レポート表示

## 6. リリース計画

### 6.1 配布方法
- GitHub Releasesでのdmg配布
- Homebrew Cask（将来的に）
- Mac App Store（オプション）

### 6.2 バージョニング
- セマンティックバージョニング採用
- v1.0.0: MVP機能を含む初回リリース

## 7. 今後の拡張案

1. **グラフ表示機能**
   - 使用量の推移グラフ
   - コスト予測

2. **複数プロジェクト対応**
   - プロジェクト別の使用量追跡
   - プロジェクト切り替え

3. **エクスポート機能**
   - レポートのCSV/PDF出力
   - 使用量データのバックアップ

4. **ウィジェット対応**
   - macOSウィジェットでの表示
   - ショートカット対応