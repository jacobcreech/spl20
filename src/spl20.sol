// SPDX-License-Identifier: MIT license
pragma solidity =0.8.28;

struct Mint {
    uint8 decimals;
    uint256 supply;
    address mintAuthority;
    address freezeAuthority;
    address mintAddress;
}

struct TokenAccount {
    address mintAddress;
    address owner;
    uint256 balance;
    bool isFrozen;
}

contract Spl20 {
    mapping(address => Mint) public mints;
    mapping(address => TokenAccount) public tokenAccounts;
    mapping(address => bool) public mintAddresses;
    mapping(address => bool) public tokenAddresses;

    function initializeMint(uint8 decimals, address mintAuthority, address freezeAuthority, address mintAddress)
        public
        returns (Mint memory)
    {
        require(mintAddresses[mintAddress] == false, "Mint already exists");
        mints[mintAddress] = Mint(decimals, 0, mintAuthority, freezeAuthority, mintAddress);
        mintAddresses[mintAddress] = true;
        return Mint(decimals, 0, mintAuthority, freezeAuthority, mintAddress);
    }

    function mintTokens(address toMintTokens, address mintAddress, uint256 amount) public {
        require(mints[mintAddress].mintAuthority == msg.sender, "Only the mint authority can mint tokens");
        require(mints[mintAddress].mintAddress != address(0), "Token does not exist");
        require(mints[mintAddress].supply + amount <= type(uint256).max, "Supply overflow");

        mints[mintAddress].supply += amount;

        address tokenAddress = address(uint160(uint256(keccak256(abi.encodePacked(toMintTokens, mintAddress)))));

        if (tokenAccounts[tokenAddress].mintAddress == address(0)) {
            tokenAccounts[tokenAddress] = TokenAccount(mintAddress, toMintTokens, 0, false);
            tokenAddresses[tokenAddress] = true;
        }
        tokenAccounts[tokenAddress].balance += amount;
        tokenAccounts[tokenAddress].owner = toMintTokens;
    }

    function transfer(address to, address mintAddress, uint256 amount) public {
        address toTokenAddress = address(uint160(uint256(keccak256(abi.encodePacked(to, mintAddress)))));
        address fromTokenAddress = address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, mintAddress)))));

        require(tokenAccounts[fromTokenAddress].balance >= amount, "Insufficient balance");
        require(tokenAccounts[toTokenAddress].balance + amount <= type(uint256).max, "Supply overflow");
        require(tokenAccounts[fromTokenAddress].owner == msg.sender, "fromToken owner is not msg.sender");
        require(tokenAccounts[fromTokenAddress].isFrozen == false, "fromToken is frozen");
        require(tokenAccounts[toTokenAddress].isFrozen == false, "toToken is frozen");

        if (tokenAccounts[toTokenAddress].mintAddress == address(0)) {
            tokenAccounts[toTokenAddress] = TokenAccount(mintAddress, to, 0, false);
            tokenAddresses[toTokenAddress] = true;
        }

        tokenAccounts[fromTokenAddress].balance -= amount;
        tokenAccounts[toTokenAddress].balance += amount;
    }

    function getMint(address token) public view returns (Mint memory) {
        return mints[token];
    }

    function getTokenAccount(address owner, address token) public view returns (TokenAccount memory) {
        return tokenAccounts[address(uint160(uint256(keccak256(abi.encodePacked(owner, token)))))];
    }
}
