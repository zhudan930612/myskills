---
name: "merge-branch-to-main"
description: "把功能分支合并到 main 的完整流程（管理员验收制协作模型）：管理员可走本地合并直接 push（不走 PR，enforce_admins=false 已允许），或走 PR + code owner 批准；协作者必须走 PR。触发：合并分支、合分支、合并到主分支、把 XX 合到 main、merge to main、提 PR、合并后删除分支。"
version: 1
created: "2026-08-21"
updated: "2026-08-21"
---
## When to Use
触发词分流：说「**合并分支 / 合并到 main / merge to main / 把 XX 合到 main / 合分支**」→ 直接合并不走 PR（路径 A，管理员快捷合并）；说「**提 PR / 走 PR / 提合并请求**」→ 走 PR 流程（路径 B）。当前分支是 main 时先确认要合并哪个分支/哪个 PR。适用于 main 受保护（必须 PR + code owner review）或管理员可 bypass 的仓库；非受保护仓库可直接本地 merge + push（跳过 PR 步骤）。

## Procedure
1. 前置检查：git status --short 必须干净（有未提交改动则停下让用户处理）；确认当前分支与角色（管理员 / 协作者 write）；git fetch origin 获取远程最新
2. 同步基线：git checkout main + git pull --ff-only；若本地 main 有未推送提交，先向用户说明（避免把未验收的本地提交随合并推出去）
3. **路径 A：管理员快捷合并（直接合并不走 PR）**——触发词「合并分支/合并到 main/merge to main/把 XX 合到 main」；仅当仓库 enforce_admins=false（管理员可 bypass）且用户确认：git merge <分支> --no-ff（保留功能分支历史；要线性历史用 --ff-only）→ 冲突处理（步骤 5）→ 验证（步骤 6）→ git push origin main 直接推送（受保护 main 对非管理员仍拒绝）
4. **路径 B：标准 PR 流程（走 PR）**——触发词「提 PR/走 PR/提合并请求」；协作者自己提 PR（推荐，管理员 Review→Approve→Merge 走 code owner review）；或管理员帮提（PR 作者=管理员不能自批，合并走 admin bypass）；**合并后远程分支由 GitHub 自动删除**（仓库已配置 delete_branch_on_merge=true，无需手动操作）
5. 冲突处理（本地 merge 或 PR 分支需 rebase 时）：add/add——两边各自新增同名文件，比较 git show 两边版本保留更新/更完整的一版；content——两拨功能不重叠则手工合并共存，重叠按语义取舍；疑难冲突停下向用户展示让用户决定；解决后 git add 标记
6. 验证：跑项目验证命令（至少单元测试 + 构建；涉及 server/数据脚本时对应命令也跑）；PR 合并前确认 CI/安全检查通过
7. 收尾-本地分支：功能完成 → git branch -d <分支>（未合并会被 -d 自动拒绝）；还要继续开发 → git checkout <分支> && git merge main 同步新基线再继续，避免基于过期基线提交
8. 收尾-验证同步：git status -sb 无 ahead/behind；git ls-remote origin <分支> 无结果（远程已删）

## Pitfalls
- 直接 git push origin main 对**非管理员**会被拒（GH006 受保护分支）——协作者必须走 PR；管理员 direct push 仅当 enforce_admins=false
- 管理员直接 push 合并绕过了 review 记录（无 PR/approval 留痕）——需要留痕时走 PR；PR 合并后的远程分支删除已由 GitHub 自动处理（delete_branch_on_merge=true）
- PR 作者不能批准自己的 PR（GitHub 硬规则）：管理员帮协作者提的 PR 无法走正式 approve，合并用 admin bypass
- 远程分支删除后本地继续提交再 push → 远程分支会基于旧基线重建（git 默认重建不存在的远程分支）；继续开发前先 git merge main 同步基线
- 合并前不检查工作区干净 → 未提交改动混进合并；不 fetch/不 pull --ff-only → 基于过期 main
- 冲突无脑选 ours/theirs → 丢失另一分支功能；两拨不重叠功能通常需共存（如两套菜单在同一组件）
- push 被拒后强推 --force → 覆盖远程提交，禁止；普通分支用 pull --rebase
- 测试不跑就合并 → 产物可能编译失败/测试红；PR 合并前确认密钥扫描（GitGuardian）无告警
- 删除分支用 git branch -d（安全）而非 -D；本地 main 有未推送提交时不要随合并一起推（先与用户确认）
- 合并过程中 dev server/其他终端可能 checkout 到别的分支造成状态漂移，操作前确认 git branch --show-current

## Verification
1. 路径 A（direct push）：git push origin main 成功且 git status -sb 无 ahead/behind
2. 路径 B（PR）：PR state=MERGED（gh pr view <PR号> --json state）且 git fetch origin 后 git log origin/main 能看到功能提交；远程分支已自动删除（ls-remote 无输出）
3. 本地同步：git checkout main && git pull 后 git status -sb 无 ahead/behind
4. 验证命令通过（单元测试/构建/对应数据脚本）；grep -rn '<<<<<<<' 冲突目标文件无残留标记
5. 若删本地分支：git branch 列表无功能分支；git branch -d 已合并校验