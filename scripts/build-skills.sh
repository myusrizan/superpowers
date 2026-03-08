#!/usr/bin/env bash
# build-skills.sh
# Rebuilds the skills/ folder from custom-skills/.
# Called automatically by hooks/session-start on every session.
# Run manually to rebuild without starting a session:
#   ./scripts/build-skills.sh [--code | --no-code]
#
# Modes:
#   (no flag)  — all categories (default)
#   --code     — coding, agents, git only (+ using-superpowers bootstrap)
#   --no-code  — meta, qol, thinking only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC="${PLUGIN_ROOT}/custom-skills"
DEST="${PLUGIN_ROOT}/skills"

# Parse install mode
MODE="${1:-}"
case "$MODE" in
    --code)
        CATEGORIES="coding agents git"
        echo "build-skills: Building code-only profile (coding, agents, git + using-superpowers bootstrap)." >&2
        ;;
    --no-code)
        CATEGORIES="meta qol thinking"
        echo "build-skills: Building no-code profile (meta, qol, thinking)." >&2
        ;;
    "")
        CATEGORIES="coding agents git meta qol thinking"
        echo "build-skills: Building full profile (all categories)." >&2
        ;;
    *)
        echo "build-skills: ERROR — unknown mode '${MODE}'. Valid options: --code, --no-code, or omit for all." >&2
        exit 1
        ;;
esac
export BUILD_CATEGORIES="$CATEGORIES"

# Validate source exists
if [ ! -d "$SRC" ]; then
    echo "build-skills: ERROR — custom-skills/ not found at ${SRC}" >&2
    exit 1
fi

# Auto-generate skill catalog in using-superpowers/SKILL.md from frontmatter
catalog_source="${SRC}/meta/using-superpowers/SKILL.md"
if [ -f "$catalog_source" ] && command -v python3 >/dev/null 2>&1; then
    SRC="$SRC" CATALOG="$catalog_source" BUILD_CATEGORIES="$BUILD_CATEGORIES" python3 << 'PYEOF'
import os, re, sys

src = os.environ['SRC']
catalog_file = os.environ['CATALOG']
allowed = set(os.environ.get('BUILD_CATEGORIES', '').split())

CATEGORY_META = [
    ('coding',   'Software development workflow'),
    ('agents',   'Agent orchestration'),
    ('git',      'Version control'),
    ('thinking', 'Intellectual engagement'),
    ('qol',      'Output production'),
    ('meta',     'Skill system'),
]

# Filter to only the categories in this build profile
# Always include meta for using-superpowers (catalog bootstrap), even in --code mode
if allowed:
    filtered = [(c, d) for c, d in CATEGORY_META if c in allowed or c == 'meta']
else:
    filtered = CATEGORY_META

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
    # Strip "Use [qualifiers] when " prefix (handles "Use when", "Use ONLY when", etc.)
    desc = re.sub(r'^[Uu]se (?:\w+ )*when ', '', desc)
    return desc[0].upper() + desc[1:] if desc else desc

catalog_lines = []
for cat, cat_desc in filtered:
    cat_dir = os.path.join(src, cat)
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
    catalog_lines.append(f'**{cat}/** — {cat_desc}')
    catalog_lines.append('| Skill | Use when |')
    catalog_lines.append('|-------|----------|')
    for name, desc in skills:
        catalog_lines.append(f'| `{name}` | {desc} |')
    catalog_lines.append('')

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

# Warn if skill count is approaching cognitive overload threshold
skill_count = sum(1 for line in catalog_lines if line.startswith('| `'))
WARN_THRESHOLD = 60
if skill_count >= WARN_THRESHOLD:
    print(f"build-skills: WARNING — {skill_count} skills in catalog (threshold: {WARN_THRESHOLD}). Consider splitting catalog into core/extended.", file=sys.stderr)
else:
    print(f"build-skills: {skill_count} skills in catalog.", file=sys.stderr)
PYEOF
fi

# Rebuild destination — copy only the categories in this build profile
rm -rf "$DEST"
mkdir -p "$DEST"

for cat in $CATEGORIES; do
    if [ -d "${SRC}/${cat}" ]; then
        cp -r "${SRC}/${cat}" "${DEST}/${cat}"
    fi
done

# Always copy meta/using-superpowers (bootstrap skill for catalog routing)
# even in --code mode, so Claude knows which skills are available
if [[ "$MODE" == "--code" ]] && [ -d "${SRC}/meta/using-superpowers" ]; then
    mkdir -p "${DEST}/meta"
    cp -r "${SRC}/meta/using-superpowers" "${DEST}/meta/using-superpowers"
fi

# Ensure logs/ directory exists for capturing-context skill
mkdir -p "${PLUGIN_ROOT}/logs"

# Package skills as .zip files in dist/ for upload compatibility.
# Upload dialog accepts: .zip/.skill file containing SKILL.md, or standalone .md with YAML frontmatter.
# Skills with multiple files need .zip; packaging all skills as .zip handles both cases uniformly.
DIST="${PLUGIN_ROOT}/dist"
rm -rf "$DIST"
mkdir -p "$DIST"

while IFS= read -r skill_md; do
    skill_dir="$(dirname "$skill_md")"
    skill_name="$(basename "$skill_dir")"
    (cd "$skill_dir" && zip -qr "${DIST}/${skill_name}.zip" .)
done < <(find "$DEST" -name "SKILL.md")

skill_zip_count=$(find "$DIST" -name "*.zip" | wc -l | tr -d ' ')
echo "build-skills: Packaged ${skill_zip_count} skills as .zip files in dist/." >&2
