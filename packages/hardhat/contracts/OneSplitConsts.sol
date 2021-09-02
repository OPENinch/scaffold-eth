// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IOneSplit.sol";
import "./interfaces/IBancorNetwork.sol";
import "./interfaces/IBancorContractRegistry.sol";
import "./interfaces/IBancorNetworkPathFinder.sol";
import "./interfaces/IBancorConverterRegistry.sol";
import "./interfaces/IBancorEtherToken.sol";
import "./interfaces/IBancorFinder.sol";
import "./interfaces/IOasisExchange.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/ICurve.sol";
import "./interfaces/IChai.sol";
import "./interfaces/ICompound.sol";
import "./interfaces/ICompoundRegistry.sol";
import "./interfaces/ICompoundEther.sol";
import "./interfaces/IAaveToken.sol";
import "./interfaces/IAaveRegistry.sol";
import "./interfaces/IAaveLendingPool.sol";
import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IShell.sol";
import "./interfaces/IMStable.sol";
import "./interfaces/IBalancerHelper.sol";
import "./interfaces/IBalancerRegistry.sol";
import "./interfaces/IOneSplitView.sol";

//
//  [ msg.sender ]
//       | |
//       | |
//       \_/
// +---------------+ ________________________________
// | OneSplitAudit | _______________________________  \
// +---------------+                                 \ \
//       | |                      ______________      | | (staticcall)
//       | |                    /  ____________  \    | |
//       | | (call)            / /              \ \   | |
//       | |                  / /               | |   | |
//       \_/                  | |               \_/   \_/
// +--------------+           | |           +----------------------+
// | OneSplitWrap |           | |           |   OneSplitViewWrap   |
// +--------------+           | |           +----------------------+
//       | |                  | |                     | |
//       | | (delegatecall)   | | (staticcall)        | | (staticcall)
//       \_/                  | |                     \_/
// +--------------+           | |             +------------------+
// |   OneSplit   |           | |             |   OneSplitView   |
// +--------------+           | |             +------------------+
//       | |                  / /
//        \ \________________/ /
//         \__________________/
//


