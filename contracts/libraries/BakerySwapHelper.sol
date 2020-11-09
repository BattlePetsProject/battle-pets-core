pragma solidity >=0.6.0;

import '@openzeppelin/contracts/math/Math.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

library BakerySwapHelper {
    using SafeMath for uint256;
    uint256 public constant PRICE_MULTIPLE = 1E8;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'BakerySwapHelper: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'BakerySwapHelper: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex'e2e87433120e32c4738a7d8f3271f3d872cbe16241d67537139158d90bac61d3' // init code hash
                    )
                )
            )
        );
    }

    function getPrice(
        address factory,
        address _baseToken,
        address _quoteToken
    ) internal view returns (uint256 price) {
        if (_baseToken == _quoteToken) {
            price = 1;
        } else {
            address pair = BakerySwapHelper.pairFor(factory, _baseToken, _quoteToken);
            uint256 baseTokenAmount = IERC20(_baseToken).balanceOf(pair);
            uint256 quoteTokenAmount = IERC20(_quoteToken).balanceOf(pair);
            price = quoteTokenAmount
                .mul(PRICE_MULTIPLE)
                .mul(10**uint256(ERC20(_baseToken).decimals()))
                .div(10**uint256(ERC20(_quoteToken).decimals()))
                .div(baseTokenAmount);
        }
    }
}
