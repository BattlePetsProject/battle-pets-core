import { Erc20 } from '../../typechain/Erc20'
import { Erc20Factory } from '../../typechain/Erc20Factory'

const { ethers } = require('@nomiclabs/buidler')

export const approveErc20 = async (token: string, to: string) => {
  const erc20Factory: Erc20Factory = await ethers.getContractFactory('Erc20')
  const erc20: Erc20 = erc20Factory.attach(token)
  const approveTx = await erc20.approve(to, ethers.constants.MaxUint256)
  console.log(`approveErc20 ${approveTx.hash}`)
  await approveTx.wait()
  console.log(`approveErc20 done`)
}
