# astra-bot

Astra Serve（`astra-serve-host`）的**二进制分发仓库**。源码闭源，本仓库只包含：

- [Release 资产](../../releases)：各平台的 `astra-serve-host` 原生二进制
- [`latest.json`](latest.json)：最新版本清单（桌面端自动下载的依据）
- [`scripts/upload.sh`](scripts/upload.sh)：本地构建后的上传辅助脚本

## 安装

### Astra 桌面端（推荐）

桌面端「Agent 服务」页启动 Serve 时会自动完成：本地没有二进制 → 拉取
`latest.json` → 按当前平台下载到应用数据目录 → sha256 校验 → 启动。无需手动操作。

### 手动安装

1. 从 [Releases](../../releases) 下载对应平台的文件：

   | 平台 | 文件 |
   | --- | --- |
   | Apple Silicon (M 系列) | `astra-serve-host-aarch64-apple-darwin` |
   | Intel Mac | `astra-serve-host-x86_64-apple-darwin` |
   | Windows x64 | `astra-serve-host-x86_64-pc-windows-msvc.exe` |

2. 校验（可选）：

   ```sh
   shasum -a 256 astra-serve-host-aarch64-apple-darwin   # macOS
   # 对照 Release 说明或 latest.json 里的 sha256
   ```

3. 放入固定位置并赋权：

   ```sh
   mkdir -p ~/.astra/bin
   cp astra-serve-host-aarch64-apple-darwin ~/.astra/bin/astra-serve-host
   chmod +x ~/.astra/bin/astra-serve-host
   ```

   Windows 放 `%USERPROFILE%\.astra\bin\astra-serve-host.exe`。

## 发布新版本（维护者）

在 astra-serve 源码仓库构建后上传：

```sh
scripts/upload.sh <版本号>   # 例如 scripts/upload.sh 0.2.0
```

脚本完成：本机构建 → 生成 sha256 → 更新 latest.json → 创建 Release 并上传资产。

## License

二进制按现状分发（AS-IS），版权归 Astra 项目所有，详见 LICENSE。
