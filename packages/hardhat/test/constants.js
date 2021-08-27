module.exports = Object.freeze({
    Flags: {
        FLAG_DISABLE_UNISWAP: 0x01,
        FLAG_DISABLE_BANCOR: 0x04,
        FLAG_DISABLE_OASIS: 0x08,
        FLAG_DISABLE_COMPOUND: 0x10,
        FLAG_DISABLE_FULCRUM: 0x20,
        FLAG_DISABLE_CHAI: 0x40,
        FLAG_DISABLE_AAVE: 0x80,
        FLAG_DISABLE_SMART_TOKEN: 0x100,
        FLAG_DISABLE_BDAI: 0x400,
        FLAG_DISABLE_IEARN: 0x800,
        FLAG_DISABLE_CURVE_COMPOUND: 0x1000,
        FLAG_DISABLE_CURVE_USDT: 0x2000,
        FLAG_DISABLE_CURVE_Y: 0x4000,
        FLAG_DISABLE_CURVE_BINANCE: 0x8000,
        FLAG_DISABLE_CURVE_SYNTHETIX: 0x40000,
        FLAG_DISABLE_WETH: 0x80000,
        FLAG_DISABLE_UNISWAP_COMPOUND: 0x100000, // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
        FLAG_DISABLE_UNISWAP_CHAI: 0x200000, // Works only when ETH<>DAI or FLAG_ENABLE_MULTI_PATH_ETH
        FLAG_DISABLE_UNISWAP_AAVE: 0x400000, // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
        FLAG_DISABLE_IDLE: 0x800000,
        FLAG_DISABLE_UNISWAP_V2: 0x2000000,
        FLAG_DISABLE_UNISWAP_V2_ETH: 0x4000000,
        FLAG_DISABLE_UNISWAP_V2_DAI: 0x8000000,
        FLAG_DISABLE_UNISWAP_V2_USDC: 0x10000000,
        FLAG_DISABLE_ALL_SPLIT_SOURCES: 0x20000000,
        FLAG_DISABLE_ALL_WRAP_SOURCES: 0x40000000,
        FLAG_DISABLE_CURVE_PAX: 0x80000000,
        FLAG_DISABLE_CURVE_RENBTC: 0x100000000,
        FLAG_DISABLE_CURVE_TBTC: 0x200000000,
        FLAG_DISABLE_SHELL: 0x8000000000,
        FLAG_ENABLE_CHI_BURN: 0x10000000000,
        FLAG_DISABLE_MSTABLE_MUSD: 0x20000000000,
        FLAG_DISABLE_CURVE_SBTC: 0x40000000000,
        FLAG_DISABLE_DMM: 0x80000000000,
        FLAG_DISABLE_UNISWAP_ALL: 0x100000000000,
        FLAG_DISABLE_CURVE_ALL: 0x200000000000,
        FLAG_DISABLE_UNISWAP_V2_ALL: 0x400000000000,
        FLAG_DISABLE_SPLIT_RECALCULATION: 0x800000000000,
        FLAG_DISABLE_BALANCER_ALL: 0x1000000000000,
        FLAG_DISABLE_BALANCER_1: 0x2000000000000,
        FLAG_DISABLE_BALANCER_2: 0x4000000000000,
        FLAG_DISABLE_BALANCER_3: 0x8000000000000,
        FLAG_ENABLE_REFERRAL_GAS_SPONSORSHIP: 0x80000000000000, // Turned off by default
        FLAG_ENABLE_CHI_BURN_BY_ORIGIN: 0x4000000000000000,
        FLAG_DISABLE_ALL: 0x1F2800000000C,
        FLAG_ANY: 0x0
    },
    Tokens: {
        eth: ['0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE',   'ETH',    1e18, '390000000'],
        weth: ['0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',   'WETH',   1e18, '390000000'], // passes eth -> weth on any
        chai: ['0x06AF07097C9Eeb7fD685c692751D5C66dB49c215',   'CHAI',   1e18, '390000000'], // fails eth  -> chai on any
        dai: ['0x6B175474E89094C44Da98b954EedeAC495271d0F',   'DAI',    1e18, '390000000'], // fails eth  -> dai on any
        usdc: ['0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',   'USDC',   1e6,  '390000000'], // fails eth  -> usdc on any
        usdt: ['0xdAC17F958D2ee523a2206206994597C13D831ec7',   'USDT',   1e6,  '390000000'], // passes eth -> usdt on any
        tusd: ['0x0000000000085d4780B73119b644AE5ecd22b376',   'TUSD',   1e18, '390000000'], // passes eth -> tusd on any
        busd: ['0x4fabb145d64652a948d72533023f6e7a623c7c53',   'BUSD',   1e18, '390000000'], // passes eth -> busd on any
        susd: ['0x57Ab1ec28D129707052df4dF418D58a2D46d5f51',   'SUSD',   1e18, '390000000'], // passes eth -> susd on any
        pax: ['0x8E870D67F660D95d5be530380D0eC0bd388289E1',   'PAX',    1e18, '390000000'], // passes eth -> pax on any
        renbtc: ['0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D',   'RENBTC', 1e8,  '600000'],    // passes eth -> renbtc on any
        wbtc: ['0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',   'WBTC',   1e8,  '600000'],    // passes eth -> wbtc on any
        tbtc: ['0x1bBE271d15Bb64dF0bc6CD28Df9Ff322F2eBD847',   'TBTC',   1e18, '600000'],    // fails eth -> tbtc on any
        hbtc: ['0x0316EB71485b0Ab14103307bf65a021042c6d380',   'HBTC',   1e18, '390000000'], // passes eth -> hbtc on any
        sbtc: ['0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6',   'SBTC',   1e14, '390000000'] // passes eth -> sbtc on any
    },
    ERC20_ABI: [
        // Some details about the token
        "function name() view returns (string)",
        "function symbol() view returns (string)",
        "function decimals() view returns (uint)",
        "function balanceOf(address) view returns (uint)",
        "function approve(address spender, uint256 amount)",
        "function allowance(address owner, address spender) view returns (uint256)",
        "function transfer(address to, uint amount)",
        "function transferFrom(address sender, address recipient, uint256 amount)",
        "event Transfer(address indexed from, address indexed to, uint amount)",
    ]
});
