import subprocess
import sys
from pathlib import Path
from datetime import date

REPO_URL = subprocess.check_output(
    ["git", "config", "--get", "remote.origin.url"],
    text=True
).strip().replace(".git", "")

def run(cmd):
    return subprocess.check_output(cmd, text=True).strip()

def get_commits():
    # All commits introduced by the merge
    return run(["git", "log", "--pretty=%H|%s", "origin/main~1..HEAD"]).splitlines()

def bump_type(commits):
    if any(c.split("|")[1].startswith("BREAKING_CHANGE:") for c in commits):
        return "major", "Breaking Change"
    if any(c.split("|")[1].startswith("feat:") for c in commits):
        return "minor", "Feature"
    if any(c.split("|")[1].startswith("fix:") for c in commits):
        return "patch", "Bug Fix"
    return None, None

def changed_reports():
    files = run(["git", "diff", "--name-only", "origin/main~1", "HEAD"]).splitlines()
    return sorted({
        Path(f).parts[1]
        for f in files
        if f.startswith("SNOWFLAKE_DBT_T20/") and f.endswith(".dat")
    })

def bump_version(version, bump):
    major, minor, patch = map(int, version.split("."))
    if bump == "major":
        return f"{major+1}.0.0"
    if bump == "minor":
        return f"{major}.{minor+1}.0"
    return f"{major}.{minor}.{patch+1}"

def main():
    commits = get_commits()
    bump, label = bump_type(commits)

    if not bump:
        print("No version keyword found. Skipping.")
        return

    today = date.today().isoformat()

    for report in changed_reports():
        base = Path("SNOWFLAKE_DBT_T20") / report
        version_file = base / "version.txt"
        changelog = base / "CHANGELOG.md"

        if not version_file.exists():
            continue

        new_version = bump_version(version_file.read_text().strip(), bump)
        version_file.write_text(new_version)

        with changelog.open("a") as f:
            f.write(f"\n## {new_version} ({today})\n")
            for c in commits:
                sha, msg = c.split("|", 1)
                clean = msg.split(":", 1)[-1].strip()
                f.write(
                    f"- **{label}**: {clean} "
                    f"([`{sha[:7]}`]({REPO_URL}/commit/{sha}))\n"
                )

        run(["git", "add", str(version_file), str(changelog)])
        run(["git", "tag", f"{report}-v{new_version}"])

if __name__ == "__main__":
    main()
