#!/usr/bin/env python3
"""O207 test helper: inject a /tmp kos-pm-next.py fixture via KOS_PM_NEXT_TOOL.

kos_handoff.py delegates department-pool parsing to an external kos-pm-next.py
tool (resolved from KOS_PM_NEXT_TOOL, else the per-user external KOS home).
CI runners and isolated-HOME test runs have no external tool, so every test
case that exercises a kos_handoff dispatch surface must install this fixture
tool into a TemporaryDirectory, point KOS_PM_NEXT_TOOL at it, and clear the
kos_handoff external-module cache between cases so no cached module state
leaks across tests.

The fixture module mirrors the real tool's load_department_pools(path)
contract (parse the ROSTER.md department-pool table into
{pool_name: [members]}, require exactly 6 pools, SystemExit(2) on a missing
roster or malformed table). The optional /tmp roster fixture carries the
same standard 6-pool table used by every dispatch test. Nothing here is
ever a real ledger path.
"""
import os
import re
import sys
import tempfile
from pathlib import Path

PM_NEXT_ENV = "KOS_PM_NEXT_TOOL"
ROSTER_ENV = "KOS_ROSTER"

FIXTURE_TOOL_SOURCE = '''#!/usr/bin/env python3
"""Test-fixture stand-in for the external kos-pm-next.py (O207 contract).

Implements the same load_department_pools(path) contract as the real PM
dispatcher tool: parse the ROSTER.md department-pool table into
{pool_name: [members]}, require exactly 6 pools, and fail with SystemExit(2)
on a missing roster or a malformed table. Written into a TemporaryDirectory
by tests and injected via KOS_PM_NEXT_TOOL; never a real ledger path.
"""
import re
import sys
from pathlib import Path


def load_department_pools(path):
    """Parse the six department pools and their members from ROSTER.md."""
    path = Path(path)
    if not path.is_file():
        print("kos-pm-next.py: error: 找不到花名册 %s" % path, file=sys.stderr)
        raise SystemExit(2)
    pools = {}
    in_table = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith("|"):
            if in_table and pools:
                break
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 2:
            continue
        if cells[0] == "部门池":
            in_table = True
            continue
        if not in_table or set(cells[0]) <= set("-: "):
            continue
        members = []
        member_cell = re.sub(r"[（(][^）)]*[）)]", "", cells[1])
        for part in re.split(r"[、,，]", member_cell):
            name = part.strip()
            if name:
                members.append(name)
        if not members:
            print("kos-pm-next.py: error: 部门池 %s 没有成员" % cells[0], file=sys.stderr)
            raise SystemExit(2)
        pools[cells[0]] = members
    if len(pools) != 6:
        found = "、".join(pools) or "无"
        print(
            "kos-pm-next.py: error: 花名册应有 6 个部门池，实际解析到 %d 个（%s）" % (len(pools), found),
            file=sys.stderr,
        )
        raise SystemExit(2)
    return pools
'''

# Standard 6-pool fixture roster (same table every dispatch test uses).
FIXTURE_ROSTER = """# 名册（测试夹具）
| 名字 | 角色 | 当前担任者 | 角色卡 |
|---|---|---|---|
| Jack | PM | Fixture | Jack.md |
| Pete | Preflight | Fixture | Pete.md |

## 部门池与流转规则（测试夹具）

按部门派发时（除 PM 外共六个部门池），各部门全员名单如下。

| 部门池 | 全员名单 | 对应单卡 |
|---|---|---|
| Preflight 部门 | Pete、Reed | Pete.md、Reed.md |
| Executor（代码）部门 | Cole、Lucy、Ivy | Cole.md、Lucy.md、Ivy.md |
| Executor（文档）部门 | Sam、Wendy | Sam.md、Wendy.md |
| Quality 部门 | Quinn、Maya | Quinn.md、Maya.md |
| Publish 部门 | Wendy、Sam | Wendy.md、Sam.md |
| 架构 / 设计 部门 | Nick、Alex | Nick.md、Alex.md |
"""


class FixtureHandle:
    """Save token returned by install(): fixture paths + previous env values."""

    def __init__(self, tool: Path, roster: Path, saved_env: dict, tmp):
        self.tool = tool
        self.roster = roster
        self._saved_env = saved_env
        self._tmp = tmp


def reset_module_cache():
    """Drop kos_handoff's cached external-tool module (if loaded in-process).

    Each test case must re-resolve KOS_PM_NEXT_TOOL instead of inheriting a
    module cached by a previous case. Subprocess-based cases are unaffected:
    they start a fresh interpreter and load the tool from scratch.
    """
    module = sys.modules.get("kos_handoff")
    if module is not None and hasattr(module, "_PM_NEXT_MODULE"):
        module._PM_NEXT_MODULE = None


def write_fixture_tool(root: Path) -> Path:
    """Write the fixture tool under <root>/tools/ and return its path."""
    tool = Path(root) / "tools" / "kos-pm-next.py"
    tool.parent.mkdir(parents=True, exist_ok=True)
    tool.write_text(FIXTURE_TOOL_SOURCE, encoding="utf-8")
    return tool


def write_fixture_roster(root: Path) -> Path:
    """Write the standard 6-pool fixture roster under <root>."""
    roster = Path(root) / "ROSTER.md"
    roster.write_text(FIXTURE_ROSTER, encoding="utf-8")
    return roster


def install(set_roster: bool = False) -> FixtureHandle:
    """Install the fixture tool into a fresh TemporaryDirectory.

    Sets KOS_PM_NEXT_TOOL to the fixture tool and resets the kos_handoff
    module cache. With set_roster=True it also points KOS_ROSTER at the
    bundled /tmp 6-pool roster (for test cases whose subprocesses would
    otherwise fall through to the per-user external HOME roster). Cases that
    manage KOS_ROSTER themselves keep set_roster=False.
    """
    tmp = tempfile.TemporaryDirectory(prefix="kos-pm-next-fixture-")
    tool = write_fixture_tool(Path(tmp.name))
    roster = write_fixture_roster(Path(tmp.name))
    saved_env = {PM_NEXT_ENV: os.environ.get(PM_NEXT_ENV)}
    if set_roster:
        saved_env[ROSTER_ENV] = os.environ.get(ROSTER_ENV)
    os.environ[PM_NEXT_ENV] = str(tool)
    if set_roster:
        os.environ[ROSTER_ENV] = str(roster)
    reset_module_cache()
    return FixtureHandle(tool, roster, saved_env, tmp)


def uninstall(handle: FixtureHandle):
    """Restore the previous env values and drop the fixture directory."""
    for key, old in handle._saved_env.items():
        if old is None:
            os.environ.pop(key, None)
        else:
            os.environ[key] = old
    reset_module_cache()
    handle._tmp.cleanup()
