# ccusage メニューバーアプリ 実装To Doリスト

## Phase 1: MVP（最小機能版）

### 高優先度タスク
- [ ] **1. Xcodeプロジェクトの作成とセットアップ**
  - XcodeBuildMCPでmacOSプロジェクト作成（`xcode-create-project`）
  - プロジェクト名: CCUsageMenuBar
  - SwiftUIテンプレート使用
  - 最小対応OS: macOS 13.0に設定
  - プロジェクトのビルド設定確認（`xcode-list-settings`）

- [ ] **2. 基本的なMenuBarExtraアプリの実装**
  - CCUsageMenuBarApp.swiftでMenuBarExtraを設定
  - 最小限のメニューバー表示を確認
  - XcodeBuildMCPでビルド実行（`xcode-build`）
  - アプリの起動テスト（`xcode-launch-app`）

- [ ] **3. CCUsageServiceの実装（ccusageコマンド実行）**
  - Processクラスを使用してccusageコマンドを実行
  - `ccusage daily --json`の出力を取得
  - 非同期処理の実装

- [ ] **4. データモデルの実装**
  - DailyUsageData構造体の作成
  - MonthlyUsageData構造体の作成
  - JSON デコーディング対応

- [ ] **5. MenuBarViewModelの実装（メインロジック）**
  - ObservableObjectとして実装
  - CCUsageServiceを呼び出し
  - データの保持と更新ロジック

- [ ] **6. メニューバーに今日の使用金額を表示**
  - 金額のフォーマット（例: "$45.32"）
  - リアルタイムで表示更新

## Phase 2: 基本機能

### 中優先度タスク
- [ ] **7. 手動更新機能の実装**
  - "今すぐ更新"メニュー項目の追加
  - 更新処理のトリガー

- [ ] **8. ドロップダウンメニューの実装**
  - MenuContentViewの作成
  - 本日の使用状況詳細表示
  - メニュー項目の配置

- [ ] **9. 設定画面の基本実装**
  - SettingsViewの作成
  - 更新間隔の選択UI
  - JSONLファイルパスの設定

- [ ] **10. 自動更新機能の実装（Timer）**
  - 設定可能な間隔でのタイマー実装
  - バックグラウンドでの更新処理

- [ ] **11. 月次レポート表示機能の実装**
  - MonthlyReportViewの作成
  - `ccusage monthly --json`の実行と表示

- [ ] **12. 設定の永続化（UserDefaults）**
  - AppSettings構造体の実装
  - 設定の保存と読み込み

## Phase 3: 改善と完成度向上

### 低優先度タスク
- [ ] **13. アプリアイコンの作成**
  - メニューバー用アイコン（テンプレート画像）
  - アプリケーションアイコン

- [ ] **14. 起動時の自動起動設定**
  - LaunchAgentsの設定
  - 設定画面での切り替え実装

- [ ] **15. エラーハンドリングの改善**
  - ccusageコマンドのエラー処理
  - ユーザーへのフィードバック

- [ ] **16. リリースビルドの作成**
  - XcodeBuildMCPでリリースビルド（`xcode-build --configuration Release`）
  - アプリのアーカイブ作成
  - 配布用DMGの作成

## 実装時の注意事項

### 各フェーズの完了条件
- **Phase 1完了**: メニューバーに今日の使用金額が表示され、手動更新が可能
- **Phase 2完了**: 自動更新、設定画面、月次レポートが機能する
- **Phase 3完了**: 製品としての完成度（アイコン、自動起動、エラー処理）

### テスト項目
- [ ] ccusageコマンドが正しく実行されるか
- [ ] JSON解析が正しく行われるか
- [ ] 更新間隔が設定通りに動作するか
- [ ] 設定が正しく保存・復元されるか
- [ ] XcodeBuildMCPでテスト実行（`xcode-test`）

### デバッグ用タスク
- [ ] コンソールログの追加
- [ ] デバッグ用のモックデータ作成
- [ ] エラー状態のシミュレーション

## 開発環境セットアップ

1. Xcode 15.0以上をインストール
2. XcodeBuildMCP を有効化
   - MCPサーバーとしてXcodeBuildMCPを設定
   - 利用可能なコマンドを確認
3. ccusageコマンドがインストール済みであることを確認
   ```bash
   which ccusage
   ccusage --version
   ```
4. サンプルのJSONLファイルが存在することを確認
   ```bash
   ls ~/.claude/code/usage_logs/
   ```

## XcodeBuildMCP 活用のポイント

- **プロジェクト作成**: `xcode-create-project`でmacOSアプリテンプレートから開始
- **ビルド管理**: `xcode-build`でインクリメンタルビルド、`xcode-clean`でクリーンビルド
- **デバッグ**: `xcode-launch-app`でアプリ起動、`xcode-stop-app`で停止
- **テスト**: `xcode-test`でユニットテストとUIテストを実行
- **設定確認**: `xcode-list-settings`でビルド設定を確認
- **スキーム管理**: `xcode-list-schemes`でビルドスキームを確認

## 次のステップ

1. このTo Doリストに従って、Phase 1から順番に実装
2. 各タスク完了時にチェックを入れる
3. Phase完了時に動作確認とテストを実施
4. 問題があれば仕様書を参照して調整
5. XcodeBuildMCPを活用して効率的に開発を進める