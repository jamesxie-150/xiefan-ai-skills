#!/bin/bash
# sync-project-skills.sh
# 将 projects/*/skills/*/ 下的项目专属 Skill 同步（符号链接）到 .github/skills/
# 使 VS Code Copilot 能发现这些项目专属 Skill
#
# 用法：bash scripts/sync-project-skills.sh
# 建议在每次 git pull 后执行

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/.github/skills"
PROJECTS_DIR="${REPO_ROOT}/projects"

echo "=== 项目 Skill 同步工具 ==="
echo "仓库根目录: ${REPO_ROOT}"
echo "Skills 目录: ${SKILLS_DIR}"
echo "Projects 目录: ${PROJECTS_DIR}"
echo ""

# 确保目标目录存在
mkdir -p "${SKILLS_DIR}"

# 统计
synced=0
skipped=0
errors=0

# 遍历所有项目
for project_dir in "${PROJECTS_DIR}"/*/; do
    project_name=$(basename "${project_dir}")
    skills_source="${project_dir}skills"

    # 跳过没有 skills/ 目录的项目
    if [ ! -d "${skills_source}" ]; then
        echo "[跳过] ${project_name}: 没有 skills/ 目录"
        continue
    fi

    echo "[扫描] 项目: ${project_name}"

    # 遍历项目下的每个 skill
    for skill_dir in "${skills_source}"/*/; do
        [ -d "${skill_dir}" ] || continue

        skill_name=$(basename "${skill_dir}")
        skill_md="${skill_dir}SKILL.md"
        target_link="${SKILLS_DIR}/${skill_name}"

        # 检查 SKILL.md 是否存在
        if [ ! -f "${skill_md}" ]; then
            echo "  [错误] ${skill_name}: 缺少 SKILL.md"
            ((errors++))
            continue
        fi

        # 如果目标已存在
        if [ -e "${target_link}" ]; then
            if [ -L "${target_link}" ]; then
                # 已经是符号链接，检查是否指向正确位置
                current_target=$(readlink -f "${target_link}")
                expected_target=$(readlink -f "${skill_dir}")
                if [ "${current_target}" = "${expected_target}" ]; then
                    echo "  [已同步] ${skill_name}"
                    ((skipped++))
                    continue
                else
                    # 指向错误位置，删除重建
                    rm "${target_link}"
                fi
            else
                # 不是符号链接（是真实目录），跳过，避免覆盖公共 skill
                echo "  [跳过] ${skill_name}: 已存在非链接目录（可能是公共 Skill）"
                ((skipped++))
                continue
            fi
        fi

        # 创建符号链接
        ln -s "${skill_dir}" "${target_link}"
        echo "  [已链接] ${skill_name} → ${skill_dir}"
        ((synced++))
    done
done

echo ""
echo "=== 同步完成 ==="
echo "新同步: ${synced}"
echo "已跳过: ${skipped}"
echo "错误:   ${errors}"
echo ""

# 列出当前所有 skill
echo "当前 .github/skills/ 下的所有 Skill:"
for skill in "${SKILLS_DIR}"/*/; do
    [ -d "${skill}" ] || continue
    name=$(basename "${skill}")
    if [ -L "${skill}" ]; then
        source=$(readlink "${skill}")
        echo "  📎 ${name} → ${source} (项目专属)"
    else
        echo "  📦 ${name} (公共)"
    fi
done
