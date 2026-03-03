# YAML Frontmatter 格式指南

## ✅ 正确的格式

```yaml
---
name: skill-creator
description: Create or update AgentSkills with proper structure...
---
```

## ❌ 错误的格式

```yaml
---
name: skill-creator
description: "Create or update AgentSkills with proper structure..."  # ❌ 不要用双引号！
---
```

## 📋 YAML Frontmatter 格式规则

### 1. 不要用引号
- ❌ **错误**：`description: "我的描述..."`
- ✅ **正确**：`description: 我的描述...`

### 2. 必需的字段
```yaml
---
name: skill-name           # 必填
description: 描述...       # 必填
---
```

### 3. 可选的字段
```yaml
---
name: skill-name
description: 描述...
homepage: https://example.com  # 可选
metadata:                     # 可选
  openclaw:
    emoji: "🎯"
    events: ["command:new"]
---
```

### 4. 完整示例（HOOK.md）
```yaml
---
name: my-hook
description: Does something useful when /new is issued
metadata:
  openclaw:
    emoji: "🎯"
    events: ["command:new"]
---
```

## 🛡️ 为什么会有这个问题？

### 原因分析：
1. **YAML 解析器差异** - 不同的 YAML 解析器对引号的处理不同
2. **OpenClaw 的要求** - OpenClaw 的 hooks 加载器期望无引号的格式
3. **复制粘贴错误** - 从其他地方复制时可能带了引号

### 影响：
- ❌ Hook 可能无法被正确发现
- ❌ Metadata 可能无法被正确解析
- ❌ Hook 可能无法被启用

## ✅ 避免后续发生的方法

### 1. 使用模板
始终使用提供的模板，不要手动写 YAML frontmatter：

**HOOK.md 模板：**
```yaml
---
name: my-hook
description: 我的 hook 描述
metadata:
  openclaw:
    emoji: "🎯"
    events: ["command:new"]
---
```

### 2. 检查清单
创建或修改 SKILL.md/HOOK.md 后，检查：

- [ ] `name:` 字段没有引号
- [ ] `description:` 字段没有引号
- [ ] `metadata:` 字段格式正确
- [ ] 有正确的 `---` 分隔符

### 3. 验证
创建后用命令验证：

```bash
# 检查 hook 是否被发现
openclaw hooks list

# 查看详细信息
openclaw hooks info my-hook
```

## 📚 参考

- OpenClaw Hooks 文档：https://docs.openclaw.ai/automation/hooks
- YAML 规范：https://yaml.org/spec/1.2/spec.html

---

**记住：YAML frontmatter 中，description 和 name 字段不要用引号！**
