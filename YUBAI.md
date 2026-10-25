# 余白 / Yubai

基于 James Kokoska 的 [Cashew](https://github.com/jameskokoska/Cashew)，上游基线 `9cfbe50c16d95429891d44faf5f2c77a3abdb93b`。这是个人定制版，与原作者的官方服务无关联。原 README、LICENSE、作者名单和素材归属均保留。修改日期：2026-10-23。

## 修改边界

- 保留 Flutter、Drift schema 46、原有账户/交易/分类/预算/统计/搜索/CSV/SQLite 备份恢复/Goals 页面和金额计算。
- 新增 Goals 详情的默认 30 个自然日冷静期，复用 `Objective.dateCreated`。原版把这个字段也当作可编辑的开始日期，所以显示为“创建时间／原开始日期”。已有 Goal 沿用原值；修改开始日期会改变倒计时。没有伪造历史创建时间，没有新增数据库列。
- 手动预算检查：预留前可动用总额 − 要保留的存款 − 近期必要开支 − 心愿目标价格。资金输入在关闭表单后丢弃，不生成交易、不重复计支出。所有输入应使用该 Goal 账户币种，表单最多支持两位小数；输入框右侧可打开 Cashew 原有金额计算器。
- 默认新用户使用浅紫、米白主题，Geist + 本机思源黑体裁剪版；保留深色模式、原字体选择和已有用户设置。底部导航增加轻微模糊，新表单保留 48 像素触控高度和 SafeArea。
- 本地版不初始化 Firebase、不支持 Google 云登录/共享预算/Drive 同步；原代码保留，入口给出本地模式说明。设备备份与恢复仍可用。Web 内容策略阻止未使用的 Google 登录脚本及外部连接，手机运行只连接本站。汇率使用同源地址，腾讯云服务器代取公开汇率，不发送账目；失败时保留原缓存及自定义汇率。
- 仅 Web/PWA 已验证。未制作 Android、Windows 原生包或 IPA。
- 首次安装默认简体中文，不依赖手机系统语言；设置中仍可选择英语、跟随系统及其他原版语言，已保存的选择优先。
- 2026-10-24 补齐 iPhone / iPad 的 152、167、180 像素 Apple touch icon，使用版本化 PNG 地址；服务器根目录也提供无需登录的图标回退。已安装的旧占位图可能仍被 iOS 缓存。更新入口前先导出账目备份、保留旧入口，不清除网站数据。
- 2026-10-25 优化 Web 启动页：小型品牌标识、轻微呼吸与三点等待动效、真实启动阶段提示、首帧后平滑退场，适配深色/横屏/减少动态效果。Geist 与仅约11KB的 Noto Sans SC 中文子集同源加载，许可位于 `budget/web/startup/`；三点动效参考 [SpinKit Flow](https://github.com/tobiasahlin/SpinKit)，保留 MIT 归属。主记账程序、数据模型与存储方式未改，不设虚假进度或最低等待时间。

## 工具与依赖

Flutter 3.22.3 / Dart 3.4.4。为处理实际构建错误，仅把 `intl` 改为 0.19.0、`device_preview` 固定为 1.2.0、`home_widget` 固定为 0.6.0，其余变动为 SDK 所需的传递依赖。两个 Git 依赖固定在上游 lockfile 的提交。没有运行全量依赖升级。

```powershell
cd budget
flutter pub get
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357 --web-renderer html
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release --web-renderer html --pwa-strategy=none --no-web-resources-cdn --base-href /yubai-cashew/
```

Windows 的数据库单元测试需要 SQLite DLL，可通过 `YUBAI_SQLITE_DLL` 指定完整路径；CI Linux 使用系统 SQLite。Web 运行使用仓库已有的 `sql-wasm.js/.wasm`，不需要该 DLL。

## 备份与存储

设置 → 导出数据文件，保存 `.sqlite`（完整 SQLite 数据和原版 settings）。恢复：设置 → 导入数据文件 → 确认覆盖 → 选择备份 → 刷新。CSV 用于交易交换，不能替代完整备份。新增冷静期从已有字段计算，完整 SQLite 备份也包含所需数据。

数据库沿用 Drift 的 IndexedDB 存储，浏览器不支持时回退到原版 localStorage。不要用隐私模式记正式账；清理网站数据会删除账本。更换域名、协议、端口，或从 Safari 转入主屏幕应用时，先导出再验证是否需要导入；不能假定不同存储空间自动互通。GitHub Pages 同一账号下的项目共享 origin，若同源已有其他 Cashew 实例，应先备份并避免同时操作多个实例。

Safari 的持久存储请求可能被拒绝，系统也可能回收网站数据；安装到主屏幕不能代替备份。依据：[WebKit 存储策略](https://webkit.org/blog/14403/updates-to-storage-policy/)。Windows 浏览器验证不能证明 iPhone Safari 真机表现。

## 离线和更新

本版明确使用 `--pwa-strategy=none`，没有可靠的离线启动机制。不承诺断网后重新打开可用。刷新和发布更新不主动清除 IndexedDB/localStorage。Flutter 的原版自动缓存不能直接当作可靠的离线承诺。

## 公开部署

用户已于 2026-10-23 授权部署，并要求手机不使用代理。优先复用已有的腾讯云新加坡服务器，独立域名为 https://yubai-43-134-20-29.sslip.io/yubai-cashew/ 。配置见 `scripts/yubai.caddy`；仅静态应用文件与公开汇率，没有账目上传接口。服务器、免费 DNS、证书及运营商网络仍可能影响访问，不承诺所有网络永不间断。服务器沿用已有套餐，没有购买新资源。

源码仓库：https://github.com/birdy2213756/yubai-cashew 。保留手动 Pages 工作流作为可选部署方案，但不把 GitHub Pages 默认域名作为国内直连保障。项目站点自动使用 `/<仓库名>/`，账号主页仓库使用 `/`。Manifest、图标、SQL 资源采用相对路径。纯静态站的汇率文件是内含日期的快照；腾讯云同一地址由服务器取得最新公开数据。

公开分发时，保留 GPL-3.0 及所有必要归属，发布与构建版对应的完整源代码。工作流会在站点 `source/yubai-source.zip` 提供该提交的源码快照，并保留 LICENSE。站点启动页也链接源码与许可。

## iPhone 安装及真机验收

1. 用 iPhone Safari 打开上面的腾讯云 HTTPS 地址。
2. 分享 → 添加到主屏幕 → 名称“余白” → 添加。
3. 从主屏幕重新打开，创建一笔测试交易和一个心愿，刷新和关闭重开后核对。
4. 导出 `.sqlite` 到“文件”，验证可选取并恢复；正式记账前完成这项检查。
5. 更新版本前导出备份；更新后核对金额和 Goal，再测试新交易。

尚未在实际 iPhone 上执行上述验收。不需要 Mac 或 Xcode。
