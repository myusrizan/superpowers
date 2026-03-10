#!/usr/bin/env bash
# build-skills.sh
# Rebuilds skills/ and dist/ from custom-skills/chat/ and custom-skills/plugin/.
#
# Output:
#   chat/    → dist/   (zipped .zip files — upload to Claude directly)
#   plugin/  → skills/ (copied flat — loaded by Claude Code plugin)
#
# Usage:
#   ./scripts/build-skills.sh           — build both chat and plugin (default)
#   ./scripts/build-skills.sh --chat    — build chat skills only
#   ./scripts/build-skills.sh --plugin  — build plugin skills only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CUSTOM="${ROOT}/custom-skills"
CHAT_SRC="${CUSTOM}/chat"
PLUGIN_SRC="${CUSTOM}/plugin"

SKILLS_DEST="${ROOT}/skills"
DIST_DEST="${ROOT}/dist"

# Parse mode
MODE="${1:-}"
case "$MODE" in
    --chat)
        BUILD_CHAT=1; BUILD_PLUGIN=0
        echo "build-skills: Building chat skills only." >&2
        ;;
    --plugin)
        BUILD_CHAT=0; BUILD_PLUGIN=1
        echo "build-skills: Building plugin skills only." >&2
        ;;
    "")
        BUILD_CHAT=1; BUILD_PLUGIN=1
        echo "build-skills: Building chat + plugin skills." >&2
        ;;
    *)
        echo "build-skills: ERROR — unknown mode '${MODE}'. Valid options: --chat, --plugin, or omit for both." >&2
        exit 1
        ;;
esac

# Validate source dirs exist
[ -d "$CHAT_SRC" ]   || { echo "build-skills: ERROR — custom-skills/chat/ not found."   >&2; exit 1; }
[ -d "$PLUGIN_SRC" ] || { echo "build-skills: ERROR — custom-skills/plugin/ not found." >&2; exit 1; }

# ---------------------------------------------------------------------------
# Auto-generate skill catalog in using-superpowers/SKILL.md
# ---------------------------------------------------------------------------
catalog_source="${CHAT_SRC}/meta/using-superpowers/SKILL.md"
if [ -f "$catalog_source" ] && command -v python3 >/dev/null 2>&1; then
    BUILD_CHAT="$BUILD_CHAT" BUILD_PLUGIN="$BUILD_PLUGIN" \
    CHAT_SRC="$CHAT_SRC" PLUGIN_SRC="$PLUGIN_SRC" \
    CATALOG="$catalog_source" python3 << 'PYEOF'
import os, re, sys

chat_src   = os.environ['CHAT_SRC']
plugin_src = os.environ['PLUGIN_SRC']
catalog_file = os.environ['CATALOG']
build_chat   = os.environ['BUILD_CHAT'] == '1'
build_plugin = os.environ['BUILD_PLUGIN'] == '1'

CHAT_CATEGORIES = [
    ('meta',     'Skill system'),
    ('qol',      'Output production'),
    ('thinking', 'Intellectual engagement'),
]

PLUGIN_CATEGORIES = [
    ('coding',  'Software development workflow'),
    ('agents',  'Agent orchestration'),
    ('git',     'Version control'),
    ('meta',    'Discovery & docs'),
]

