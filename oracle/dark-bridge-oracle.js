const ethers = require('ethers');
require('dotenv').config();

const INCO_RPC = 'https://sepolia.base.org';
const RISE_RPC = 'https://testnet.riselabs.xyz';

const INCO_VAULT = process.env.INCO_VAULT || '0xdf4C7863Ae5FcDC015bE73732E3CFF4AC2cf47e9';
const RISE_BRIDGE = process.env.RISE_BRIDGE || '0x0980cF9a9fB86761E33717a2e5A1c0678363d029';

const VAULT_ABI = [
  'event Deposited(address indexed user, uint256 amount)',
  'event Withdrawn(address indexed user, uint256 amount)'
];

const BRIDGE_ABI = [
  'function submitProof(address user, uint256 amount, bytes32 proof) external'
];

let incoProvider, riseProvider, signer, lastBlock;

async function init() {
  console.log('🔮 HERMES Dark Bridge Oracle starting...');
  console.log('📍 Monitoring Inco Vault:', INCO_VAULT);
  console.log('📍 RISE Bridge:', RISE_BRIDGE);

  try {
    incoProvider = new ethers.JsonRpcProvider(INCO_RPC);
    riseProvider = new ethers.JsonRpcProvider(RISE_RPC);
    
    if (!process.env.ORACLE_PRIVATE_KEY) {
      console.error('❌ ORACLE_PRIVATE_KEY not set!');
      process.exit(1);
    }
    
    signer = new ethers.Wallet(process.env.ORACLE_PRIVATE_KEY, riseProvider);
    console.log('🔑 Oracle address:', signer.address);

    lastBlock = await incoProvider.getBlockNumber();
    console.log('📦 Starting from block:', lastBlock);
    console.log('✅ Oracle running! Polling every 12 seconds...\n');

    // Poll every 12 seconds (Base Sepolia block time)
    setInterval(pollDeposits, 12000);
    
  } catch (error) {
    console.error('💥 INIT ERROR:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

async function pollDeposits() {
  try {
    const currentBlock = await incoProvider.getBlockNumber();
    
    if (currentBlock <= lastBlock) return;

    const vault = new ethers.Contract(INCO_VAULT, VAULT_ABI, incoProvider);
    
    const filter = vault.filters.Deposited();
    const events = await vault.queryFilter(filter, lastBlock + 1, currentBlock);
    
    if (events.length > 0) {
      console.log(`\n📬 Found ${events.length} deposit(s) in blocks ${lastBlock + 1} → ${currentBlock}`);
      
      for (const event of events) {
        console.log('\n💰 Deposit detected!');
        console.log('   User:', event.args.user);
        console.log('   Amount:', ethers.formatEther(event.args.amount), 'ETH');
        console.log('   Block:', event.blockNumber);
        console.log('   TX:', event.transactionHash);
        
        await relayToRise(event.args.user, event.args.amount, event.transactionHash);
      }
    }
    
    lastBlock = currentBlock;
    
  } catch (error) {
    console.error('❌ Polling error:', error.message);
  }
}

async function relayToRise(user, amount, txHash) {
  try {
    const bridge = new ethers.Contract(RISE_BRIDGE, BRIDGE_ABI, signer);
    
    // Generate proof (simple hash for demo)
    const proof = ethers.keccak256(
      ethers.solidityPacked(
        ['address', 'uint256', 'bytes32'],
        [user, amount, txHash]
      )
    );
    
    console.log('📡 Relaying to RISE...');
    console.log('   Proof:', proof);
    
    const tx = await bridge.submitProof(user, amount, proof);
    console.log('   TX hash:', tx.hash);
    
    const receipt = await tx.wait();
    console.log('✅ Relayed! Gas used:', receipt.gasUsed.toString());
    
  } catch (error) {
    console.error('❌ Relay error:', error.message);
  }
}

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Oracle shutting down...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n👋 Oracle shutting down...');
  process.exit(0);
});

// Keep alive
process.on('uncaughtException', (error) => {
  console.error('💥 UNCAUGHT EXCEPTION:', error);
});

process.on('unhandledRejection', (error) => {
  console.error('💥 UNHANDLED REJECTION:', error);
});

init().catch(error => {
  console.error('💥 FATAL ERROR:', error);
  process.exit(1);
});
