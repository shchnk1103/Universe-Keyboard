#!/usr/bin/env python3
"""kos-pkg-lint.py --start <本阶段起点提交SHA> [--prev <上一阶段任务目录>] [--stage <本阶段目录>（自动选各类最高修订版与最新章程）] [--charter <章程>] [包文件...]
O1/O19：包与包之间的机械一致性检查（只读）。退出码 1=有错误，0=仅提示或无问题。
检查：
 E1 起点类 SHA：出现在“起点/父提交/HEAD/起点提交”语境里的 40 位 SHA 必须等于 --start（或同一行同时写了“取代/历史/旧”视为引用旧物）。
 E2 遗留 SHA：出现在 --prev 目录各包里、但本阶段章程（或本批包）并未自己声明的 40 位 SHA，若出现在本批包里 → 报“可能是拷贝遗留”。
 E3 参数键：包里 kos-block.sh 命令行的 key=值 的 key 必须在章程第 4 条键表里。
 E4 引用路径：包里的绝对路径（排除 reports/、scratch/、worktree、含 < > 的占位）必须存在。
 E5 worktree 路径：新建或使用的路径不得含主仓库 .worktrees/，且须在 ~/.kos-work/Universe-Keyboard/ 下；清理或历史描述豁免。
 E6 交接脚本：禁止 render_handoff_v1.py；样式 B 的 kos_handoff.py 及同包 scripts/kos、tools 脚本必须存在。
 E7 本地门禁：禁止 CODE_SIGNING_IDENTITY=-；声明 full 或签名 Keychain 命令时六步必须齐全，且不得把托管重试说成本地命令。
 E8 冻结输入：要求校验或标明冻结输入时，必须有反引号路径与 64 位哈希配对。
 W1 数字短语：同一“名词+数字”（如 7 条断言、18 项跳过）在不同包里数字不同 → 提示人工核对。
 W2 量词：同一份文本里既有“各自/分别/逐项”又有“或”描述同一类枚举时提示（启发式：同一行有“或”且另一包同关键词的行有“各自/分别”）。
 W3 编号条目：同一编号内容差异大时提示。
 W4 变量名：变量后紧跟非 ASCII 字符时提示。
 W5 哈希配对：绝对 Markdown 路径附近有 64 位哈希但缺少可解析配对时提示。
"""
E7_REQUIRED_TOKENS = (
    ("swift-format", "lint"),
    ("swift test", "KeyboardCore"),
    ("RimeBridgeTests",),
    ('scheme "Universe Keyboard"', " test"),
    ("CODE_SIGN_IDENTITY=-", "-only-testing"),
    ("-configuration Release", " build"),
)

