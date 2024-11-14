// https://docs.ethers.org/v6/cookbook/signing/
import {ethers} from"ethers";

const main = async () => {
    const provider = new ethers.JsonRpcProvider(`https://cloudflare-eth.com`);
    const signer = new ethers.Wallet("xxxxx",provider)
    console.log(`私钥钱包地址:${signer.address}`)
    const message = "Hello, World!";
    // const rawSig = await signer.signMessage(message);
    // 等效于Solidity中的keccak256(abi.encodePacked(account, tokenId))
    const msgHash = ethers.solidityPackedKeccak256(
        ['string'],
        [message])
    const messageHashBytes = ethers.getBytes(msgHash)
    const rawSig = await signer.signMessage(messageHashBytes);
    // console.log(rawSig);
}
main()
