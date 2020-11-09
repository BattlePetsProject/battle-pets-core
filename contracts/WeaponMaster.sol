pragma solidity =0.6.6;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/Math.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721Holder.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';

import './WeaponToken.sol';
import './WeaponNFT.sol';

contract WeaponMaster is ERC721Holder, Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. WEAPONs to distribute per block.
        uint256 lastRewardBlock; // Last block number that WEAPONs distribution occurs.
        uint256 accWeaponPerShare; // Accumulated WEAPONs per share, times 1e12. See below.
    }
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when WEAPON mining starts.
    uint256 public immutable startBlock;
    // WEAPON tokens created per block.
    uint256 public weaponPerBlock;
    // Accumulated WEAPONs per share, times 1e12.
    uint256 public constant accWeaponPerShareMultiple = 1E12;
    uint256 public totalStakingWeaponNFTPower;
    // The WEAPON TOKEN!
    WeaponToken public immutable weapon;
    WeaponNFT public weaponNFT;
    address[] public poolAddresses;
    // Info of each pool.
    mapping(address => PoolInfo) public poolInfoMap;
    // Info of each user that stakes LP tokens.
    mapping(address => mapping(address => UserInfo)) public poolUserInfoMap;
    mapping(address => EnumerableSet.UintSet) private _stakingWeaponNftTokens;

    event SetWeaponPerBlock(address indexed user, uint256 weaponPerBlock);
    event Stake(address indexed user, address indexed poolAddress, uint256 amount);
    event Unstake(address indexed user, address indexed poolAddress, uint256 amount);
    event EmergencyUnstake(address indexed user, address indexed poolAddress, uint256 amount);
    event StakeWeaponNFT(address indexed user, uint256 indexed tokenId, uint256 amount);
    event UnstakeWeaponNFT(address indexed user, uint256 indexed tokenId, uint256 amount);
    event EmergencyUnstakeWeaponNFT(address indexed user, uint256 indexed tokenId, uint256 amount);

    constructor(
        address _weapon,
        address _weaponNFT,
        uint256 _startBlock,
        uint256 _weaponPerBlock
    ) public {
        weapon = WeaponToken(_weapon);
        weaponNFT = WeaponNFT(_weaponNFT);
        startBlock = _startBlock;
        weaponPerBlock = _weaponPerBlock;
    }

    // *** POOL MANAGER ***
    function poolLength() external view returns (uint256) {
        return poolAddresses.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        address _pair,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        PoolInfo storage pool = poolInfoMap[_pair];
        require(pool.lastRewardBlock == 0, 'pool already exists');
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        pool.allocPoint = _allocPoint;
        pool.lastRewardBlock = lastRewardBlock;
        pool.accWeaponPerShare = 0;
        poolAddresses.push(_pair);
    }

    // Update the given pool's WEAPON allocation point. Can only be called by the owner.
    function set(
        address _pair,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        PoolInfo storage pool = poolInfoMap[_pair];
        require(pool.lastRewardBlock != 0, 'pool not exists');
        totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(_allocPoint);
        pool.allocPoint = _allocPoint;
    }

    // Return total reward over the given _from to _to block.
    function getTotalReward(uint256 _from, uint256 _to) public view returns (uint256 totalReward) {
        uint256 balance = weapon.balanceOf(address(weapon));
        if (_to <= startBlock || balance == 0) {
            return 0;
        }
        if (_from < startBlock) {
            _from = startBlock;
        }
        return Math.min(balance, _to.sub(_from).mul(weaponPerBlock));
    }

    // View function to see pending WEAPONs on frontend.
    function pendingWeapon(address _pair, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfoMap[_pair];
        if (pool.lastRewardBlock == 0) {
            return 0;
        }
        UserInfo storage userInfo = poolUserInfoMap[_pair][_user];
        uint256 accWeaponPerShare = pool.accWeaponPerShare;
        uint256 stakeBalance = address(weaponNFT) != _pair
            ? IERC20(_pair).balanceOf(address(this))
            : totalStakingWeaponNFTPower;
        if (block.number > pool.lastRewardBlock && stakeBalance != 0) {
            uint256 totalReward = getTotalReward(pool.lastRewardBlock, block.number);
            uint256 weaponReward = totalReward.mul(pool.allocPoint).div(totalAllocPoint);
            accWeaponPerShare = accWeaponPerShare.add(weaponReward.mul(accWeaponPerShareMultiple).div(stakeBalance));
        }
        return userInfo.amount.mul(accWeaponPerShare).div(accWeaponPerShareMultiple).sub(userInfo.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolAddresses.length;
        for (uint256 i = 0; i < length; ++i) {
            updatePool(poolAddresses[i]);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(address _pair) public {
        PoolInfo storage pool = poolInfoMap[_pair];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 stakeBalance = address(weaponNFT) != _pair
            ? IERC20(_pair).balanceOf(address(this))
            : totalStakingWeaponNFTPower;
        if (stakeBalance == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 totalReward = getTotalReward(pool.lastRewardBlock, block.number);
        uint256 weaponReward = totalReward.mul(pool.allocPoint).div(totalAllocPoint);
        weaponReward = weapon.safeMint(address(this), weaponReward);
        pool.accWeaponPerShare = pool.accWeaponPerShare.add(
            weaponReward.mul(accWeaponPerShareMultiple).div(stakeBalance)
        );
        pool.lastRewardBlock = block.number;
    }

    // Stake LP tokens to WeaponMaster for WEAPON allocation.
    function stake(address _pair, uint256 _amount) public whenNotPaused {
        PoolInfo storage pool = poolInfoMap[_pair];
        UserInfo storage userInfo = poolUserInfoMap[_pair][msg.sender];
        updatePool(_pair);
        if (userInfo.amount != 0) {
            uint256 pending = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple).sub(
                userInfo.rewardDebt
            );
            if (pending != 0) {
                safeWeaponTransfer(msg.sender, pending);
            }
        }
        IERC20(_pair).safeTransferFrom(address(msg.sender), address(this), _amount);
        userInfo.amount = userInfo.amount.add(_amount);
        userInfo.rewardDebt = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple);
        emit Stake(msg.sender, _pair, _amount);
    }

    // Unstake LP tokens from WeaponMaster.
    function unstake(address _pair, uint256 _amount) public {
        PoolInfo storage pool = poolInfoMap[_pair];
        UserInfo storage userInfo = poolUserInfoMap[_pair][msg.sender];
        require(userInfo.amount >= _amount, 'unstake: not good');
        updatePool(_pair);
        uint256 pending = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple).sub(
            userInfo.rewardDebt
        );
        if (pending != 0) {
            safeWeaponTransfer(msg.sender, pending);
        }
        if (_amount != 0) {
            userInfo.amount = userInfo.amount.sub(_amount);
            IERC20(_pair).safeTransfer(address(msg.sender), _amount);
        }
        userInfo.rewardDebt = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple);
        emit Unstake(msg.sender, _pair, _amount);
    }

    // Unstake without caring about rewards. EMERGENCY ONLY.
    function emergencyUnstake(address _pair, uint256 _amount) public {
        UserInfo storage userInfo = poolUserInfoMap[_pair][msg.sender];
        PoolInfo memory pool = poolInfoMap[_pair];

        if (_amount == 0) {
            _amount = userInfo.amount;
        } else {
            _amount = Math.min(_amount, userInfo.amount);
        }
        IERC20(_pair).safeTransfer(address(msg.sender), _amount);
        emit EmergencyUnstake(msg.sender, _pair, _amount);
        if (_amount == userInfo.amount) {
            delete poolUserInfoMap[_pair][msg.sender];
        } else {
            userInfo.amount = userInfo.amount.sub(_amount);
            userInfo.rewardDebt = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple);
        }
    }

    function stakeWeaponNFT(uint256 tokenId) public whenNotPaused {
        address _pair = address(weaponNFT);
        PoolInfo storage pool = poolInfoMap[_pair];
        UserInfo storage userInfo = poolUserInfoMap[_pair][msg.sender];
        updatePool(_pair);
        if (userInfo.amount != 0) {
            uint256 pending = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple).sub(
                userInfo.rewardDebt
            );
            if (pending != 0) {
                safeWeaponTransfer(msg.sender, pending);
            }
        }
        if (tokenId != 0) {
            weaponNFT.safeTransferFrom(address(msg.sender), address(this), tokenId);
            (, uint256 stakingPower, , , ) = weaponNFT.weaponInfoMap(tokenId);
            userInfo.amount = userInfo.amount.add(stakingPower);
            _stakingWeaponNftTokens[msg.sender].add(tokenId);
            totalStakingWeaponNFTPower = totalStakingWeaponNFTPower.add(stakingPower);
            emit StakeWeaponNFT(msg.sender, tokenId, stakingPower);
        }
        userInfo.rewardDebt = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple);
    }

    function unstakeWeaponNFT(uint256 tokenId) public {
        require(_stakingWeaponNftTokens[msg.sender].contains(tokenId), 'unstake weaponNft forbidden');
        address _pair = address(weaponNFT);
        PoolInfo storage pool = poolInfoMap[_pair];
        UserInfo storage userInfo = poolUserInfoMap[_pair][msg.sender];
        updatePool(_pair);
        uint256 pending = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple).sub(
            userInfo.rewardDebt
        );
        if (pending != 0) {
            safeWeaponTransfer(msg.sender, pending);
        }
        (, uint256 stakingPower, , , ) = weaponNFT.weaponInfoMap(tokenId);
        userInfo.amount = userInfo.amount.sub(stakingPower);
        totalStakingWeaponNFTPower = totalStakingWeaponNFTPower.sub(stakingPower);
        _stakingWeaponNftTokens[msg.sender].remove(tokenId);
        weaponNFT.safeTransferFrom(address(this), address(msg.sender), tokenId);
        userInfo.rewardDebt = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple);
        emit UnstakeWeaponNFT(msg.sender, tokenId, stakingPower);
    }

    function unstakeAllWeaponNFT() public {
        EnumerableSet.UintSet storage stakingWeaponNftTokens = _stakingWeaponNftTokens[msg.sender];
        uint256 length = stakingWeaponNftTokens.length();
        for (uint256 i = 0; i < length; ++i) {
            unstakeWeaponNFT(stakingWeaponNftTokens.at(0));
        }
    }

    function emergencyUnstakeWeaponNFT(uint256 tokenId) public {
        require(_stakingWeaponNftTokens[msg.sender].contains(tokenId), 'emergency unstake weaponNft forbidden');
        address _pair = address(weaponNFT);
        UserInfo storage userInfo = poolUserInfoMap[_pair][msg.sender];
        PoolInfo memory pool = poolInfoMap[_pair];
        (, uint256 stakingPower, , , ) = weaponNFT.weaponInfoMap(tokenId);
        userInfo.amount = userInfo.amount.sub(stakingPower);
        totalStakingWeaponNFTPower = totalStakingWeaponNFTPower.sub(stakingPower);
        _stakingWeaponNftTokens[msg.sender].remove(tokenId);
        weaponNFT.safeTransferFrom(address(this), address(msg.sender), tokenId);
        userInfo.rewardDebt = userInfo.amount.mul(pool.accWeaponPerShare).div(accWeaponPerShareMultiple);
        emit EmergencyUnstakeWeaponNFT(msg.sender, tokenId, stakingPower);
    }

    function emergencyAllUnstakeWeaponNFT() public {
        EnumerableSet.UintSet storage stakingWeaponNftTokens = _stakingWeaponNftTokens[msg.sender];
        uint256 length = stakingWeaponNftTokens.length();
        for (uint256 i = 0; i < length; ++i) {
            emergencyUnstakeWeaponNFT(stakingWeaponNftTokens.at(0));
        }
    }

    function getStakingWeaponNftLength(address user) public view returns (uint256) {
        return _stakingWeaponNftTokens[user].length();
    }

    function tokenOfWeaponNftStakerByIndex(address staker, uint256 index) public view returns (uint256) {
        return _stakingWeaponNftTokens[staker].at(index);
    }

    // Safe weapon transfer function, just in case if rounding error causes pool to not have enough WEAPONs.
    function safeWeaponTransfer(address _to, uint256 _amount) internal {
        uint256 weaponBal = weapon.balanceOf(address(this));
        if (_amount > weaponBal) {
            weapon.transfer(_to, weaponBal);
        } else {
            weapon.transfer(_to, _amount);
        }
    }

    function pauseStake() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpauseStake() public onlyOwner whenPaused {
        _unpause();
    }

    function setWeaponPerBlock(uint256 _weaponPerBlock) public onlyOwner {
        require(weaponPerBlock != _weaponPerBlock, ' NOT NEED UPDATE');
        emit SetWeaponPerBlock(msg.sender, _weaponPerBlock);
        weaponPerBlock = _weaponPerBlock;
    }
}
