# WatchTama (Apple Watch)

Apple Watch単体で完結する、たまごっちライクな育成ゲームのプロトタイプです。短い隙間時間で「世話 → 反応 → 状態変化」を体験できる構成にしています。

## できること
- 1匹の育成（名前は初回のみ設定）
- 状態管理（空腹/機嫌/清潔/体力/眠気）
- 世話（ごはん/遊ぶ/掃除/寝かせる/なでる/薬）
- 進化（幼体→成体→最終、分岐あり）
- 履歴と設定
- watchOS 10向けWidgetKitコンプリケーション

## 実装のメモ
- バックグラウンド更新は `scheduleBackgroundRefresh` を短時間だけ予約
- 状態変化は「前回更新時刻」と「現在時刻」の差分で計算
- 進化は経過時間と平均ステータスで分岐

## セットアップ
1. Homebrewでxcodegenが入っていることを確認
2. プロジェクト生成

```bash
cd /Users/kawashimataiki/Desktop/WatchTama
xcodegen generate
```

3. `WatchTama.xcodeproj` をXcodeで開き、watchOSシミュレータ/実機で起動

## 構成
```
WatchTama/
  project.yml
  Shared/
  WatchTama/
  WatchTamaWidget/
```

## 注意点
- App Group `group.com.watchtama.shared` を使用（Widgetとデータ共有）
- AppIconはプレースホルダーです。必要に応じて差し替えてください。

## ライセンス
MIT
