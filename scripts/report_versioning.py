from git import Repo
from semantic_release.version import Version
from semantic_release.history import get_commit_parser
from datetime import datetime
import os

repo = Repo(".")
commits = list(repo.iter_commits("origin/main~1..HEAD"))

# 1️⃣ Decide highest version bump
bump = "none"
for c in commits:
    msg = c.message
    if msg.startswith("BREAKING_CHANGE:") in msg:
        bump = "major"
        break
    elif msg.startswith("feat:") and bump != "major":
        bump = "minor"
    elif msg.startswith("fix:") and bump not in ["major", "minor"]:
        bump = "patch"

if bump == "none":
    exit(0)

# 2️⃣ Detect changed reports
changed_files = repo.git.diff("origin/main~1", "HEAD", name_only=True).splitlines()
reports = {f.split("/")[0] for f in changed_files if f.endswith(".dat")}

# 3️⃣ Update each report
for report in reports:
    version_file = f"{report}/version.txt"
    changelog = f"{report}/CHANGELOG.md"

    if not os.path.exists(version_file):
        continue

    current = Version.parse(open(version_file).read().strip())
    new = current.bump(bump)

    open(version_file, "w").write(str(new))

    with open(changelog, "a") as cl:
        cl.write(f"\n## {new} ({datetime.utcnow().date()})\n")
        for c in commits:
            cl.write(
                f"- {'Reporting' if 'feat:' in c.message else 'Bug-fixing'}: "
                f"{c.message.strip()}\n"
                f"  Commit: {c.hexsha}\n"
            )

    repo.git.add(version_file, changelog)

repo.index.commit("chore: report-level version bump")