def parse_frontmatter(path):
    try:
        with open(path) as f:
            content = f.read()
    except Exception:
        return {}
    m = re.match(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
    if not m:
        return {}
    fm = {}
    for line in m.group(1).splitlines():
        if ':' in line:
            k, _, v = line.partition(':')
            fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm

def shorten_desc(desc):
    desc = re.sub(r'^[Uu]se (?:\w+ )*when ', '', desc)
    return desc[0].upper() + desc[1:] if desc else desc

def collect_skills(base, categories):
    lines = []
    for cat, cat_desc in categories:
        cat_dir = os.path.join(base, cat)
        if not os.path.isdir(cat_dir):
            continue
        skills = []
        for skill_dir in sorted(os.listdir(cat_dir)):
            skill_md = os.path.join(cat_dir, skill_dir, 'SKILL.md')
            if not os.path.isfile(skill_md):
                continue
            fm = parse_frontmatter(skill_md)
            name = fm.get('name', '')
            desc = fm.get('description', '')
            if not name or name == 'using-superpowers':
                continue
            skills.append((name, shorten_desc(desc)))
        if not skills:
            continue
        lines.append(f'**{cat}/** — {cat_desc}')
        lines.append('| Skill | Use when |')
        lines.append('|-------|----------|')
        for name, desc in skills:
            lines.append(f'| `{name}` | {desc} |')
        lines.append('')
    return lines

catalog_lines = []

if build_chat:
    catalog_lines.append('### Chat Skills')
    catalog_lines.append('')
    catalog_lines.extend(collect_skills(chat_src, CHAT_CATEGORIES))

if build_plugin:
    catalog_lines.append('### Plugin Skills')
    catalog_lines.append('')
    catalog_lines.extend(collect_skills(plugin_src, PLUGIN_CATEGORIES))

catalog_content = '\n'.join(catalog_lines).rstrip('\n')

try:
    with open(catalog_file) as f:
        original = f.read()
except Exception as e:
    print(f"build-skills: ERROR reading catalog file: {e}", file=sys.stderr)
    sys.exit(1)

if '<!-- CATALOG_START -->' not in original:
    print("build-skills: WARNING — no CATALOG_START marker in using-superpowers/SKILL.md; catalog not updated", file=sys.stderr)
    sys.exit(0)

new_content = re.sub(
    r'<!-- CATALOG_START -->.*?<!-- CATALOG_END -->',
    f'<!-- CATALOG_START -->\n{catalog_content}\n<!-- CATALOG_END -->',
    original,
    flags=re.DOTALL
)
if new_content != original:
    with open(catalog_file, 'w') as f:
        f.write(new_content)
    print("build-skills: Catalog regenerated in using-superpowers/SKILL.md", file=sys.stderr)

skill_count = sum(1 for line in catalog_lines if line.startswith('| `'))
WARN_THRESHOLD = 60
if skill_count >= WARN_THRESHOLD:
    print(f"build-skills: WARNING — {skill_count} skills in catalog (threshold: {WARN_THRESHOLD}). Consider splitting.", file=sys.stderr)
else:
    print(f"build-skills: {skill_count} skills in catalog.", file=sys.stderr)
PYEOF
fi

# ---------------------------------------------------------------------------
# PLUGIN skills → skills/ (flat copy for Claude Code)
# ---------------------------------------------------------------------------
if [ "$BUILD_PLUGIN" -eq 1 ]; then
    rm -rf "$SKILLS_DEST"
    mkdir -p "$SKILLS_DEST"

    for cat_dir in "${PLUGIN_SRC}"/*/; do
        cat="$(basename "$cat_dir")"
        if [ -d "$cat_dir" ]; then
            cp -r "$cat_dir" "${SKILLS_DEST}/${cat}"
        fi
    done

    plugin_count=$(find "$SKILLS_DEST" -name "SKILL.md" | wc -l | tr -d ' ')
    echo "build-skills: ${plugin_count} plugin skills copied to skills/." >&2
fi

# ---------------------------------------------------------------------------
# CHAT skills → dist/ (zipped for Claude upload)
# ---------------------------------------------------------------------------
if [ "$BUILD_CHAT" -eq 1 ]; then
    rm -rf "$DIST_DEST"
    mkdir -p "$DIST_DEST"

    find "$CHAT_SRC" -name "SKILL.md" | while IFS= read -r skill_md; do
        skill_dir="$(dirname "$skill_md")"
        skill_name="$(basename "$skill_dir")"
        (cd "$skill_dir" && zip -qr "${DIST_DEST}/${skill_name}.zip" .)
    done

    chat_count=$(find "$DIST_DEST" -name "*.zip" | wc -l | tr -d ' ')
    echo "build-skills: ${chat_count} chat skills zipped to dist/." >&2
fi

# Ensure logs/ directory exists
mkdir -p "${ROOT}/logs"