def main():
    import sys, re, os, collections
    args = sys.argv[1:]
    def opt(n):
        if n in args:
            i = args.index(n); v = args[i+1]; del args[i:i+2]; return v
    start = opt('--start'); prev = opt('--prev'); charter = opt('--charter'); stage = opt('--stage')
    files = args
    if stage:  # 自动选各类包的最高修订版与最新章程
        import glob, re as _re
        def rev(fn):
            m = _re.search(r'-r(\d+)\.md$', fn); return int(m.group(1)) if m else 0
        files = []
        for kind in ['pre', 'impl', 'quality', 'fix']:
            c = sorted(glob.glob(f'{stage}/instructions/task-package-{kind}*.md'), key=rev)
            if c: files.append(c[-1])
        cs = sorted(glob.glob(f'{stage}/STAGE-CHARTER*.md'), key=rev)
        if cs and not charter: charter = cs[-1]
    assert start and files, __doc__
    H = os.path.join(os.environ.get('KOS_HOME', os.path.expanduser('~/.kos-work')), os.environ.get('KOS_PROJECT', 'Universe-Keyboard'))
    err, warn = [], []
    txt = {f: open(f, encoding='utf-8').read() for f in files}
    if charter: txt[charter] = open(charter, encoding='utf-8').read()
    SHA = re.compile(r'(?<![0-9a-f])[0-9a-f]{40}(?![0-9a-f])')
    CTX = re.compile(r'起点|父提交|HEAD|基线提交')
    OLD = re.compile(r'取代|历史|旧|未下发|原包|上一')
    for f, t in txt.items():
        for n, line in enumerate(t.split('\n'), 1):
            for m in SHA.finditer(line):
                s = m.group(0)
                win = line[max(0, m.start()-40):m.end()+10]
                if CTX.search(win) and s != start and not OLD.search(line) and not (
                    '只读' in line and ('main HEAD' in line or '主检出' in line)
                ):
                    err.append(f"E1 {os.path.basename(f)}:{n} 起点类语境里的 SHA {s[:8]} ≠ 本阶段起点 {start[:8]}")
    if prev:
        prevsha = set()
        for pf in os.popen(f"ls {prev}/instructions/task-package-*.md {prev}/STAGE-CHARTER*.md 2>/dev/null").read().split():
            prevsha |= set(SHA.findall(open(pf, encoding='utf-8').read()))
        own = set()
        if charter: own = set(SHA.findall(txt[charter]))
        for f in files:
            for s in set(SHA.findall(txt[f])) & prevsha:
                if s != start and s not in own:
                    err.append(f"E2 {os.path.basename(f)} 含上一阶段包里的 SHA {s[:8]}，本阶段章程未声明：可能是拷贝遗留")
    keytab = set()
    if charter:
        for m in re.finditer(r'^\| ([a-zA-Z_]+) \|', txt[charter], re.M): keytab.add(m.group(1))
    if keytab:
        for f in files:
            for m in re.finditer(r'kos-block\.sh[^`\n]*', txt[f]):
                for k in re.findall(r'\s([a-zA-Z_]+)=', m.group(0)):
                    if k not in keytab: err.append(f"E3 {os.path.basename(f)} 的 kos-block 命令用了章程键表外的键 {k}")
    seen = set()
    for f in files:
        for m in re.finditer(r'(/Users/[^\s`（）()，。;；]+)', txt[f].replace('/Users/doubleshy0n/Dev/Universe Keyboard','/Users/doubleshy0n/Dev/UniverseKeyboard')):
            p = m.group(1).rstrip('.,:')
            if p in seen or '/Dev/UniverseKeyboard' in p or '/reports/' in p or '/scratch' in p or '/worktree' in p or '<' in p or p.endswith('/') or 'STAGE-LEDGER' in p: continue
            seen.add(p)
            if '/PM-LOG/open-' in p and p.endswith('.json'):
                continue
            if not os.path.exists(p): err.append(f"E4 {os.path.basename(f)} 引用的路径不存在：{p}")
    nums = collections.defaultdict(lambda: collections.defaultdict(set))
    for f in files:
        for m in re.finditer(r'(\d+) ?(条|项|个|次|轮|种|处)([一-鿿A-Za-z]{0,6})', txt[f]):
            noun = m.group(2) + m.group(3)[:4]
            nums[noun][m.group(1)].add(os.path.basename(f))
    for noun, d in nums.items():
        if len(d) > 1 and noun.strip():
            warn.append("W1 “数字+" + noun + "” 在不同位置数字不同：" + "; ".join(f"{k}→{sorted(v)}" for k, v in sorted(d.items())))
    kw = ['反例', '断言', '清单', '快照', '情形']
    for k in kw:
        each = [(os.path.basename(f), n) for f in files for n, l in enumerate(txt[f].split('\n'), 1) if k in l and re.search('各自|分别|逐项', l)]
        orr = [(os.path.basename(f), n) for f in files for n, l in enumerate(txt[f].split('\n'), 1) if k in l and re.search(r'[，、（(]或|或者|或 ', l)]
        if each and orr:
            warn.append(f"W2 关键词“{k}”既有“各自/分别/逐项”（{each[:2]}）又有“或”（{orr[:2]}）：确认量词对齐")

    # W3 同一编号条目（U1/U2…、(1)(2)…）在不同文件里的文字相似度过低 → 提示可能互相矛盾
    def items(txt):
        d = {}
        for l in txt.split('\n'):
            m = re.match(r'^\(?([A-Z]\d+)[\).]\s*(.*)$', l)
            if m: d[m.group(1)] = m.group(2)
        return d
    def grams(s):
        s = re.sub(r'\s+', '', s); return {s[i:i+3] for i in range(len(s)-2)}
    its = {f: items(t) for f, t in txt.items()}
    names = list(its)
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            for k in set(its[names[i]]) & set(its[names[j]]):
                a, b = grams(its[names[i]][k]), grams(its[names[j]][k])
                if a and b and len(a & b) / len(a | b) < 0.30:
                    warn.append(f"W3 条目 {k} 在 {os.path.basename(names[i])} 与 {os.path.basename(names[j])} 里文字差异很大，请人工核对是否矛盾")

    # W4 $var 后紧跟非 ASCII：LC_ALL=C + set -u 会当成不同变量名
    W4 = re.compile(r'\$([A-Za-z_][A-Za-z0-9_]*)[^\x00-\x7F]')
    for f, content in txt.items():
        for n, line in enumerate(content.split('\n'), 1):
            for m in W4.finditer(line):
                warn.append(
                    f"W4 {os.path.basename(f)}:{n} 变量 ${m.group(1)} 后紧跟非 ASCII 字符：LC_ALL=C 下 set -u 会报 unbound variable，请写成 ${{{m.group(1)}}}"
                )
    ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    KOS_ROOTS = (
        os.path.expanduser("~/.kos-work/Universe-Keyboard"),
        "/Users/doubleshy0n/.kos-work/Universe-Keyboard",
    )

    def _check_e5(files, txt, err):
        for f in txt:
            for n, line in enumerate(txt[f].split("\n"), 1):
                if re.search(r"拆除|迁出|历史|清理|删除|旧|已拆除|不建|不得建|不创建|只读", line) and not re.search(r"(?:新建|创建|使用)(?:本包|新的|新|\s*(?:git\s+)?worktree)", line, re.I):
                    continue
                for m in re.finditer(r"(?<![A-Za-z0-9_.-])(/Users/[^`\n，。；;）)]*|/[^\s`'\"，。；;）)]+|~/.kos-work/[^\s`'\"，。；;）)]+)", line):
                    path = m.group(1).strip().rstrip(".,:")
                    triggered = bool(re.search(r"worktree", line, re.I) and not re.search(r"(?:不建|不得建|不创建)\s*worktree", line, re.I) and path.startswith(("/", "~/")))
                    before = line[max(0, m.start() - 40):m.start()]
                    triggered = triggered or bool(re.search(r"(?:新建|创建|使用|建在|worktree 路径)[：:\s`]*$", before))
                    if not triggered or re.search(r"\.(?:py|sh)(?:\s|$)", path):
                        continue
                    normalized = os.path.normpath(os.path.expanduser(path))
                    legal = any(normalized == root or normalized.startswith(root + "/") for root in KOS_ROOTS)
                    if ".worktrees/" in path or not legal:
                        err.append(f"E5 {os.path.basename(f)}:{n} worktree 路径不在规范目录：{path}")

    def _existing(token):
        if "<" in token or ">" in token:
            return True
        path = token if os.path.isabs(token) else os.path.join(ROOT, token)
        return os.path.isfile(path)

    def _rule_explanation(line, token):
        # Commands remain actionable even when surrounded by prose about rules.
        stripped = re.sub(r"^\s*(?:(?:[-*+]\s+)|(?:\d+[.)]\s+))?", "", line).replace("`", "").strip()
        if re.match(r"(?:python\d*|xcodebuild|xcrun|swift|bash|sh|\./|/)", stripped):
            return False
        before, _, after = line.partition(token)
        rule = re.search(r"出现|禁止|禁用|不得|不应|旧值|修正|修订|误判|报错|错误|提示", before)
        consequence = re.search(r"报\s*E[67]|禁止|应为|不应|不得|误判|->|→", after)
        return bool(rule and consequence or re.search(r"禁止|禁用|不得|不应|旧值", before))

    def _script_rel(token):
        # normalize script refs to their scripts/kos/... or tools/... suffix so
        # absolute and relative spellings of the same file match each other
        for marker in ("scripts/kos/", "tools/"):
            i = token.find(marker)
            if i >= 0:
                return token[i:]
        return token

    def _allowed_new_files(content):
        # KOS-LINT-NEWFILE-001: script paths declared as （新增） inside the
        # allowed-write section are files the task will create; E6 must not
        # fire on them (the declaration makes them intentional, not typos).
        new_files = set()
        in_allow = False
        for line in content.splitlines():
            s = line.strip()
            if re.match(r"^#{1,6}\s*allow\b", s, re.I):
                in_allow = True
                continue
            if "允许写入路径" in line and (s.startswith("#") or s.startswith("- **") or s.startswith("**")):
                in_allow = True
                continue
            if s.startswith("#"):
                in_allow = False
                continue
            if in_allow and ("（新增）" in line or "(新增)" in line):
                for tok in re.findall(r"(?:/[^`'\"\n]*?/)?(?:scripts/kos|tools)/[^\s`'\"，。；;）)]+\.(?:py|sh)", line):
                    new_files.add(_script_rel(tok))
        return new_files

    def _check_e6(files, txt, err):
        flag_table = None
        flag_table_failed = False
        for f in txt:
            content = txt[f]
            if any("render_handoff_v1.py" in line and not _rule_explanation(line, "render_handoff_v1.py") for line in content.splitlines()):
                err.append(f"E6 {os.path.basename(f)} 引用了已废弃的 render_handoff_v1.py")
            handoff_lines = [line for line in content.splitlines() if re.search(r"(?:kos_handoff\.py\s+render|python3[^\n]*kos_handoff\.py)", line) and not re.search(r"出现|规则|解析到|规范目标", line)]
            if handoff_lines:
                handoff_content = "\n".join(handoff_lines)
                refs = re.findall(r"(?:/Users/[^`\n\"]*?/scripts/kos/kos_handoff\.py|scripts/kos/kos_handoff\.py|[^\s`'\"，。；;）)]*kos_handoff\.py)", handoff_content)
                for ref in refs or ["kos_handoff.py"]:
                    if not ref.endswith("scripts/kos/kos_handoff.py") or not _existing(ref):
                        err.append(f"E6 {os.path.basename(f)} 交接脚本不存在或不是 scripts/kos/kos_handoff.py：{ref}")
                # Keep the whole reference, including placeholders and absolute prefixes.
                pattern = r"(?:/[^`'\"\n]*?/)?(?:scripts/kos|tools)/[^\s`'\"，。；;）)]+\.(?:py|sh)"
                new_files = _allowed_new_files(content)
                for ref in re.findall(pattern, content):
                    if not _existing(ref):
                        if _script_rel(ref) in new_files:
                            continue  # declared （新增） in the allowed-write section
                        m = re.match(r"^tools/(.+)$", ref)
                        if m and os.path.isfile(os.path.join(H, "tools", m.group(1))):
                            continue  # short-form tools/ path that exists under $KOS_HOME/tools
                        err.append(f"E6 {os.path.basename(f)} 引用的脚本不存在：{ref}")
                if flag_table is None and not flag_table_failed:
                    flag_table = _handoff_flag_table()
                    if flag_table is None:
                        flag_table_failed = True
                if flag_table_failed:
                    err.append(f"E6 {os.path.basename(f)} 无法反射 scripts/kos/kos_handoff.py 的 argparse 子命令表（fail-closed，不静默跳过）")
                else:
                    _check_e6_handoff_invocations(f, content, handoff_lines, flag_table, err)

    def _check_e6_handoff_invocations(f, content, handoff_lines, table, err):
        # KOS-LINT-HANDOFF-FLAGS: subcommands/long options must match the real
        # argparse definition in scripts/kos/kos_handoff.py, and block-producing
        # subcommands require the anti-wrap notice somewhere in the packet.
        import shlex
        if not table:
            return
        base = os.path.basename(f)
        relay_subs = {"final", "relay-exec", "relay-quality"}
        needs_notice = set()
        for line in handoff_lines:
            clean = re.sub(r"^\s*(?:(?:[-*+]\s+)|(?:\d+[.)]\s+))?", "", line).strip().replace("`", "")
            try:
                tokens = shlex.split(clean, comments=True)
            except ValueError:
                continue
            idx = next((i for i, t in enumerate(tokens) if t.endswith("kos_handoff.py")), None)
            if idx is None:
                continue
            rest = tokens[idx + 1:]
            sub = next((t for t in rest if not t.startswith("-")), None)
            # A prose remainder (Chinese, paths, values) is not a subcommand claim.
            if sub is None or not re.fullmatch(r"[a-z][a-z0-9-]*", sub):
                continue
            if sub not in table:
                err.append(f"E6 {base} kos_handoff 未知子命令：{sub}")
                continue
            for t in rest:
                if t.startswith("--"):
                    flag = t.split("=", 1)[0]
                    if flag not in table[sub]:
                        err.append(f"E6 {base} kos_handoff {sub} 非法选项：{flag}")
            if sub in relay_subs:
                needs_notice.add(sub)
        if needs_notice and not re.search(r"直接作为 Markdown 原样回复|严禁外层再套代码块", content):
            err.append(
                f"E6 {base} 调用 {'/'.join(sorted(needs_notice))} 但未写明防套壳要求（直接作为 Markdown 原样回复 / 严禁外层再套代码块）"
            )

    def _handoff_flag_table():
        # KOS-TOOLS-CLEANUP-002: reflect the real argparse subparsers of the
        # adjacent scripts/kos/kos_handoff.py instead of parsing its source
        # text (which silently returned an empty table on naming drift — a
        # fail-open hole). Any import/reflection failure returns None and the
        # caller reports an explicit E6 error (fail-closed).
        import argparse as _argparse
        import importlib.util
        handoff_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "kos_handoff.py")
        try:
            spec = importlib.util.spec_from_file_location("_kos_handoff_reflect", handoff_path)
            module = importlib.util.module_from_spec(spec)
            assert spec.loader is not None
            spec.loader.exec_module(module)
        except Exception:
            return None
        captured = {}
        orig_add_parser = _argparse._SubParsersAction.add_parser
        def _spy(self, name, *args, **kwargs):
            parser = orig_add_parser(self, name, *args, **kwargs)
            captured[name] = parser
            return parser
        _argparse._SubParsersAction.add_parser = _spy
        # KOS-REPORT-AUDIT-001 (O70): redirect stdout/stderr while calling
        # profile so argparse's usage/error noise never reaches the user's
        # terminal (reflection output is captured via the spy, not printed).
        import contextlib as _contextlib
        import io as _io
        try:
            with _contextlib.redirect_stdout(_io.StringIO()), _contextlib.redirect_stderr(_io.StringIO()):
                module.main(["profile"])
        except SystemExit:
            pass
        except Exception:
            return None
        finally:
            _argparse._SubParsersAction.add_parser = orig_add_parser
        table = {}
        for name, parser in captured.items():
            table[name] = {flag for flag in parser._option_string_actions if flag.startswith("--")}
        return table or None

    def _gate_commands(content):
        import shlex
        commands = []
        for line in re.sub(r"\\\s*\n", " ", content).splitlines():
            line = re.sub(r"^\s*(?:(?:[-*+]\s+)|(?:\d+[.)]\s+))", "", line).strip().replace("`", "")
            if line.startswith(('#', '>')):
                continue
            try:
                tokens = shlex.split(line, comments=True)
            except ValueError:
                continue
            if tokens:
                commands.append(tokens)
        return commands

    def _gate_steps(content):
        commands = _gate_commands(content)
        def executable(cmd, name):
            return any(os.path.basename(token) == name for token in cmd[:2])
        def scheme(cmd, name):
            return any(cmd[i:i+2] == ['-scheme', name] for i in range(len(cmd)-1))
        def action(cmd, name):
            return name in cmd
        return (
            any((executable(c, 'swift-format') or c[:2] == ['xcrun', 'swift-format']) and action(c, 'lint') for c in commands),
            any(executable(c, 'swift') and action(c, 'test') and any('KeyboardCore' in t for t in c) for c in commands),
            any(executable(c, 'xcodebuild') and scheme(c, 'RimeBridgeTests') and action(c, 'test') for c in commands),
            any(executable(c, 'xcodebuild') and scheme(c, 'Universe Keyboard') and action(c, 'test') and not any(t.startswith('-only-testing') for t in c) for c in commands),
            any(executable(c, 'xcodebuild') and scheme(c, 'Universe Keyboard') and action(c, 'test') and 'CODE_SIGN_IDENTITY=-' in c and any(t.startswith('-only-testing:UniverseKeyboardTests/RimeSyncModelTests/testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem') for t in c) for c in commands),
            any(executable(c, 'xcodebuild') and ['-configuration', 'Release'] in [c[i:i+2] for i in range(len(c)-1)] and action(c, 'build') for c in commands),
        )

    def _check_e7(files, txt, err):
        for f in txt:
            content = txt[f]
            base = os.path.basename(f)
            if any("CODE_SIGNING_IDENTITY=-" in line and not _rule_explanation(line, "CODE_SIGNING_IDENTITY=-") for line in content.splitlines()):
                err.append(f"E7 {base} 使用了 CODE_SIGNING_IDENTITY=-，应为 CODE_SIGN_IDENTITY=-")
            full = any(re.search(r"本地[^。\n]{0,20}\bfull\b|\bfull\b[^。\n]{0,12}门禁", line) and not re.search(r"对声明|若.*声明|出现|规则|检查.*是否齐全", line) for line in content.splitlines())
            keychain = any(any(os.path.basename(t) == 'xcodebuild' for t in c[:2]) and ('CODE_SIGN_IDENTITY=-' in c or any('RimeSyncSecretStore' in t for t in c)) for c in _gate_commands(content))
            if full or keychain:
                missing = [tokens[0] for tokens, present in zip(E7_REQUIRED_TOKENS, _gate_steps(content)) if not present]
                if missing:
                    err.append(f"E7 {base} 本地 full 门禁缺少步骤：{', '.join(missing)}")
            if re.search(r"与\s*CI\s*参数完整一致", content) and not re.search(r"-retry-tests-on-failure[^。\n]{0,24}(?:不属于|不含)|不含[^。\n]{0,16}(?:托管重试|-retry-tests-on-failure)", content):
                err.append(f"E7 {base} 声称与 CI 参数完整一致，但未说明 -retry-tests-on-failure 不属于本地门禁")

    def _pairs(content):
        return [(m.start(), m.end()) for m in re.finditer(r"`(/[^`]+)`(.{0,80}?)`([0-9a-f]{64})`", content)
                if not any(mark in m.group(1) for mark in ('<', '>', '*', '$', '{{'))]

    def _check_hash_pairs(files, txt, err, warn):
        for f in txt:
            content = txt[f]
            base = os.path.basename(f)
            spans = _pairs(content)
            for m in re.finditer(r"(/[^\s`]+\.md)", content):
                window = content[max(0, m.start() - 80):m.end() + 80]
                if not re.search(r"(?<![0-9a-f])[0-9a-f]{64}(?![0-9a-f])", window):
                    continue
                if any(start <= m.start() and m.end() <= end for start, end in spans):
                    continue
                warn.append(f"W5 {base} 绝对 Markdown 路径与 64 位哈希缺少反引号配对，可能无法被 kos-verify-inputs 解析：{m.group(1)}")
            declared = "kos-verify-inputs.py" in content or "冻结输入" in content
            if declared and not spans:
                err.append(f"E8 {base} 声明了冻结输入或输入校验，但没有可解析的路径与哈希配对")

    def _check_hardcoded_next_role(files, txt, warn):
        # O85: execution / repair packets should name a duty, not a person.
        # Jack is the PM and stays explicit. Warning only — historical packets
        # must keep exiting 0.
        names = "Alex|Quinn|Nick|Lucy|Cole|Pete|Wendy|Ivy|Maya"
        name_re = re.compile(rf"(?<![A-Za-z])({names})（")
        for f in files:
            content = txt[f]
            head = "\n".join(content.splitlines()[:40])
            base = os.path.basename(f)
            is_exec = bool(re.search(
                r"角色：\s*Executor|返修|包头档位[^\n]{0,40}`(?:code-fix|feature|fix)`",
                head)) or bool(re.search(r"(?:^|-)(?:code|fix|impl)(?:-|$)", base))
            if not is_exec:
                continue
            for n, line in enumerate(content.splitlines(), 1):
                if "next_role" not in line:
                    continue
                for match in name_re.finditer(line):
                    warn.append(
                        f"W6 {base}:{n} next_role 硬编码了非 PM 人名 {match.group(1)}，"
                        "建议只写职责（如 Quality Reviewer）")

    _check_e5(files, txt, err)
    _check_e6(files, txt, err)
    _check_e7(files, txt, err)
    _check_hash_pairs(files, txt, err, warn)
    _check_hardcoded_next_role(files, txt, warn)
    for e in err: print(e)
    for w in warn: print(w)
    print(f"== 错误 {len(err)}，提示 {len(warn)}")
    sys.exit(1 if err else 0)

if __name__ == "__main__":
    main()
