#  Solidity Development Book
Welcome to the world of decentralized blockchain: The document begins with an introduction to blockchain technology and Ethereum, providing essential context for understanding smart contracts. It then delves into the syntax and features of Solidity, covering key concepts such as data types, functions, modifiers, and inheritance. Practical examples are included to illustrate how to write and deploy smart contracts, along with best practices for security and optimization. Additionally, the document addresses common pitfalls and debugging strategies to help learners navigate challenges they may encounter. Finally, the document provides resources for further learning, including links to online courses, documentation, and community forums. This structured approach aims to equip readers with the knowledge and skills needed to confidently create and manage their own smart contracts in Solidity

This book will guide you through the development of a decentralized application, including:
- smart-contract development (in [Solidity](https://docs.soliditylang.org/en/latest/index.html));

**This book is not for complete beginners.**

I expect you to be an experienced developer, who has ever programmed in any programming language. It'll also be helpful if you know [the syntax of Solidity](https://docs.soliditylang.org/en/v0.8.17/introduction-to-smart-contracts.html), the main programming language of this book. If not, it's not a big problem: we'll learn a lot about Solidity and Ethereum Virtual Machine during our journey.

**However, this book is for blockchain beginners.**

If you only heard about blockchains and were interested but haven't had a chance to dive deeper, this book is for you!  Yes, for you! You'll learn how to develop for blockchains (specifically, Ethereum), how blockchains work, how to program and deploy smart contracts, and how to run and test them on your computer.

Alright, let's get started!

## Useful Links
1. This book is hosted on GitHub: <https://github.com/yuhuajing/solidity-book>

## Table of Contents
- Milestone 0. Solidity Data
  1. data-bytes
  2. data-enum
  3. data-foreach
  4. data-mapping
  5. data-variables
  6. data-encode
- Milestone 1. Solidity functions
  1. variables-slot-storage
  2. variables-unicode
  3. variables-user-defined-type
- Milestone 2. Solidity variables
  1. Functions
  2. Functions modifier
  3. Functions selector
  4. Functions sendValue
  5. errors check
- Milestone 3. Sollidity contracts create
  1. contracts-import
  2. contracts-create
  3. contracts-creationcodes
  4. contracts-destroy
  5. contracts-event
  6. contracts-getcodes
- Milestone 4: Sollidity contracts type
  1. contracts-interface
  2. contracts-library
  3. contracts-abstract
  4. contracts-inherite
  5. contracts-proxy
- Milestone 5. Sollidity contracts call
  1. contracts-call
  2. contracts-delegatecall
  3. contrats-staticcall
  4. contracts-precompile
- Milestone 6. Sollidity advanced
  1. merkle tree
  2. ecdsa signature
## Running locally

To run the book locally:
1. Install [Rust](https://www.rust-lang.org/).
1. Install [mdBook](https://github.com/rust-lang/mdBook):
    ```shell
    $ cargo install mdbook
    $ cargo install mdbook-katex
    ```
1. Clone the repo:
    ```shell
    $ git clone https://github.com/yuhuajing/solidity-book.git
    $ cd solidity-book
    ```
1. Run:
    ```shell
    $ mdbook serve --open
    ```
1. Visit http://localhost:3000/ (or whatever URL the previous command outputs!)
