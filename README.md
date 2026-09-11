# Solidity Development Book

> A practical, **EVM-first** guide to writing, deploying, and securing Solidity smart contracts on Ethereum — built around how the Ethereum Virtual Machine actually works, not just language syntax.

[![Built with mdBook](https://img.shields.io/badge/built%20with-mdBook-1f6feb)](https://rust-lang.github.io/mdBook/)
[![Deployed on GitHub Pages](https://img.shields.io/badge/deployed-GitHub%20Pages-1f6feb)](https://yuhuajing.github.io/solidity-book/)

---

## What this book is

This book is a structured, example-driven walkthrough of Solidity smart-contract
development. It starts from blockchain and Ethereum fundamentals so you understand
*why* things work the way they do, then drills into Solidity syntax, storage
layout, contract creation, inter-contract calls, proxies, and finally advanced
security and cryptography topics.

Every concept is paired with runnable examples and, where it matters, a look under
the hood at EVM bytecode and storage slots — so you learn to reason about gas,
security, and correctness instead of copying snippets.

## Who this book is for

- **Experienced developers who are new to blockchain.** You should have written code
  in *some* programming language before. You do **not** need to know Solidity yet —
  we learn it together — but a heads-up that this book is **not for complete
  programming beginners**.
- **Blockchain beginners who are curious.** If you've only heard about Ethereum and
  never gone deeper, this is for you: you'll learn how blockchains work, how to write
  and deploy contracts, and how to run and test them on your own machine.

If you already know the [Solidity syntax](https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html),
great — you can move faster. If not, no problem: the journey covers it.

## How the book is organized

The book progresses in *Milestones*, each focusing on one layer of the stack:

| Section | Topic | What's inside |
| --- | --- | --- |
| **Background** | Understanding the EVM | How the Ethereum Virtual Machine executes code and stores state |
| **Milestone 0 — Solidity Data** | Values & data | Variables, storage scoping, copy semantics, `enum`, `bytes`/`string`, `mapping`, `foreach`, ABI `encode` |
| **Milestone 1 — Solidity variables** | Storage layout | Static / mapping / array / string / struct slot storage, user-defined value types |
| **Milestone 2 — Solidity functions** | Functions | Function kinds, constructors, modifiers, selectors, sending value, error handling |
| **Milestone 3 — Solidity contract creation** | Deployment | `import`, `create` / `create2` / `create3`, creation codes, `SSTORE2`, destruction, events, reading bytecode |
| **Milestone 4 — Solidity contract types** | Composition | `interface`, `library`, `abstract`, inheritance, upgradeable `proxy` |
| **Milestone 5 — Solidity contract calls** | Interaction | `call`, `delegatecall`, `staticcall`, precompiled contracts |
| **Milestone 6 — Advanced** | Security & crypto | Merkle proofs, ECDSA & RSA signatures, common mistakes, ERC-7702, Chainlink oracle, gas optimization, Tornado Cash case study |

> The full clickable table of contents lives inside the book itself — see
> [the online version](https://yuhuajing.github.io/solidity-book/).

## Tech stack

- Authored in **Markdown**, built with **[mdBook](https://rust-lang.github.io/mdBook/)**.
- Math rendering via the **[mdbook-katex](https://github.com/KaTeX/katex)** preprocessor (used in the signature / Merkle sections).
- Continuous deployment to **GitHub Pages** on every push to `main`.

## Read it online

- 📖 Book: <https://yuhuajing.github.io/solidity-book/>
- 💻 Source: <https://github.com/yuhuajing/solidity-book>

## Run it locally

```shell
# 1. Install Rust  (https://www.rust-lang.org/)
# 2. Install mdBook and the KaTeX preprocessor
cargo install mdbook
cargo install mdbook-katex

# 3. Clone and serve
git clone https://github.com/yuhuajing/solidity-book.git
cd solidity-book
mdbook serve --open
# then open http://localhost:3000/
```

> Tip: `mdbook build` produces a static site in `book/` if you only need the output.

## Project layout

```
solidity-book/
├── book.toml            # mdBook configuration (title, theme, deploy)
├── src/
│   ├── README.md        # Book landing page (this repo's intro)
│   ├── SUMMARY.md       # Table of contents (drives the sidebar)
│   ├── background/      # EVM fundamentals
│   ├── milestone_0..6/  # Chapters, one folder per milestone
│   └── images/          # Shared diagrams
└── book/                # Build output (generated, not committed)
```

## Contributing

Contributions are welcome! To propose a fix or a new section:

1. Fork the repo and create a branch.
2. Edit the relevant Markdown under `src/` (keep the Milestone folder convention).
3. Run `mdbook serve` locally to preview.
4. Open a pull request against `main`.

For larger changes (new milestones, restructuring), please open an issue first so we
can align on scope.

## Useful links

1. Repo: <https://github.com/yuhuajing/solidity-book>
2. Live book: <https://yuhuajing.github.io/solidity-book/>
3. Solidity docs: <https://docs.soliditylang.org/en/latest/>

---

*This is an independent, community-oriented learning resource and is not affiliated
with the Ethereum Foundation or the Solidity team.*
