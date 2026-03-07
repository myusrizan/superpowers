#!/usr/bin/env bash
# build-skills.sh
# Rebuilds the skills/ folder from custom-skills/.
# Called automatically by hooks/session-start on every session.
# Run manually to rebuild without starting a session:
#   ./scripts/build-skills.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SRC="${PLUGIN_ROOT}/custom-skills"
DEST="${PLUGIN_ROOT}/skills"

# Validate source exists
if [ ! -d "$SRC" ]; then
    echo "build-skills: ERROR — custom-skills/ not found at ${SRC}" >&2
    exit 1
fi

# Auto-generate skill catalog in using-superpowers/SKILL.md from frontmatter
catalog_source="${SRC}/meta/using-superpowers/SKILL.md"
if [ -f "$catalog_source" ] && command -v python3 >/dev/null 2>&1; then
    SRC="$SRC" CATALOG="$catalog_source" python3 << 'PYEOF'
import os, re, sys

src = os.environ['SRC']
catalog_file = os.environ['CATALOG']

CATEGORY_META = [
    ('coding',   'Software development workflow'),
    ('agents',   'Agent orchestration'),
    ('git',      'Version control'),
    ('thinking', 'Intellectual engagement'),
    ('qol',      'Output production'),
    ('meta',     'Skill system'),
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
    # Strip "Use [qualifiers] when " prefix (handles "Use when", "Use ONLY when", etc.)
    desc = re.sub(r'^[Uu]se (?:\w+ )*when ', '', desc)
    return desc[0].upper() + desc[1:] if desc else desc

catalog_lines = []
for cat, cat_desc in CATEGORY_META:
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

# Rebuild destination
rm -rf "$DEST"
cp -r "$SRC" "$DEST"

# Ensure logs/ directory exists for capturing-context skill
mkdir -p "${PLUGIN_ROOT}/logs"
