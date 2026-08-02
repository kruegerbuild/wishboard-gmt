# Wish Board

A public wall for wishes, written by strangers, kept forever.

## The idea

Most of what we write online disappears. A tweet scrolls away, a note gets deleted, a wall gets painted over. Wish Board works differently. It's a single wall, open to anyone with a wallet, where a person can write a short, honest wish and hang it up for good. Once it's on the wall, it stays there. No account, no algorithm deciding who sees it, no owner who can quietly take it down. Just a message, a timestamp, and the address that hung it, sitting on-chain where anyone can read it.

It was built for BOTChain Build Week, but the idea behind it is simple enough to outlast the hackathon: give people one honest place to say what they want, and let it last.

## What it does

- **Connect a wallet.** More on exactly which wallets below — the short version is MetaMask is the one this is built around, but it isn't the only one that works.
- **Write a wish.** Up to 280 characters, plain text, no formatting.
- **Hang it on the wall.** This sends a transaction to the WishBoard smart contract. Once it confirms, the wish is permanent — there's no delete function, by design.
- **Read the wall.** Anyone can browse every wish ever posted, sorted newest or oldest first, without connecting a wallet at all. Reading is free and doesn't require a transaction.
- **See the numbers.** A small stats row shows how many wishes have been hung, how many unique wallets have posted, and what it currently costs to post one (the contract's fee is often zero, but the network gas fee still applies).

## How someone would use it

No sign-up, no app to download. Here's the actual sequence, start to finish:

1. **Open the site.** The wall is already there, loaded straight from the blockchain — you don't need a wallet just to look at it.
2. **Click "Connect MetaMask."** MetaMask (or a compatible wallet extension) will open and ask you to approve the connection.
3. **If your wallet's on the wrong network**, the app will notice and prompt it to switch to BOT Chain Mainnet — approve that too. This only happens once; after that your wallet remembers.
4. **Type a wish** into the text box. Anything up to 280 characters.
5. **Click "Hang it on the wall."** Your wallet will ask you to confirm the transaction. There's a small network gas fee, paid to the chain itself — the board doesn't charge anything on top of that.
6. **Wait a moment for the transaction to confirm.** Once it does, your wish appears on the wall, with your wallet address attached, for anyone to read.

That's it. There's no edit button and no delete button anywhere — once it's up, it's up for good.

## Wallets: what's actually required

Reading the wall needs nothing at all — no wallet, no extension, not even a browser that supports Web3. It's just a page reading public data off a public chain.

Writing to it — hanging an actual wish — needs a wallet, because that's what turns "a message" into "a signed transaction." The page is built around **MetaMask** specifically: when it opens, it looks for MetaMask by name, and if more than one wallet extension happens to be installed at once, it goes out of its way to pick MetaMask rather than whichever one grabbed the browser first. If no wallet is present at all, the button sends you to install MetaMask, not some generic "get a wallet" page.

That said, under the hood, the page is talking to whatever wallet exposes itself the standard way browser wallets do — the same interface MetaMask, Coinbase Wallet's extension, and a handful of others all speak. So while MetaMask is the one it's designed and tested around, a different standards-compliant wallet extension will likely still work for connecting and posting.

One thing worth knowing if you're testing this yourself: **opening the page in an incognito or private window and seeing it point you straight to install MetaMask is expected, not a bug.** Browsers disable extensions in private windows by default. With no extension running, there's genuinely no wallet for the page to find — so it does exactly what it's supposed to do in that situation.

## Network

Wish Board runs on **BOT Chain Mainnet only** (chain ID 677). There's no testnet switch in the interface — if a connected wallet is on a different network, the app will ask it to switch, or add the network automatically if the wallet doesn't already know about it.

| | |
|---|---|
| Chain | BOT Chain Mainnet |
| Chain ID | 677 (`0x2a5`) |
| Currency | BOT |
| RPC | `https://rpc.botchain.ai` |
| Explorer | `https://scan.botchain.ai` |

These values live in the `NETWORK` object near the top of the script in `index.html`.

## How it's built

This is intentionally a single, self-contained file: `index.html`. There's no build step, no bundler, and no framework. HTML, CSS, and JavaScript all live in one place, and the only external dependency is [ethers.js](https://docs.ethers.org/v5/) (v5), loaded from a CDN, which handles all the contract reads, writes, and wallet communication.

The page talks to the chain in two separate ways:

- **Reading the wall** uses a plain JSON-RPC provider pointed at BOT Chain Mainnet's public RPC endpoint. This works for any visitor, wallet or not.
- **Posting a wish** requires a connected wallet, since it needs a signer to submit and pay for the transaction.

## The contract

This repository holds the frontend only; the contract itself is `WishBoard.sol`, included alongside it. It's deliberately small — one struct, one array, three read functions, and a single function that writes anything at all.

```solidity
function postWish(string calldata _message) external payable
function getWishCount() external view returns (uint256)
function getWish(uint256 _index) external view returns (address sender, string memory message, uint256 timestamp)
function getAllWishes() external view returns (Wish[] memory)
uint256 public minFee
event WishPosted(address indexed sender, string message, uint256 timestamp, uint256 wishId)
```

A few things worth knowing about how it works:

- **There's no owner.** No admin address, no pausing, no way for anyone — including whoever deploys it — to edit or remove a wish once it's posted. The permanence isn't just a design choice in the frontend; it's baked into the contract.
- **`minFee` is fixed at deploy time and can't be changed afterward.** There's no setter function. Whatever it's set to when the contract goes live (currently `0`, meaning posting is free aside from network gas) is what it stays at, forever.
- **Validation happens on-chain, not just in the browser.** The contract itself rejects empty messages, messages over 280 characters, and payments below `minFee` — so the character limit and fee shown in the UI aren't just cosmetic, the chain enforces them too.

This is what's currently deployed and wired up on the live site — the address is set in the `CONTRACT_ADDRESS` constant near the top of the script in `index.html`.

## Developer mode

Once `CONTRACT_ADDRESS` is set in the code, the ability to swap in a different contract from the page itself is hidden from regular visitors — a live wall shouldn't let anyone quietly repoint it. To reveal that control while testing, add `?dev=1` to the URL.

## A note on permanence

There is no edit button and no delete button anywhere in this app, and that's on purpose. Once a wish is confirmed on-chain, it's part of the wall for as long as the chain exists. Write accordingly.

## License

This isn't all one license — it's worth being precise here.

`WishBoard.sol` carries `// SPDX-License-Identifier: MIT` in its header, and its source is already publicly verified on the BOT Chain explorer under that declaration. That makes the contract genuinely, irreversibly MIT-licensed — the SPDX line is a real, tool-recognized license grant for that specific file, not just a comment, and once verified source is public under it, there's no taking that back.

Everything else in this repository — `index.html`, the README, and the project as a whole — is **not** released under any open license. All rights reserved by default. You're welcome to read the code and see how it works, but reusing, copying, or redistributing it beyond that isn't granted here.

---

Source: [github.com/kruegerbuild](https://github.com/kruegerbuild)
