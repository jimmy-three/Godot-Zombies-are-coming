<div align="center">
  <h1>🧟 Zombies Are Coming</h1>
  <p><strong>一个用 Godot 4 开发的生存射击游戏</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Godot-4.2-%23478CBF?logo=godotengine&logoColor=white" alt="Godot 4">
    <img src="https://img.shields.io/badge/Language-GDScript-%23478CBF" alt="GDScript">
    <img src="https://img.shields.io/badge/Status-开发中-brightgreen" alt="Status">
  </p>
</div>

---

## 🎮 操作方式

- `WASD` 移动角色
- `空格` / `鼠标左键` 射击
- `←` `→` 转向（也可在商店购买“面向鼠标”功能）
- `ESC` 打开/关闭商店与设置界面
- 长按 `Q` 选择道具，`E` 使用道具
- `1` ~ `5` 切换武器

---

## 🏪 商店系统

商店分为 6 个页面：

| 页面 | 内容 |
|------|------|
| ① 增益 | 伤害、射速、击退、精度提升 |
| ② 武器 | AK47 / 加特林 / 霰弹枪 / 狙击枪（可升级） |
| ③ 道具 | 绷带 / 月永云力 / 火焰子弹 / 精准射击 |
| ④ 特殊 | 骸骨泯灭者（导弹）/ 炮台 |
| ⑤ 弹药 | 各类型子弹与炮弹 |
| ⑥ 自动 | 自动购买子弹 / 火焰子弹 |

---

## 🧟 核心机制

- 动态难度：随时间自动提升，僵尸越来越强
- 多种僵尸：普通 / 侦查兵 / 士兵
- Boss 系统：每 20 波出现一次
- 金币系统：击杀僵尸掉落金币，用于商店消费

---

## 🛠️ 技术栈

- **引擎**：Godot 4.x
- **语言**：GDScript
- **版本控制**：Git + GitHub
- **平台**：Windows / macOS / Linux / Web

---

## 🚀 如何运行

1. 安装 [Godot 4.x](https://godotengine.org/download)
2. 克隆本仓库：
   ```bash
   git clone git@github.com:jimmy-three/Godot-Zombies-are-coming.git

---

## 📁 项目结构

Godot-Zombies-are-coming/
├── addons/          # 插件
├── resources/       # 图片 / 音频 / 字体
├── translations/    # 多语言翻译
├── *.tscn           # 场景文件
├── *.gd             # 脚本
└── project.godot    # 项目配置

---

## 📄 版本记录
完整更新日志请查看 CHANGELOG.md

---

<div align="center"> <sub>由 <strong>jimmy-three</strong> 制作 · 一个准高一生的游戏开发之路</sub> </div> ```
