"""验证 DeepSeek 的钥匙能不能用。

用法：在 D:\\cs-learning 目录，venv 激活之后敲：
    python test_deepseek.py

钥匙从 .env 读取，不写在代码里、不打印出来、不进 git。
只用标准库，不用装任何第三方包。
"""

import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

ENV_FILE = Path(__file__).parent / ".env"
API_URL = "https://api.deepseek.com/chat/completions"


def load_key() -> str:
    """读钥匙：先看环境变量，再读 .env 文件。"""
    key = os.getenv("DEEPSEEK_API_KEY", "").strip()
    if key:
        return key

    if not ENV_FILE.exists():
        sys.exit(
            "没找到 .env 文件。\n"
            "在 D:\\cs-learning 里建一个，内容就一行：DEEPSEEK_API_KEY=sk-你的钥匙\n"
            "注意文件名前面有个点，是 .env 不是 env。"
        )

    for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("DEEPSEEK_API_KEY="):
            key = line.split("=", 1)[1].strip().strip('"').strip("'")
            if key:
                return key

    sys.exit(".env 里没读到 DEEPSEEK_API_KEY，检查格式是不是：DEEPSEEK_API_KEY=sk-xxx")


def main() -> None:
    key = load_key()
    print("钥匙读到了，正在请求 DeepSeek ...")

    # 模型名：deepseek-v4-flash 是入门款，最便宜，学习够用。
    # 如果这里报错说模型不存在，去 https://api-docs.deepseek.com/zh-cn/quick_start/pricing
    # 看一眼当前有效的模型名，改这里就行。
    payload = json.dumps(
        {
            "model": "deepseek-v4-flash",
            "messages": [{"role": "user", "content": "只回两个字：成功"}],
            "stream": False,
        }
    ).encode("utf-8")

    req = urllib.request.Request(
        API_URL,
        data=payload,
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "ignore")
        if e.code == 401:
            sys.exit(
                "401：钥匙不对或已失效。\n"
                "检查 .env 里有没有多空格、少字符、或者把引号也复制进去了。\n"
                f"原文：{body[:200]}"
            )
        if e.code == 402:
            sys.exit(f"402：账号没余额了，充几块钱再试。\n原文：{body[:200]}")
        sys.exit(f"HTTP {e.code}：\n{body[:300]}")
    except urllib.error.URLError as e:
        sys.exit(f"连不上 DeepSeek：{e.reason}\n（单位网可能拦了，换手机热点试试）")
    except TimeoutError:
        sys.exit("30 秒超时，网络太慢或者被拦了。")
    except json.JSONDecodeError:
        sys.exit("返回的不是 JSON，可能代理插了一脚。")

    reply = data["choices"][0]["message"]["content"]
    usage = data.get("usage", {})
    print()
    print("通了。DeepSeek 回的是：", reply.strip())
    print(
        f"本次消耗：输入 {usage.get('prompt_tokens', '?')} tokens，"
        f"输出 {usage.get('completion_tokens', '?')} tokens"
    )


if __name__ == "__main__":
    main()
