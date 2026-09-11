# Solidity Development Book

> A practical, **EVM-first** guide to writing, deploying, and securing Solidity smart contracts on Ethereum — built around how the EVM actually works, not just language syntax.

Welcome to the world of decentralized blockchain. This book starts with blockchain and Ethereum fundamentals so you understand *why* things behave the way they do, then drills into Solidity syntax, storage layout, contract creation, inter-contract calls, proxies, and finally advanced security and cryptography topics. Every concept comes with runnable examples — and, where it matters, a look under the hood at EVM bytecode and storage slots — so you learn to reason about gas, security, and correctness instead of copying snippets.

## Who this book is for

- **Experienced developers who are new to blockchain.** You should have written code in *some* programming language before. You do **not** need to know Solidity yet — we learn it together — but this book is **not for complete programming beginners**.
- **Blockchain beginners who are curious.** If you've only heard about Ethereum and never gone deeper, this is for you: you'll learn how blockchains work, how to write and deploy contracts, and how to run and test them on your own machine.

If you already know [the syntax of Solidity](https://docs.soliditylang.org/en/latest/introduction-to-smart-contracts.html), great — you can move faster. If not, no problem: the journey covers it.

## What's inside

The book progresses in *Milestones*, each focusing on one layer of the stack:

| Section | Topic | What you'll learn |
| --- | --- | --- |
| **Background** | Understanding the EVM | How the Ethereum Virtual Machine executes code and stores state |
| **Milestone 0 — Solidity Data** | Values & data | Variables, storage scoping, copy semantics, `enum`, `bytes`/`string`, `mapping`, `foreach`, ABI `encode` |
| **Milestone 1 — Solidity variables** | Storage layout | Static / mapping / array / string / struct slot storage, user-defined value types |
| **Milestone 2 — Solidity functions** | Functions | Function kinds, constructors, modifiers, selectors, sending value, error handling |
| **Milestone 3 — Solidity contract creation** | Deployment | `import`, `create` / `create2` / `create3`, creation codes, `SSTORE2`, destruction, events, reading bytecode |
| **Milestone 4 — Solidity contract types** | Composition | `interface`, `library`, `abstract`, inheritance, upgradeable `proxy` |
| **Milestone 5 — Solidity contract calls** | Interaction | `call`, `delegatecall`, `staticcall`, precompiled contracts |
| **Milestone 6 — Advanced** | Security & crypto | Merkle proofs, ECDSA & RSA signatures, common mistakes, ERC-7702, Chainlink oracle, gas optimization, Tornado Cash case study |

The full clickable table of contents is in the sidebar on the left.

## How this book is built

- Authored in **Markdown**, rendered with **[mdBook](https://rust-lang.github.io/mdBook/)**.
- Math (used in the signature and Merkle sections) rendered by the **[mdbook-katex](https://github.com/KaTeX/katex)** preprocessor.
- Deployed to **GitHub Pages** on every push to `main`.

## How to use this book

- Just read top-to-bottom in the sidebar — each milestone builds on the previous one.
- Want to experiment locally? Clone the repo and run:

  ```shell
  cargo install mdbook
  cargo install mdbook-katex
  git clone https://github.com/yuhuajing/solidity-book.git
  cd solidity-book
  mdbook serve --open   # opens http://localhost:3000/
  ```

## Useful resources

1. 📖 Live book: <https://yuhuajing.github.io/solidity-book/>
2. 💻 Source on GitHub: <https://github.com/yuhuajing/solidity-book>
3. 📘 Solidity documentation: <https://docs.soliditylang.org/en/latest/>
4. 🔧 Ethereum Virtual Machine overview: <https://ethereum.org/en/developers/docs/evm/>
5. ✍️ Solidity by Example: <https://solidity-by-example.org/>

Alright, let's get started!
