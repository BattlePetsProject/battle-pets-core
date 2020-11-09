pragma solidity =0.6.6;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract WeaponToken is ERC20Pausable, AccessControl, Ownable {
    bytes32 public constant SAFE_MINT_ROLE = keccak256('SAFE_MINT_ROLE');

    constructor() public ERC20('Weapon Token', 'WEAPON') {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _mint(address(this), 5E25);
    }

    function safeMint(address _to, uint256 _amount) public whenNotPaused returns (uint256 balance) {
        require(hasRole(SAFE_MINT_ROLE, _msgSender()), 'Must have safe mint role');
        balance = balanceOf(address(this));
        if (balance != 0) {
            balance = _amount > balance ? balance : _amount;
            if (allowance(address(this), _msgSender()) < balance) {
                _approve(address(this), _msgSender(), uint256(-1));
            }
            transferFrom(address(this), _to, balance);
        }
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(
            amount,
            'ERC20: burn amount exceeds allowance'
        );

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