contract OneSplitConsts {
    // flags = FLAG_DISABLE_UNISWAP + FLAG_DISABLE_BANCOR + ...
    uint256 internal constant FLAG_DISABLE_UNISWAP = 0x01;
    uint256 internal constant FLAG_DISABLE_BANCOR = 0x04;
    uint256 internal constant FLAG_DISABLE_OASIS = 0x08;
    uint256 internal constant FLAG_DISABLE_COMPOUND = 0x10;
    uint256 internal constant FLAG_DISABLE_FULCRUM = 0x20;
    uint256 internal constant FLAG_DISABLE_CHAI = 0x40;
    uint256 internal constant FLAG_DISABLE_AAVE = 0x80;
    uint256 internal constant FLAG_DISABLE_SMART_TOKEN = 0x100;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_ETH = 0x200; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_BDAI = 0x400;
    uint256 internal constant FLAG_DISABLE_IEARN = 0x800;
    uint256 internal constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
    uint256 internal constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 internal constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 internal constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_DAI = 0x10000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDC = 0x20000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 internal constant FLAG_DISABLE_WETH = 0x80000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_COMPOUND = 0x100000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_CHAI = 0x200000; // Works only when ETH<>DAI or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_AAVE = 0x400000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_IDLE = 0x800000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2 = 0x2000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ETH = 0x4000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_DAI = 0x8000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_USDC = 0x10000000;
    uint256 internal constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x20000000;
    uint256 internal constant FLAG_DISABLE_ALL_WRAP_SOURCES = 0x40000000;
    uint256 internal constant FLAG_DISABLE_CURVE_PAX = 0x80000000;
    uint256 internal constant FLAG_DISABLE_CURVE_RENBTC = 0x100000000;
    uint256 internal constant FLAG_DISABLE_CURVE_TBTC = 0x200000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDT = 0x400000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_WBTC = 0x800000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_TBTC = 0x1000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_RENBTC = 0x2000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_SHELL = 0x8000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN = 0x10000000000;
    uint256 internal constant FLAG_DISABLE_MSTABLE_MUSD = 0x20000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_SBTC = 0x40000000000;
    uint256 internal constant FLAG_DISABLE_DMM = 0x80000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_ALL = 0x100000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_ALL = 0x200000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ALL = 0x400000000000;
    uint256 internal constant FLAG_DISABLE_SPLIT_RECALCULATION = 0x800000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_ALL = 0x1000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_1 = 0x2000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_2 = 0x4000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_3 = 0x8000000000000;
    uint256 internal constant FLAG_ENABLE_REFERRAL_GAS_SPONSORSHIP = 0x80000000000000; // Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_COMP = 0x100000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_ENABLE_CHI_BURN_BY_ORIGIN = 0x4000000000000000;



    uint256 constant internal DEXES_COUNT = 23;
    IERC20 constant internal ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 constant internal ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);

    /// @dev we need a file that contains all constants    
    IBancorEtherToken constant internal bancorEtherToken = IBancorEtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
    IWETH constant internal weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IChai constant internal chai = IChai(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
    IERC20 constant internal dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 constant internal usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant internal usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 constant internal tusd = IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
    IERC20 constant internal busd = IERC20(0x4Fabb145d64652a948d72533023f6E7A623C7C53);
    IERC20 constant internal susd = IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
    IERC20 constant internal pax = IERC20(0x8E870D67F660D95d5be530380D0eC0bd388289E1);
    IERC20 constant internal renbtc = IERC20(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    IERC20 constant internal wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 constant internal tbtc = IERC20(0x1bBE271d15Bb64dF0bc6CD28Df9Ff322F2eBD847);
    IERC20 constant internal hbtc = IERC20(0x0316EB71485b0Ab14103307bf65a021042c6d380);
    IERC20 constant internal sbtc = IERC20(0xfE18be6b3Bd88A2D2A7f928d00292E7a9963CfC6);

    IUniswapFactory constant internal uniswapFactory = IUniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    IBancorContractRegistry constant internal bancorContractRegistry = IBancorContractRegistry(0x52Ae12ABe5D8BD778BD5397F99cA900624CfADD4);
    IBancorNetworkPathFinder constant internal bancorNetworkPathFinder = IBancorNetworkPathFinder(0x6F0cD8C4f6F06eAB664C7E3031909452b4B72861);
    //IBancorConverterRegistry constant internal bancorConverterRegistry = IBancorConverterRegistry(0xf6E2D7F616B67E46D708e4410746E9AAb3a4C518);
    IBancorFinder constant internal bancorFinder = IBancorFinder(0x2B344e14dc2641D11D338C053C908c7A7D4c30B9);
    IOasisExchange constant internal oasisExchange = IOasisExchange(0x794e6e91555438aFc3ccF1c5076A74F42133d08D);
    ICurve constant internal curveCompound = ICurve(0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56);
    ICurve constant internal curveUSDT = ICurve(0x52EA46506B9CC5Ef470C5bf89f17Dc28bB35D85C);
    ICurve constant internal curveY = ICurve(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    ICurve constant internal curveBinance = ICurve(0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27);
    ICurve constant internal curveSynthetix = ICurve(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD);
    ICurve constant internal curvePAX = ICurve(0x06364f10B501e868329afBc005b3492902d6C763);
    ICurve constant internal curveRenBTC = ICurve(0x93054188d876f558f4a66B2EF1d97d16eDf0895B);
    ICurve constant internal curveTBTC = ICurve(0x9726e9314eF1b96E45f40056bEd61A088897313E);
    ICurve constant internal curveSBTC = ICurve(0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714);
    IShell constant internal shell = IShell(0xA8253a440Be331dC4a7395B73948cCa6F19Dc97D);
    IAaveLendingPool constant internal aave = IAaveLendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    ICompound constant internal compound = ICompound(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    ICompoundEther constant internal cETH = ICompoundEther(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    IUniswapV2Factory constant internal uniswapV2 = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IMStable constant internal musd = IMStable(0xe2f2a5C287993345a840Db3B0845fbC70f5935a5);
    IMassetValidationHelper constant internal musd_helper = IMassetValidationHelper(0xaBcC93c3be238884cc3309C19Afd128fAfC16911);
    IBalancerRegistry constant internal balancerRegistry = IBalancerRegistry(0x65e67cbc342712DF67494ACEfc06fe951EE93982);
    ICurveCalculator constant internal curveCalculator = ICurveCalculator(0xc1DB00a8E5Ef7bfa476395cdbcc98235477cDE4E);
    ICurveRegistry constant internal curveRegistry = ICurveRegistry(0x7002B727Ef8F5571Cb5F9D70D13DBEEb4dFAe9d1);
    ICompoundRegistry constant internal compoundRegistry = ICompoundRegistry(0xF451Dbd7Ba14BFa7B1B78A766D3Ed438F79EE1D1);
    IAaveRegistry constant internal aaveRegistry = IAaveRegistry(0xEd8b133B7B88366E01Bb9E38305Ab11c26521494);
    IBalancerHelper constant internal balancerHelper = IBalancerHelper(0xA961672E8Db773be387e775bc4937C678F3ddF9a);

    int256 internal constant VERY_NEGATIVE_VALUE = -1e72;
}
